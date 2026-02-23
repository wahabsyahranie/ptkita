import 'package:cloud_firestore/cloud_firestore.dart';

class Formatters {
  /// Format tanggal menjadi: 18 Februari 2026
  static String formatDate(dynamic value) {
    if (value == null) return '-';

    DateTime date;

    if (value is Timestamp) {
      date = value.toDate();
    } else if (value is DateTime) {
      date = value;
    } else {
      return value.toString();
    }

    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${date.day.toString().padLeft(2, '0')} '
        '${months[date.month - 1]} '
        '${date.year}';
  }

  /// Format angka ke Rupiah (Rp 66.666)
  static String formatRupiah(int value) {
    final reversed = value.toString().split('').reversed.toList();
    final parts = <String>[];

    for (var i = 0; i < reversed.length; i += 3) {
      parts.add(reversed.skip(i).take(3).toList().reversed.join());
    }

    return 'Rp ${parts.reversed.join('.')}';
  }

  /// Format input user supaya otomatis jadi format ribuan
  static String formatRupiahInput(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';

    final number = int.parse(digits);
    return formatRupiah(number).replaceFirst('Rp ', '');
  }
}
