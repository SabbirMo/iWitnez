import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/sos_recipient_model.dart';
import '../model/sos_upload_state.dart';
import '../repository/sos_repository.dart';

class SosUploadNotifier extends Notifier<SosUploadState> {
  @override
  SosUploadState build() {
    return const SosUploadState();
  }

  /// Automatically handles session recovery, multipart file upload,
  /// recipient delivery parsing, and graceful error handling.
  Future<void> uploadRecording({
    required String? alertId,
    required String? videoFilePath,
    int? durationSeconds,
  }) async {
    // If upload is already in progress, avoid duplicate dispatch
    if (state.isUploading) return;

    // 1. Recover Alert ID from active session if not directly supplied
    String? resolvedAlertId = alertId;
    if (resolvedAlertId == null || resolvedAlertId.isEmpty) {
      try {
        final active = await ref.read(sosRepositoryProvider).getActiveSos();
        resolvedAlertId = active?['id']?.toString();
      } catch (e) {
        debugPrint('Active SOS recovery error: $e');
      }
    }

    if (!ref.mounted) return;

    if (resolvedAlertId == null || resolvedAlertId.isEmpty) {
      state = state.copyWith(
        isUploading: false,
        errorMessage: 'Alert session ID not found.',
      );
      return;
    }

    // 2. Validate video file path on disk
    if (videoFilePath == null || videoFilePath.isEmpty) {
      state = state.copyWith(
        isUploading: false,
        errorMessage: 'Recording file not found on device.',
      );
      return;
    }

    state = state.copyWith(isUploading: true, errorMessage: null);

    try {
      final repository = ref.read(sosRepositoryProvider);
      final responseData = await repository.uploadRecording(
        alertId: resolvedAlertId,
        videoFilePath: videoFilePath,
        durationSeconds: durationSeconds,
      );

      if (!ref.mounted) return;

      if (responseData != null) {
        final rawRecipients = responseData['recipients'] as List<dynamic>?;
        final recipientsList = rawRecipients != null
            ? rawRecipients
                  .whereType<Map<String, dynamic>>()
                  .map((r) => SosRecipientModel.fromJson(r))
                  .toList()
            : <SosRecipientModel>[];

        final recMap = responseData['recording'] as Map<String, dynamic>?;

        state = state.copyWith(
          isUploading: false,
          isUploadSuccess: true,
          recipients: recipientsList,
          videoUrl: recMap?['video_url']?.toString(),
          formattedDuration: recMap?['formatted_duration']?.toString(),
          errorMessage: null,
        );
      } else {
        state = state.copyWith(
          isUploading: false,
          errorMessage: 'Failed to upload emergency recording.',
        );
      }
    } catch (e) {
      if (!ref.mounted) return;

      String errorMsg = 'Upload error: $e';
      if (e is DioException && e.response?.data is Map) {
        final data = e.response!.data as Map;
        final msg = data['message']?.toString();
        final errs = data['errors']?.toString();
        errorMsg = msg ?? errs ?? errorMsg;
      }

      state = state.copyWith(isUploading: false, errorMessage: errorMsg);
    }
  }
}

final sosUploadProvider =
    NotifierProvider.autoDispose<SosUploadNotifier, SosUploadState>(
      SosUploadNotifier.new,
    );
