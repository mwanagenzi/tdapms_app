class TenantNotification {
  final int id;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final bool read; // API returns a boolean, not a timestamp
  final String createdAt;

  const TenantNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    required this.read,
    required this.createdAt,
  });

  bool get isUnread => !read;

  factory TenantNotification.fromJson(Map<String, dynamic> json) =>
      TenantNotification(
        id: (json['id'] as num?)?.toInt() ?? 0,
        type: json['type'] as String? ?? '',
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        data: json['data'] is Map
            ? json['data'] as Map<String, dynamic>
            : null,
        read: json['read'] as bool? ?? false,
        createdAt: json['created_at'] as String? ?? '',
      );
}

class NotificationPage {
  final List<TenantNotification> items;
  final int unreadCount;
  final int currentPage;
  final int lastPage;

  const NotificationPage({
    required this.items,
    required this.unreadCount,
    required this.currentPage,
    required this.lastPage,
  });

  bool get hasMore => currentPage < lastPage;

  NotificationPage markRead(int id) {
    return NotificationPage(
      items: items
          .map((n) => n.id == id
              ? TenantNotification(
                  id: n.id,
                  type: n.type,
                  title: n.title,
                  body: n.body,
                  data: n.data,
                  read: true,
                  createdAt: n.createdAt,
                )
              : n)
          .toList(),
      unreadCount: (unreadCount - 1).clamp(0, unreadCount),
      currentPage: currentPage,
      lastPage: lastPage,
    );
  }

  NotificationPage markAllRead() {
    return NotificationPage(
      items: items
          .map((n) => TenantNotification(
                id: n.id,
                type: n.type,
                title: n.title,
                body: n.body,
                data: n.data,
                read: true,
                createdAt: n.createdAt,
              ))
          .toList(),
      unreadCount: 0,
      currentPage: currentPage,
      lastPage: lastPage,
    );
  }
}
