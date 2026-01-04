import 'dart:typed_data';
import 'package:printing/printing.dart';
import 'bill_service.dart';

class BillHelperImpl implements BillHelper {

  @override
  Future<void> sharePdf(Uint8List bytes, String filename) async {
    await Printing.sharePdf(
      bytes: bytes,
      filename: filename,
    );
  }

  @override
  Future<void> printPdf(Uint8List bytes) async {
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
    );
  }
}
