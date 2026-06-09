class TenantNotification {
  final int id;
  final int tenantId;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final String? readAt;
  final String createdAt;

  const TenantNotification({
    required this.id,
    required this.tenantId,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    this.readAt,
    required this.createdAt,
  });

  bool get isUnread => readAt == null;

  factory TenantNotification.fromJson(Map<String, dynamic> json) =>
      TenantNotification(
        id: (json['id'] as num?)?.toInt() ?? 0,
        tenantId: (json['tenant_id'] as num?)?.toInt() ?? 0,
        type: json['type'] as String? ?? '',
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        data: json['data'] as Map<String, dynamic>?,
        readAt: json['read_at'] as String?,
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
                  tenantId: n.tenantId,
                  type: n.type,
                  title: n.title,
                  body: n.body,
                  data: n.data,
                  readAt: DateTime.now().toIso8601String(),
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
                tenantId: n.tenantId,
                type: n.type,
                title: n.title,
                body: n.body,
                data: n.data,
                readAt: n.readAt ?? DateTime.now().toIso8601String(),
                createdAt: n.createdAt,
              ))
          .toList(),
      unreadCount: 0,
      currentPage: currentPage,
      lastPage: lastPage,
    );
  }
}
