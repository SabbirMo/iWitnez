enum CallDirection { incoming, outgoing, missed }

enum CallType { voice, video }

class CallLogEntry {
  const CallLogEntry({
    required this.name,
    required this.avatarUrl,
    required this.time,
    this.date = 'Today',
    required this.direction,
    required this.type,
    this.duration,
    this.callCount = 1,
  });

  final String name;
  final String avatarUrl;
  final String date;
  final String time;
  final CallDirection direction;
  final CallType type;
  final String? duration;
  final int callCount;
}