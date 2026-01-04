import 'dart:typed_data';
import 'dart:html' as html;
import 'bill_service.dart';

class BillHelperImpl implements BillHelper {

  @override
  Future<void> sharePdf(Uint8List bytes, String filename) async {
    _download(bytes, filename);
  }

  @override
  Future<void> printPdf(Uint8List bytes) async {
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.window.open(url, '_blank');

    Future.delayed(const Duration(seconds: 2), () {
      html.Url.revokeObjectUrl(url);
    });
  }

  void _download(Uint8List bytes, String filename) {
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();

    html.Url.revokeObjectUrl(url);
  }
}
