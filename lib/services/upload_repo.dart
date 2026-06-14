import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:uuid/v4.dart';
import '../core/api/api_client.dart';
import '../core/api/endpoints.dart';

final uploadRepoProvider = Provider<UploadRepo>(
  (ref) => UploadRepo(ref.read(apiClientProvider)),
);

class UploadInit {
  final String uploadId;
  final int chunkSize;

  UploadInit(this.uploadId, this.chunkSize);
}

class UploadInitV3 {
  final String uploadId;
  final String presignedUrl;
  final int maxFileSizeBytes;
 // final List allowedMimeTypes;
  final String expiresAt;

  UploadInitV3(
    this.uploadId,
    this.presignedUrl,
    this.maxFileSizeBytes,
    this.expiresAt,
  );
}

class UploadInit1 {
  final String uploadId;
  final int chunkSize;

  UploadInit1(this.uploadId, this.chunkSize);
}

class UploadRepo {
  final ApiClient api;
  static const int chunkSize = 1024 * 512; // 512 KB
  UploadRepo(this.api);

  /*    fileName: file.name,
            fileExtension: file.name.split(".").pop(),
            mimeType: file.type,
            fileSizeBytes: file.size,
            intendedUsage: usage,*/
  Future<UploadInitV3> initUpload(
    File file,
    String contentType,
  ) async {
    final totalSize = await file.length();
    final r = await api.postJson<Map<String, dynamic>>(Endpoints.attachments_init, {
      "fileName": path.basename(file.path),
      "totalSize": totalSize,
      "tempFilePath": file.path,
      "uploadId": "${Uuid().v4()}"
    });

    return UploadInitV3(
      r['uploadId'],
      r['presignedUrl']??"",
      r['maxFileSizeBytes']??0,
      r['expiresAt']??"",
    );
  }

  Future<void> uploadChunk(String uploadId, int offset, List<int> bytes) async {
    // send as base64 to keep minimal API simple; in production you can use raw bytes + content-range
    await api.postJson(Endpoints.attachments_chunking, {
      'uploadId': uploadId,
      'chunkNumber': 0,
      'chunk': base64Encode(bytes),
    });
  }

  Future<UploadInit> uploadFile(
    String uploadId,
    int offset,
    PlatformFile file,
  ) async {
    var url = Uri.parse("http://192.0.0.235:5274$uploadId");
    var request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('file', file.path!));
    request.headers['FileName'] = file.name;
    var streamResponse = await request.send();
    var responseString = await streamResponse.stream.bytesToString();
    var response = jsonDecode(responseString);
    return UploadInit(response['uploadId'].toString(), file.size);
  }

  Future<Map<String, dynamic>> complete(String uploadId, int size) async {
    /*/api/assets/upload/{id}/complete*/
    return await api.postJson<Map<String, dynamic>>(
      '/api/assets/upload/$uploadId/$size/complete',
      {},
    );
  }

  Future<dynamic> getImages(String uploadId) async {
    final rows = await api.getJson<dynamic>(Endpoints.getImages(uploadId));
    return rows;
  }

  Future<dynamic> getEventAttach(String uploadId) async {
    final rows = await api.getJson<dynamic>(Endpoints.getImages(uploadId));
    return rows;
  }

  Future<dynamic> getAssestLibrary(Map<String, dynamic> payload) async {
    final rows = await api.postJson<dynamic>(
      Endpoints.getAssestLibrary,
      payload,
    );
    return rows;
  }

  Future<void> refreshTmplates(
    String tenantId, {
    String? status,
    String? search,
    int page = 1,
    int pageSize = 0,
  }) async {
    final rows = await api.getJson<List<dynamic>>(
      Endpoints.tmplates(
        tenantId: tenantId,
        status: status,
        search: search,
        page: page,
        pageSize: pageSize,
      ),
    );
    rows;
  }

  Future<dynamic> getSavedContacts(Map<String, dynamic> payload) async {
    final rows = await api.postJson<dynamic>(
      Endpoints.getContactDetails,
      payload,
    );
    return rows;
  }

  Future<dynamic> saveContactList(Map<String, dynamic> payload) async {
    final rows = await api.postJson<dynamic>(
      Endpoints.saveContactListEndPoints,
      payload,
    );
    return rows;
  }

  Future<List<dynamic>> getContactList() async {
    final r = await api.getJson(Endpoints.getListDetails);
    return r;
  }

  Future<List<dynamic>> getCampaigns(String q) async {
    final rows = await api.getJson<List<dynamic>>(
      Endpoints.getcampaigns(
        q: q,
        tId: '00000000-0000-0000-0000-000000000001',
        status: 'draft',
        limit: 50,
        offset: 0,
      ),
    );
    return rows;
  }

  Future<dynamic> getcampaignDetails({required String campaignId}) async {
    final rows = await api.getJson<dynamic>(
      Endpoints.getcampaignDetails(campaignId: campaignId),
    );
    return rows;
  }

  Future<List<dynamic>> getMasterTemplates() async {
    final r = await api.getJson(Endpoints.getMasterTemplates);
    return r;
  }

  Future<dynamic> getTemplateById(String templateID, String? forwhat) async {
    final r;
    if (forwhat == "update") {
      r = await api.getJson(Endpoints.getTemplate(templateID));
    } else {
      r = await api.getJson(Endpoints.getMasterTemplate(templateID));
    }
    return r;
  }

  Future<dynamic> saveCampiagnLinkTemplate(
    String campaignId,
    String templateID,
  ) async {
    final rows = await api.postJson<dynamic>(
      Endpoints.saveCampiagnLinkTemplate(campaignId, templateID),
      {},
    );
    return rows;
  }

  Future<dynamic> saveCampiagnSchedule(
    String campaignId,
    Map<String, dynamic> payload,
  ) async {
    final rows = await api.postJson<dynamic>(
      Endpoints.saveCampiagnSchedule(campaignId),
      payload,
    );
    return rows;
  }
}
