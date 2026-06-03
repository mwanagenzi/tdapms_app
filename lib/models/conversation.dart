import 'message.dart';

class Conversation {
  final int id;
  final String? subject;
  final String contextType; // App\Models\Lease | App\Models\MaintenanceRequest
  final int contextId;
  final Message? latestMessage;
  final List<Message> messages;

  const Conversation({
    required this.id,
    this.subject,
    required this.contextType,
    required this.contextId,
    this.latestMessage,
    this.messages = const [],
  });

  String get contextLabel {
    if (contextType.contains('Lease')) return 'Lease';
    if (contextType.contains('MaintenanceRequest')) return 'Maintenance';
    return 'General';
  }

  bool get hasUnread {
    if (latestMessage == null) return false;
    return !latestMessage!.isRead;
  }

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
        id: json['id'] as int,
        subject: json['subject'] as String?,
        contextType: json['context_type'] as String? ?? '',
        contextId: json['context_id'] as int? ?? 0,
        latestMessage: json['latest_message'] != null
            ? Message.fromJson(
                json['latest_message'] as Map<String, dynamic>)
            : null,
        messages: (json['messages'] as List? ?? [])
            .map((e) => Message.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
