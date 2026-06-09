import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/deposit.dart';
import '../services/api/api_client.dart';
import '../services/api/response_parser.dart';

// ---------------------------------------------------------------------------
// Deposits list
// ---------------------------------------------------------------------------

final depositsControllerProvider =
    AsyncNotifierProvider<DepositsController, List<Deposit>>(
        DepositsController.new);

class DepositsController extends AsyncNotifier<List<Deposit>> {
  @override
  Future<List<Deposit>> build() => _fetch();

  Future<List<Deposit>> _fetch() async {
    final raw = await ref.read(apiClientProvider).get('/api/deposits');
    // Handles both [] and {"data": [...]} response shapes.
    return extractList(raw)
        .map((e) => Deposit.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }
}

// ---------------------------------------------------------------------------
// Deposit detail (with escrow transactions + deductions)
// ---------------------------------------------------------------------------

final depositDetailProvider = AsyncNotifierProvider.family<
    DepositDetailController, Deposit, int>(DepositDetailController.new);

class DepositDetailController extends FamilyAsyncNotifier<Deposit, int> {
  @override
  Future<Deposit> build(int arg) => _fetch(arg);

  Future<Deposit> _fetch(int id) async {
    final raw = await ref.read(apiClientProvider).get('/api/deposits/$id');
    // Detail may be wrapped in {"data": {...}} or returned directly.
    final map = raw is Map && raw.containsKey('data') && raw['data'] is Map
        ? raw['data'] as Map<String, dynamic>
        : raw as Map<String, dynamic>;
    return Deposit.fromJson(map);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch(arg));
  }
}
