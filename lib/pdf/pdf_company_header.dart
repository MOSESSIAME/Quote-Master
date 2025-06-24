import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;

pw.Widget buildCompanyHeader(Uint8List logoBytes) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(vertical: 12),
    alignment: pw.Alignment.center,
    child: pw.Image(
      pw.MemoryImage(logoBytes),
      height: 80, // Adjust as needed
      fit: pw.BoxFit.contain,
    ),
  );
}