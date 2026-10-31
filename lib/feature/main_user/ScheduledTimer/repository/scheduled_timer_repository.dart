import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/core/network/api_endpoint/api_end_point.dart';
import 'package:iwitnez/core/network/service/api_services.dart';
import '../model/scheduled_check_in_model.dart';

class ScheduledTimerRepository {
  final ApiServices _apiServices;

  ScheduledTimerRepository([ApiServices? apiServices])
      : _apiServices = apiServices ?? ApiServices();

  /// POST /api/v1/emergency/check-ins/start-timer/
  /// Body:
  /// {
  ///   "hours": 1,
  ///   "minutes": 0,
  ///   "seconds": 0,
  ///   "notes": "I'm at Office",
  ///   "remind_before_end": true,
  ///   "notify_if_not_checked_in": true
  /// }
  Future<ScheduledCheckInModel> startCheckInTimer({
    required int hours,
    required int minutes,
    required int seconds,
    required String notes,
    required bool remindBeforeEnd,
    required bool notifyIfNotCheckedIn,
  }) async {
    final response = await _apiServices.post(
      ApiEndPoints.checkInStartTimer,
      data: {
        'hours': hours,
        'minutes': minutes,
        'seconds': seconds,
        'notes': notes,
        'remind_before_end': remindBeforeEnd,
        'notify_if_not_checked_in': notifyIfNotCheckedIn,
      },
      requireAuth: true,
    );

    final resData = response.data;
    if (resData is Map<String, dynamic> &&
        resData['data'] is Map<String, dynamic>) {
      return ScheduledCheckInModel.fromJson(
        resData['data'] as Map<String, dynamic>,
      );
    }
    return ScheduledCheckInModel(
      id: '',
      title: 'Scheduled Safety Check-In',
      timerDurationSeconds: (hours * 3600) + (minutes * 60) + seconds,
      notes: notes,
      remindBeforeEnd: remindBeforeEnd,
      notifyIfNotCheckedIn: notifyIfNotCheckedIn,
    );
  }
}

final scheduledTimerRepositoryProvider =
    Provider<ScheduledTimerRepository>((ref) {
  return ScheduledTimerRepository();
});

