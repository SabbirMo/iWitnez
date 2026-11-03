import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/core/network/api_endpoint/api_end_point.dart';
import 'package:iwitnez/core/network/service/api_services.dart';
import '../model/cms_content_model.dart';

final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  return ContentRepository();
});

final privacyPolicyFutureProvider = FutureProvider.autoDispose<CmsContentModel?>((ref) async {
  return ref.watch(contentRepositoryProvider).getPrivacyPolicy();
});

final termsOfServiceFutureProvider = FutureProvider.autoDispose<CmsContentModel?>((ref) async {
  return ref.watch(contentRepositoryProvider).getTermsOfService();
});

final whoWeAreFutureProvider = FutureProvider.autoDispose<CmsContentModel?>((ref) async {
  return ref.watch(contentRepositoryProvider).getWhoWeAre();
});

final ourMissionFutureProvider = FutureProvider.autoDispose<CmsContentModel?>((ref) async {
  return ref.watch(contentRepositoryProvider).getOurMission();
});

class ContentRepository {
  final ApiServices _apiServices;

  ContentRepository([ApiServices? apiServices])
      : _apiServices = apiServices ?? ApiServices();

  Future<CmsContentModel?> getPrivacyPolicy() async {
    return _fetchContent(ApiEndPoints.contentPrivacyPolicy);
  }

  Future<CmsContentModel?> getTermsOfService() async {
    return _fetchContent(ApiEndPoints.contentTermsOfService);
  }

  Future<CmsContentModel?> getAboutUs() async {
    return _fetchContent(ApiEndPoints.contentAboutUs);
  }

  Future<CmsContentModel?> getWhoWeAre() async {
    return _fetchContent(ApiEndPoints.contentWhoWeAre);
  }

  Future<CmsContentModel?> getOurMission() async {
    return _fetchContent(ApiEndPoints.contentOurMission);
  }

  Future<CmsContentModel?> _fetchContent(String endpoint) async {
    try {
      final response = await _apiServices.get(endpoint, requireAuth: false);
      final dynamic raw = response.data;
      if (raw is Map<String, dynamic>) {
        final dynamic data = raw['data'] ?? raw;
        if (data is Map<String, dynamic>) {
          return CmsContentModel.fromJson(data);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
