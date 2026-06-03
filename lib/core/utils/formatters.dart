import 'package:intl/intl.dart';

final _currencyFmt = NumberFormat.currency(
  locale: 'en_KE',
  symbol: 'KES ',
  decimalDigits: 2,
);

final _dateFmt = DateFormat('dd MMM yyyy');
final _dateTimeFmt = DateFormat('dd MMM yyyy, h:mm a');
final _timeFmt = DateFormat('h:mm a');

String formatCurrency(num? amount) {
  if (amount == null) return 'KES —';
  return _currencyFmt.format(amount);
}

String formatDate(String? iso) {
  if (iso == null || iso.isEmpty) return '—';
  try {
    return _dateFmt.format(DateTime.parse(iso).toLocal());
  } catch (_) {
    return iso;
  }
}

String formatDateTime(String? iso) {
  if (iso == null || iso.isEmpty) return '—';
  try {
    return _dateTimeFmt.format(DateTime.parse(iso).toLocal());
  } catch (_) {
    return iso;
  }
}

String formatTime(String? iso) {
  if (iso == null || iso.isEmpty) return '—';
  try {
    return _timeFmt.format(DateTime.parse(iso).toLocal());
  } catch (_) {
    return iso;
  }
}

/// Returns a human-readable relative label e.g. "2 hours ago", "Yesterday".
String timeAgo(String? iso) {
  if (iso == null || iso.isEmpty) return '—';
  try {
    final dt = DateTime.parse(iso).toLocal();
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return formatDate(iso);
  } catch (_) {
    return iso;
  }
}
