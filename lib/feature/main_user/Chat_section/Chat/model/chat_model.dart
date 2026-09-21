class ChatEntry {
  const ChatEntry({
    required this.name,
    required this.avatarUrl,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
  });

  final String name;
  final String avatarUrl;
  final String lastMessage;
  final String time; // pre-formatted e.g. "9:18 AM" / "Yesterday" / "Mon"
  final int unreadCount;
}