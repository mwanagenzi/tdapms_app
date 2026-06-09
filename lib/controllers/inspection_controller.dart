import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/inspection_report.dart';
import '../services/api/api_client.dart';
import '../services/api/response_parser.dart';

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
    final raw = await ref.read(apiClientProvider).get('/api/inspections');
    // Handles both [] and {"data": [...]} response shapes.
    return extractList(raw)
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
    final raw =
        await ref.read(apiClientProvider).get('/api/inspections/$id');
    // Detail may be wrapped {"data": {...}} or returned directly.
    final map = raw is Map && raw.containsKey('data') && raw['data'] is Map
        ? raw['data'] as Map<String, dynamic>
        : raw as Map<String, dynamic>;
    return InspectionReport.fromJson(map);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch(arg));
  }
}
