/// Lightweight preview of the most recent message in a thread,
/// as returned by GET /api/messages (list endpoint).
class LastMessage {
  final String body;
  final String sender; // plain sender name string from the API
  final String date;   // ISO 8601

  const LastMessage({
    required this.body,
    required this.sender,
    required this.date,
  });

  factory LastMessage.fromJson(Map<String, dynamic> json) => LastMessage(
        body: json['body'] as String? ?? '',
        sender: json['sender'] as String? ?? '',
        date: json['date'] as String? ?? '',
      );
}

class Conversation {
  final int id;
  final String subject;
  final int unreadCount;
  final LastMessage? lastMessage;

  const Conversation({
    required this.id,
    required this.subject,
    required this.unreadCount,
    this.lastMessage,
  });

  bool get hasUnread => unreadCount > 0;

  /// Inferred from subject since the list endpoint does not expose context_type.
  String get contextLabel {
    final s = subject.toLowerCase();
    if (s.contains('maintenance')) return 'Maintenance';
    return 'Lease';
  }

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
        id: (json['id'] as num?)?.toInt() ?? 0,
        subject: json['subject'] as String? ?? 'Thread',
        unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
        lastMessage: json['last_message'] is Map
            ? LastMessage.fromJson(
                json['last_message'] as Map<String, dynamic>)
            : null,
      );
}
