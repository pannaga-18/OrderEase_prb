import 'dart:typed_data';

abstract class BillHelper {
  Future<void> sharePdf(Uint8List bytes, String filename);
  Future<void> printPdf(Uint8List bytes);
}
