enum CallDirection { incoming, outgoing, missed }

enum CallType { voice, video }

class CallLogEntry {
  const CallLogEntry({
    required this.name,
    required this.avatarUrl,
    required this.time,
    required this.direction,
    required this.type,
    this.callCount = 1,
  });

  final String name;
  final String avatarUrl;
  final String time; // pre-formatted e.g. "9:18 AM" / "Yesterday" / "Mon"
  final CallDirection direction;
  final CallType type;
  final int callCount;
}