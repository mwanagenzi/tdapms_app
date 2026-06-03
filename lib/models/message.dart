class MessageAttachment {
  final int id;
  final int messageId;
  final String path;
  final String filename;
  final String? mimeType;
  final int? size;

  const MessageAttachment({
    required this.id,
    required this.messageId,
    required this.path,
    required this.filename,
    this.mimeType,
    this.size,
  });

  factory MessageAttachment.fromJson(Map<String, dynamic> json) =>
      MessageAttachment(
        id: json['id'] as int,
        messageId: json['message_id'] as int,
        path: json['path'] as String,
        filename: json['filename'] as String,
        mimeType: json['mime_type'] as String?,
        size: json['size'] as int?,
      );
}

class Message {
  final int id;
  final int conversationId;
  final int senderId;
  final String senderName;
  final String body;
  final String? readAt;
  final String createdAt;
  final List<MessageAttachment> attachments;

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.body,
    this.readAt,
    required this.createdAt,
    this.attachments = const [],
  });

  bool get isRead => readAt != null;

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json['id'] as int,
        conversationId: json['conversation_id'] as int,
        senderId: json['sender_id'] as int,
        senderName:
            (json['sender'] as Map<String, dynamic>?)?['name'] as String? ??
                'Unknown',
        body: json['body'] as String,
        readAt: json['read_at'] as String?,
        createdAt: json['created_at'] as String,
        attachments: (json['attachments'] as List? ?? [])
            .map((e) =>
                MessageAttachment.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
