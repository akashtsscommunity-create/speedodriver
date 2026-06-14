/// ---------------------------
/// ENUMS
/// ---------------------------
enum UploadMode {
  auto,
  multipart,
  chunk,
}
class UploadState {
  final bool isUploading;
  final double progress;
  final String message;
  final String? uploadId;
  final bool isSuccess;
  final String? error;
  final String? fileName;
  final int uploadedChunks;
  final int totalChunks;
  final UploadMode? activeMode;

  const UploadState({
    required this.isUploading,
    required this.progress,
    required this.message,
    required this.uploadId,
    required this.isSuccess,
    required this.error,
    required this.fileName,
    required this.uploadedChunks,
    required this.totalChunks,
    required this.activeMode,
  });

  factory UploadState.initial() {
    return const UploadState(
      isUploading: false,
      progress: 0,
      message: '',
      uploadId: null,
      isSuccess: false,
      error: null,
      fileName: null,
      uploadedChunks: 0,
      totalChunks: 0,
      activeMode: null,
    );
  }

  UploadState copyWith({
    bool? isUploading,
    double? progress,
    String? message,
    String? uploadId,
    bool? isSuccess,
    String? error,
    String? fileName,
    int? uploadedChunks,
    int? totalChunks,
    UploadMode? activeMode,
  }) {
    return UploadState(
      isUploading: isUploading ?? this.isUploading,
      progress: progress ?? this.progress,
      message: message ?? this.message,
      uploadId: uploadId ?? this.uploadId,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
      fileName: fileName ?? this.fileName,
      uploadedChunks: uploadedChunks ?? this.uploadedChunks,
      totalChunks: totalChunks ?? this.totalChunks,
      activeMode: activeMode ?? this.activeMode,
    );
  }
}