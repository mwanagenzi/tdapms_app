import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/inspection_report.dart';
import '../services/api/api_client.dart';

// ---------------------------------------------------------------------------
// Inspections list
// ---------------------------------------------------------------------------

final inspectionsControllerProvider =
    AsyncNotifierProvider<InspectionsController, List<InspectionReport>>(
        InspectionsController.new);

class InspectionsController extends AsyncNotifier<List<InspectionReport>> {
  @override
  Future<List<InspectionReport>> build() => _fetch();

  Future<List<InspectionReport>> _fetch() async {
    final data =
        await ref.read(apiClientProvider).get('/api/inspections') as List;
    return data
        .map((e) => InspectionReport.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }
}

// ---------------------------------------------------------------------------
// Inspection detail (with items and photos)
// ---------------------------------------------------------------------------

final inspectionDetailProvider = AsyncNotifierProvider.family<
    InspectionDetailController,
    InspectionReport,
    int>(InspectionDetailController.new);

class InspectionDetailController
    extends FamilyAsyncNotifier<InspectionReport, int> {
  @override
  Future<InspectionReport> build(int arg) => _fetch(arg);

  Future<InspectionReport> _fetch(int id) async {
    final data = await ref
        .read(apiClientProvider)
        .get('/api/inspections/$id') as Map<String, dynamic>;
    return InspectionReport.fromJson(data);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch(arg));
  }
}
