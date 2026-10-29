import 'package:flutter/foundation.dart';
import 'sos_recipient_model.dart';

@immutable
class SosUploadState {
  final bool isUploading;
  final bool isUploadSuccess;
  final String? errorMessage;
  final List<SosRecipientModel> recipients;
  final String? videoUrl;
  final String? formattedDuration;

  const SosUploadState({
    this.isUploading = false,
    this.isUploadSuccess = false,
    this.errorMessage,
    this.recipients = const [],
    this.videoUrl,
    this.formattedDuration,
  });

  SosUploadState copyWith({
    bool? isUploading,
    bool? isUploadSuccess,
    String? errorMessage,
    List<SosRecipientModel>? recipients,
    String? videoUrl,
    String? formattedDuration,
  }) {
    return SosUploadState(
      isUploading: isUploading ?? this.isUploading,
      isUploadSuccess: isUploadSuccess ?? this.isUploadSuccess,
      errorMessage: errorMessage,
      recipients: recipients ?? this.recipients,
      videoUrl: videoUrl ?? this.videoUrl,
      formattedDuration: formattedDuration ?? this.formattedDuration,
    );
  }
}

