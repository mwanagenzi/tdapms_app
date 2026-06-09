import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tenant_notification.dart';
import '../services/api/api_client.dart';

// ---------------------------------------------------------------------------
// Notifications (paginated list + unread count)
// ---------------------------------------------------------------------------

final notificationControllerProvider =
    AsyncNotifierProvider<NotificationController, NotificationPage>(
        NotificationController.new);

class NotificationController extends AsyncNotifier<NotificationPage> {
  @override
  Future<NotificationPage> build() => _fetchPage(1);

  Future<NotificationPage> _fetchPage(int page) async {
    final response = await ref.read(apiClientProvider).get(
          '/api/notifications',
          params: {'page': page},
        );

    // Normalise: handle plain list, resource wrap, or paginator.
    final Map<String, dynamic> raw =
        response is Map<String, dynamic> ? response : {'data': [], 'unread_count': 0, 'current_page': 1, 'last_page': 1};

    final dataRaw = raw['data'];
    final items = (dataRaw is List ? dataRaw : <dynamic>[])
        .map((e) =>
            TenantNotification.fromJson(e as Map<String, dynamic>))
        .toList();

    return NotificationPage(
      items: items,
      unreadCount: raw['unread_count'] as int? ?? 0,
      currentPage: raw['current_page'] as int? ?? 1,
      lastPage: raw['last_page'] as int? ?? 1,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPage(1));
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore) return;

    final next = await _fetchPage(current.currentPage + 1);
    state = AsyncValue.data(
      NotificationPage(
        items: [...current.items, ...next.items],
        unreadCount: next.unreadCount,
        currentPage: next.currentPage,
        lastPage: next.lastPage,
      ),
    );
  }

  Future<void> markRead(int id) async {
    await ref.read(apiClientProvider).patch('/api/notifications/$id/read');
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncValue.data(current.markRead(id));
    }
  }

  Future<void> markAllRead() async {
    await ref.read(apiClientProvider).post('/api/notifications/read-all');
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncValue.data(current.markAllRead());
    }
  }
}

// Convenience provider for the unread badge count used in the nav bar.
final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationControllerProvider).valueOrNull?.unreadCount ?? 0;
});
