class MessageAttachment {
  final String url;
  final String filename;

  const MessageAttachment({required this.url, required this.filename});

  factory MessageAttachment.fromJson(Map<String, dynamic> json) =>
      MessageAttachment(
        url: json['url'] as String? ?? '',
        filename: json['filename'] as String? ?? '',
      );
}

class Message {
  final int id;
  final String senderName;
  final String body;
  final bool isMine;
  final bool read;
  final String createdAt;
  final List<MessageAttachment> attachments;

  const Message({
    required this.id,
    required this.senderName,
    required this.body,
    required this.isMine,
    required this.read,
    required this.createdAt,
    this.attachments = const [],
  });

  bool get isRead => read;

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: (json['id'] as num?)?.toInt() ?? 0,
        // sender is either {id, name} object or a plain string
        senderName: json['sender'] is Map
            ? (json['sender'] as Map<String, dynamic>)['name'] as String? ??
                'Unknown'
            : json['sender'] as String? ?? 'Unknown',
        body: json['body'] as String? ?? '',
        isMine: json['is_mine'] as bool? ?? false,
        read: json['read'] as bool? ?? false,
        createdAt: json['created_at'] as String? ?? '',
        attachments: (json['attachments'] as List? ?? [])
            .map((e) =>
                MessageAttachment.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
