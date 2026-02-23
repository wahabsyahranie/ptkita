import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

class RepairReceiptService {
  static Future<File?> saveReceipt(Uint8List bytes) async {
    try {
      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/repair_receipt_${DateTime.now().millisecondsSinceEpoch}.png';

      final file = File(filePath);
      await file.writeAsBytes(bytes);

      return file;
    } catch (e) {
      return null;
    }
  }
}
