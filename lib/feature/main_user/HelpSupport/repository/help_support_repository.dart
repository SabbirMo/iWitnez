import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/core/network/api_endpoint/api_end_point.dart';
import 'package:iwitnez/core/network/service/api_services.dart';
import '../model/help_support_model.dart';

class HelpSupportRepository {
  final ApiServices _apiServices;

  HelpSupportRepository([ApiServices? apiServices])
    : _apiServices = apiServices ?? ApiServices();

  /// GET /api/v1/support/faqs/
  Future<List<FaqModel>> getFaqs() async {
    final response = await _apiServices.get(
      ApiEndPoints.supportFaqs,
      requireAuth: true,
    );

    final resData = response.data?['data'];
    if (resData is List) {
      final list = <FaqModel>[];
      for (int i = 0; i < resData.length; i++) {
        final item = resData[i];
        if (item is Map<String, dynamic>) {
          list.add(FaqModel.fromJson(item, i + 1));
        }
      }
      list.sort((a, b) => a.order.compareTo(b.order));
      return list;
    }
    return [];
  }

  /// POST /api/v1/support/contact/
  /// Body:
  /// {
  ///   "email": "...",
  ///   "message": "..."
  /// }
  Future<String?> submitContact({
    required String email,
    required String message,
  }) async {
    final response = await _apiServices.post(
      ApiEndPoints.supportContact,
      data: {'email': email, 'message': message},
      requireAuth: true,
    );

    final resData = response.data;
    if (resData is Map<String, dynamic>) {
      final msg = resData['message'] as String?;
      if (msg != null && msg.isNotEmpty) {
        return msg;
      }
    }
    return 'Your message has been sent to our safety support team. We will contact you shortly.';
  }
}

final helpSupportRepositoryProvider = Provider<HelpSupportRepository>((ref) {
  return HelpSupportRepository();
});
