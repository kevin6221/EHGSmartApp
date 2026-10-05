import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

/// Represents a distinct hydration fluid intake entry with date and timestamp.
class HydrationRecord extends Equatable {
  final String id;
  final int amountMl;
  final DateTime timestamp;
  final String dateKey; // 'yyyy-MM-dd'

  const HydrationRecord({
    required this.id,
    required this.amountMl,
    required this.timestamp,
    required this.dateKey,
  });

  /// Formats time in standard 12-hour AM/PM format (e.g. "10:30 AM").
  String get timeFormatted {
    final h = timestamp.hour;
    final m = timestamp.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$h12:$m $period';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'amountMl': amountMl,
    'timestamp': timestamp.millisecondsSinceEpoch,
    'dateKey': dateKey,
  };

  factory HydrationRecord.fromJson(Map<String, dynamic> json) {
    final ts = (json['timestamp'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch;
    final date = DateTime.fromMillisecondsSinceEpoch(ts);
    return HydrationRecord(
      id: json['id'] as String? ?? '${date.millisecondsSinceEpoch}_${json['amountMl']}',
      amountMl: (json['amountMl'] as num?)?.toInt() ?? 0,
      timestamp: date,
      dateKey: json['dateKey'] as String? ?? DateFormat('yyyy-MM-dd').format(date),
    );
  }

  @override
  List<Object?> get props => [id, amountMl, timestamp, dateKey];
}
