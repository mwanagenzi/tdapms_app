import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/inspection_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/inspection_report.dart';
import '../../models/inspection_report_item.dart';
import '../../models/inspection_photo.dart';
import '../shared/widgets/error_view.dart';
import '../shared/widgets/loading_spinner.dart';
import '../shared/widgets/section_card.dart';
import '../shared/widgets/status_badge.dart';

class InspectionDetailScreen extends ConsumerWidget {
  final int id;

  const InspectionDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inspectionDetailProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inspection Report'),
        leading: const BackButton(),
      ),
      body: state.when(
        loading: () => const LoadingSpinner(),
        error: (err, _) => ErrorView(
          message:
              err is AppException ? err.message : err.toString(),
          onRetry: () =>
              ref.read(inspectionDetailProvider(id).notifier).refresh(),
        ),
        data: (report) => RefreshIndicator(
          color: AppColors.primaryDark,
          onRefresh: () =>
              ref.read(inspectionDetailProvider(id).notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ReportHeader(report: report),
              const SizedBox(height: 16),
              ..._groupByCategory(report.items).entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _CategorySection(
                        category: entry.key,
                        items: entry.value,
                      ),
                    ),
                  ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, List<InspectionReportItem>> _groupByCategory(
      List<InspectionReportItem> items) {
    final map = <String, List<InspectionReportItem>>{};
    for (final item in items) {
      map.putIfAbsent(item.category, () => []).add(item);
    }
    return map;
  }
}

class _ReportHeader extends StatelessWidget {
  final InspectionReport report;

  const _ReportHeader({required this.report});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'REPORT INFO',
      child: Column(
        children: [
          InfoRow(label: 'Type', value: report.typeLabel),
          InfoRow(
            label: 'Status',
            value: report.isCompleted ? 'Completed' : 'Draft',
          ),
          if (report.completedAt != null)
            InfoRow(
              label: 'Completed on',
              value: formatDateTime(report.completedAt),
            ),
          if (report.conductedByName != null)
            InfoRow(label: 'Conducted by', value: report.conductedByName!),
          if (report.notes != null && report.notes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'General notes',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    report.notes!,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String category;
  final List<InspectionReportItem> items;

  const _CategorySection({required this.category, required this.items});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: category.toUpperCase(),
      padding: EdgeInsets.zero,
      child: Column(
        children: items
            .asMap()
            .entries
            .map((e) => Column(
                  children: [
                    _ItemTile(item: e.value),
                    if (e.key < items.length - 1) const Divider(height: 1),
                  ],
                ))
            .toList(),
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final InspectionReportItem item;

  const _ItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.itemName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (item.conditionBadge != null)
                StatusBadge.fromBadgeInfo(item.conditionBadge!),
            ],
          ),
          if (item.notes != null && item.notes!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              item.notes!,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
          if (item.photos.isNotEmpty) ...[
            const SizedBox(height: 10),
            _PhotoStrip(photos: item.photos),
          ],
        ],
      ),
    );
  }
}

class _PhotoStrip extends StatelessWidget {
  final List<InspectionPhoto> photos;

  const _PhotoStrip({required this.photos});

  String _url(String path) => '${AppConstants.baseUrl}/storage/$path';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final photo = photos[i];
          return GestureDetector(
            onTap: () => _openGallery(context, photos, i),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: _url(photo.path),
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  color: AppColors.border,
                  child: const Icon(Icons.image_outlined,
                      color: AppColors.disabled),
                ),
                errorWidget: (_, _, _) => Container(
                  color: AppColors.border,
                  child: const Icon(Icons.broken_image_outlined,
                      color: AppColors.disabled),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _openGallery(
      BuildContext context, List<InspectionPhoto> photos, int initial) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _PhotoGallery(photos: photos, initialIndex: initial),
    ));
  }
}

class _PhotoGallery extends StatefulWidget {
  final List<InspectionPhoto> photos;
  final int initialIndex;

  const _PhotoGallery({required this.photos, required this.initialIndex});

  @override
  State<_PhotoGallery> createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<_PhotoGallery> {
  late final PageController _ctrl;
  late int _current;

  String _url(String path) => '${AppConstants.baseUrl}/storage/$path';

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _ctrl = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_current + 1} / ${widget.photos.length}'),
      ),
      body: PageView.builder(
        controller: _ctrl,
        itemCount: widget.photos.length,
        onPageChanged: (i) => setState(() => _current = i),
        itemBuilder: (_, i) {
          final photo = widget.photos[i];
          return Column(
            children: [
              Expanded(
                child: InteractiveViewer(
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: _url(photo.path),
                      fit: BoxFit.contain,
                      placeholder: (_, _) => const LoadingSpinner(
                        color: Colors.white,
                      ),
                      errorWidget: (_, _, _) =>
                          const Icon(Icons.broken_image_outlined,
                              color: Colors.white54, size: 64),
                    ),
                  ),
                ),
              ),
              if (photo.caption != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    photo.caption!,
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
