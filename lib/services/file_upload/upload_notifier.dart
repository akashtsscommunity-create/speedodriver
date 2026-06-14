import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../../app/constant.dart';
import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';
import '../../core/api/token_store.dart';
import '../model/upload_state.dart';
import '../upload_repo.dart';
final uploadNotifierProvider =
    StateNotifierProvider<UploadNotifier, UploadState>((ref) {
      return UploadNotifier(ref);
    });

class UploadNotifier extends StateNotifier<UploadState> {
  final Ref ref;

  UploadNotifier(this.ref) : super(UploadState.initial());

  static const int chunkSize = 1024 * 512;

  Future<void> pickAndUploadFile({required UploadMode selectedMode}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        withData: false,
        type: FileType.any,
      );

      if (result == null || result.files.isEmpty) return;

      final picked = result.files.single;

      if (picked.path == null || picked.path!.isEmpty) {
        throw Exception('Selected file path is null');
      }

      final file = File(picked.path!);

      if (!await file.exists()) {
        throw Exception('Selected file does not exist');
      }

      await uploadFile(file, selectedMode: selectedMode);
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        isSuccess: false,
        error: e.toString(),
        message: 'Upload failed',
      );
    }
  }

  Future<void> uploadFile(File file, {required UploadMode selectedMode}) async {
    try {
      final fileName = file.path.split(Platform.pathSeparator).last;
      final fileSize = await file.length();
      final contentType = _getContentType(fileName);

      final actualMode = _resolveMode(
        selectedMode: selectedMode,
        fileSize: fileSize,
      );

      state = state.copyWith(
        isUploading: true,
        progress: 0,
        message: actualMode == UploadMode.multipart
            ? 'Preparing multipart upload...'
            : 'Initializing chunk upload...',
        isSuccess: false,
        error: null,
        fileName: fileName,
        uploadedChunks: 0,
        totalChunks: 0,
        activeMode: actualMode,
      );

      if (actualMode == UploadMode.multipart) {
        await _uploadMultipart(
          file: file,
          fileName: fileName,
          contentType: contentType,
        );
      } else {
        await _uploadChunked(
          file: file,
          fileName: fileName,
          fileSize: fileSize,
          contentType: contentType,
        );
      }

      state = state.copyWith(
        isUploading: false,
        progress: 1.0,
        message: 'Upload completed successfully',
        isSuccess: true,
        error: null,
      );

      await Future.delayed(const Duration(seconds: 2));
      reset();
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        isSuccess: false,
        error: e.toString(),
        message: 'Upload failed',
      );
    }
  }

  Future<void> _uploadMultipart({
    required File file,
    required String fileName,
    required String contentType,
  }) async {
    state = state.copyWith(
      progress: 0.15,
      message: 'Uploading file using multipart...',
      totalChunks: 1,
      uploadedChunks: 0,
    );
    final api = ref.read(apiClientProvider);
    api.postJson(Endpoints.attachments_init, {
      "fileName": fileName,
      "totalSize": file.length(),
      "tempFilePath": file.path,
      "uploadId": "${Uuid().v4()}",
    });

    state = state.copyWith(
      progress: 0.95,
      message: 'Finalizing multipart upload...',
      uploadedChunks: 1,
      totalChunks: 1,
    );
  }

  int calculateTotalChunks(int fileSize, int chunkSize) {
    return (fileSize / chunkSize).ceil();
  }

  Stream<Uint8List> readFileInChunks(
    File file, {
    int chunkSize = 1024 * 512,
  }) async* {
    final raf = await file.open();
    try {
      final fileLength = await file.length();
      int offset = 0;

      while (offset < fileLength) {
        final remaining = fileLength - offset;
        final bytesToRead = min(chunkSize, remaining);
        final bytes = await raf.read(bytesToRead);

        if (bytes.isEmpty) break;

        yield Uint8List.fromList(bytes);
        offset += bytes.length;
      }
    } finally {
      await raf.close();
    }
  }

  Future<void> _uploadChunked({
    required File file,
    required String fileName,
    required int fileSize,
    required String contentType,
  }) async {
    final api = ref.read(apiClientProvider);
    final totalChunks = calculateTotalChunks(fileSize, chunkSize);

    state = state.copyWith(
      totalChunks: totalChunks,
      uploadedChunks: 0,
      progress: 0.02,
      message: 'Initializing chunk upload...',
    );

    final init = await ref.read(uploadRepoProvider).initUpload(file, contentType);
    state = state.copyWith(
      uploadId: init.uploadId,
      progress: 0.08,
      message: 'Chunk upload initialized',
    );

    int chunkIndex = 0;

    await for (final chunk in readFileInChunks(file, chunkSize: chunkSize)) {
      await uploadChunk(
        uploadId: init.uploadId,
        chunkIndex: chunkIndex,
        totalChunks: totalChunks,
        chunkBytes: chunk,
        fileName: fileName,
      );

      chunkIndex++;

      final progress = 0.08 + ((chunkIndex / totalChunks) * 0.84);

      state = state.copyWith(
        progress: progress.clamp(0.0, 0.95),
        message: 'Uploading chunk $chunkIndex of $totalChunks',
        uploadedChunks: chunkIndex,
        totalChunks: totalChunks,
      );
    }

    state = state.copyWith(
      progress: 0.97,
      message: 'Finalizing chunk upload...',
    );

    await finalizeUpload(
      uploadId: init.uploadId,
      fileName: fileName,
      totalChunks: totalChunks,
        contentType:contentType
    );
  }

  Future<void> uploadChunk({
    required String uploadId,
    required int chunkIndex,
    required int totalChunks,
    required Uint8List chunkBytes,
    required String fileName,
  }) async {
    final uri = Uri.parse('${Constant.baseUrl}${Endpoints.attachments_chunking}',);
    final tokens = ref.read(tokenStoreProvider);
    final t = await tokens.getAccessToken();
    final request = http.MultipartRequest('POST', uri)
      ..fields['uploadId'] = uploadId
      ..fields['chunkNumber'] = chunkIndex.toString()
      ..fields['totalChunks'] = totalChunks.toString()
      ..fields['fileName'] = fileName
      ..files.add(
        http.MultipartFile.fromBytes(
          'chunk',
          chunkBytes,
          filename: '$fileName.part$chunkIndex',
        ),
      );
    request.headers['Authorization']= 'Bearer $t';
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Chunk $chunkIndex failed (${response.statusCode}): ${response.body}',
      );
    }
  }

  Future<void> finalizeUpload({
    required String uploadId,
    required String fileName,
    required int totalChunks,
    required String contentType,
  }) async {
    final api = ref.read(apiClientProvider);
    final r = api.postJson(Endpoints.attachments_finalize, {
      'uploadId': uploadId,
      'fileName': fileName,
      'mimeType':contentType,
      'totalChunks': totalChunks,
    });
    r;
  }

  UploadMode _resolveMode({
    required UploadMode selectedMode,
    required int fileSize,
  }) {
    if (selectedMode == UploadMode.multipart) return UploadMode.multipart;
    if (selectedMode == UploadMode.chunk) return UploadMode.chunk;
    return /*fileSize <= multipartThreshold ? UploadMode.multipart : */ UploadMode.chunk;
  }

  void reset() {
    state = UploadState.initial();
  }

  String _getContentType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'pdf':
        return 'application/pdf';
      case 'zip':
        return 'application/zip';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }
}
