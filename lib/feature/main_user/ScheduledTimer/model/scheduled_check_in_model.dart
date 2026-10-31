class ScheduledCheckInModel {
  final String id;
  final String title;
  final String? scheduledTime;
  final String? scheduledTimeDisplay;
  final String status;
  final String? checkedInAt;
  final String? snoozeUntil;
  final int timerDurationSeconds;
  final String formattedTimer;
  final bool remindBeforeEnd;
  final bool notifyIfNotCheckedIn;
  final String notes;
  final String? createdAt;

  ScheduledCheckInModel({
    required this.id,
    required this.title,
    this.scheduledTime,
    this.scheduledTimeDisplay,
    this.status = 'pending',
    this.checkedInAt,
    this.snoozeUntil,
    this.timerDurationSeconds = 0,
    this.formattedTimer = '00:00:00',
    this.remindBeforeEnd = true,
    this.notifyIfNotCheckedIn = true,
    this.notes = '',
    this.createdAt,
  });

  factory ScheduledCheckInModel.fromJson(Map<String, dynamic> json) {
    return ScheduledCheckInModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? 'Scheduled Safety Check-In',
      scheduledTime: json['scheduled_time'] as String?,
      scheduledTimeDisplay: json['scheduled_time_display'] as String?,
      status: json['status'] as String? ?? 'pending',
      checkedInAt: json['checked_in_at'] as String?,
      snoozeUntil: json['snooze_until'] as String?,
      timerDurationSeconds:
          (json['timer_duration_seconds'] as num?)?.toInt() ?? 0,
      formattedTimer: json['formatted_timer'] as String? ?? '00:00:00',
      remindBeforeEnd: json['remind_before_end'] as bool? ?? true,
      notifyIfNotCheckedIn: json['notify_if_not_checked_in'] as bool? ?? true,
      notes: json['notes'] as String? ?? '',
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'scheduled_time': scheduledTime,
      'scheduled_time_display': scheduledTimeDisplay,
      'status': status,
      'checked_in_at': checkedInAt,
      'snooze_until': snoozeUntil,
      'timer_duration_seconds': timerDurationSeconds,
      'formatted_timer': formattedTimer,
      'remind_before_end': remindBeforeEnd,
      'notify_if_not_checked_in': notifyIfNotCheckedIn,
      'notes': notes,
      'created_at': createdAt,
    };
  }
}
