import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class MediaDownloadHelper {
  /// Downloads a video or audio file to local phone storage on both Android and iOS.
  static Future<File?> downloadMedia({
    required BuildContext context,
    required String url,
    required String mediaType,
    String? preferredFileName,
  }) async {
    final messenger = ScaffoldMessenger.of(context);

    if (url.trim().isEmpty) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('$mediaType download link is not available.'),
          backgroundColor: const Color(0xFFD92D20),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
      return null;
    }

    // Upgrade http to https for secure/ngrok endpoints
    String downloadUrl = url.trim();
    if (downloadUrl.startsWith('http://') && downloadUrl.contains('ngrok')) {
      downloadUrl = downloadUrl.replaceFirst('http://', 'https://');
    }

    // Notify user download started
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 18.r,
              height: 18.r,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Downloading $mediaType...',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF344054),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );

    try {
      // 1. Request permissions on Android if applicable
      if (Platform.isAndroid) {
        final status = await Permission.storage.status;
        if (!status.isGranted) {
          await Permission.storage.request();
        }
      }

      // 2. Extract clean file name with extension
      String ext = mediaType.toLowerCase().contains('video') ? 'mp4' : 'mp3';
      try {
        final uri = Uri.parse(downloadUrl);
        final segment = uri.pathSegments.isNotEmpty
            ? uri.pathSegments.last
            : '';
        if (segment.contains('.')) {
          ext = segment.split('.').last;
        }
      } catch (_) {}

      final baseName =
          preferredFileName?.replaceAll(RegExp(r'[^\w\.-]'), '_') ??
          '${mediaType.toLowerCase().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}';
      final fileName = baseName.endsWith('.$ext') ? baseName : '$baseName.$ext';

      // 3. Resolve destination folder
      Directory? targetDir;
      if (Platform.isAndroid) {
        // Standard Android Downloads directory
        final publicDownload = Directory('/storage/emulated/0/Download');
        if (publicDownload.existsSync()) {
          targetDir = publicDownload;
        } else {
          try {
            targetDir = await getDownloadsDirectory();
          } catch (_) {}
          targetDir ??=
              await getExternalStorageDirectory() ??
              await getApplicationDocumentsDirectory();
        }
      } else {
        // iOS: ApplicationDocumentsDirectory (visible in Files app with UIFileSharingEnabled)
        targetDir = await getApplicationDocumentsDirectory();
      }

      final targetPath = '${targetDir.path}/$fileName';
      final dio = Dio();

      // 4. Download file
      await dio.download(
        downloadUrl,
        targetPath,
        options: Options(
          headers: {'ngrok-skip-browser-warning': 'true'},
          responseType: ResponseType.bytes,
          followRedirects: true,
        ),
      );

      final file = File(targetPath);
      if (await file.exists() && await file.length() > 0) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'Saved to storage: $fileName',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            action: SnackBarAction(
              label: 'Share',
              textColor: const Color(0xFFF9F5FF),
              onPressed: () {
                SharePlus.instance.share(
                  ShareParams(
                    files: [XFile(file.path)],
                    text: 'Emergency $mediaType recording',
                  ),
                );
              },
            ),
            backgroundColor: const Color(0xFF039855),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
        return file;
      } else {
        throw Exception('Downloaded file is empty');
      }
    } catch (e) {
      debugPrint('Media download error: $e');
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to download $mediaType: ${e.toString()}'),
          backgroundColor: const Color(0xFFD92D20),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
      return null;
    }
  }
}
