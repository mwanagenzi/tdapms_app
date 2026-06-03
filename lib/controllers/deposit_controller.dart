import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/deposit.dart';
import '../services/api/api_client.dart';

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
    final data =
        await ref.read(apiClientProvider).get('/api/deposits') as List;
    return data
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
    final data = await ref
        .read(apiClientProvider)
        .get('/api/deposits/$id') as Map<String, dynamic>;
    return Deposit.fromJson(data);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch(arg));
  }
}
