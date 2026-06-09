import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/maintenance_request.dart';
import '../models/paginated.dart';
import '../services/api/api_client.dart';
import '../services/api/response_parser.dart';

// ---------------------------------------------------------------------------
// State wrapper for the paginated list
// ---------------------------------------------------------------------------

class MaintenanceListState {
  final List<MaintenanceRequest> items;
  final int currentPage;
  final int lastPage;
  final bool isLoadingMore;

  const MaintenanceListState({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    this.isLoadingMore = false,
  });

  bool get hasMore => currentPage < lastPage;

  MaintenanceListState copyWith({
    List<MaintenanceRequest>? items,
    int? currentPage,
    int? lastPage,
    bool? isLoadingMore,
  }) =>
      MaintenanceListState(
        items: items ?? this.items,
        currentPage: currentPage ?? this.currentPage,
        lastPage: lastPage ?? this.lastPage,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );
}

// ---------------------------------------------------------------------------
// Maintenance list — handles plain list OR paginated response
// ---------------------------------------------------------------------------

final maintenanceControllerProvider =
    AsyncNotifierProvider<MaintenanceController, MaintenanceListState>(
        MaintenanceController.new);

class MaintenanceController extends AsyncNotifier<MaintenanceListState> {
  @override
  Future<MaintenanceListState> build() => _fetchPage(1);

  Future<MaintenanceListState> _fetchPage(int page) async {
    final raw = await ref.read(apiClientProvider).get(
          '/api/maintenance',
          params: {'page': page},
        );

    // normalisePaginated handles: plain [], {"data":[],...}, paginator Map.
    final normalised = normalisePaginated(raw);
    final paged = Paginated.fromJson(normalised, MaintenanceRequest.fromJson);

    return MaintenanceListState(
      items: paged.data,
      currentPage: paged.currentPage,
      lastPage: paged.lastPage,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPage(1));
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncValue.data(current.copyWith(isLoadingMore: true));

    try {
      final next = await _fetchPage(current.currentPage + 1);
      state = AsyncValue.data(
        MaintenanceListState(
          items: [...current.items, ...next.items],
          currentPage: next.currentPage,
          lastPage: next.lastPage,
        ),
      );
    } catch (_) {
      state = AsyncValue.data(current.copyWith(isLoadingMore: false));
    }
  }
}

// ---------------------------------------------------------------------------
// Maintenance detail (with update log)
// ---------------------------------------------------------------------------

final maintenanceDetailProvider = AsyncNotifierProvider.family<
    MaintenanceDetailController,
    MaintenanceRequest,
    int>(MaintenanceDetailController.new);

class MaintenanceDetailController
    extends FamilyAsyncNotifier<MaintenanceRequest, int> {
  @override
  Future<MaintenanceRequest> build(int arg) => _fetch(arg);

  Future<MaintenanceRequest> _fetch(int id) async {
    final raw =
        await ref.read(apiClientProvider).get('/api/maintenance/$id');
    final map = raw is Map && raw.containsKey('data') && raw['data'] is Map
        ? raw['data'] as Map<String, dynamic>
        : raw as Map<String, dynamic>;
    return MaintenanceRequest.fromJson(map);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch(arg));
  }
}

// ---------------------------------------------------------------------------
// Submit new maintenance request
// ---------------------------------------------------------------------------

final submitMaintenanceProvider =
    AsyncNotifierProvider<SubmitMaintenanceController, void>(
        SubmitMaintenanceController.new);

class SubmitMaintenanceController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> submit({
    required String title,
    required String description,
    required String priority,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(apiClientProvider).post('/api/maintenance', body: {
        'title': title.trim(),
        'description': description.trim(),
        'priority': priority,
      });
      ref.invalidate(maintenanceControllerProvider);
    });
  }
}
