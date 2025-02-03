import 'package:flutter/material.dart';
import 'package:kokiku/constants/services/localization_service.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerPage extends StatefulWidget {
  final Function(String) onScan;

  const QrScannerPage({super.key, required this.onScan});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  bool hasScanned = false;

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationService.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(localization.translate('scan_qr_code'))),
      body: MobileScanner(
        onDetect: (capture) {
          if (hasScanned) return; // Prevent further scans

          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            String scannedCode = barcodes.first.rawValue ?? "";
            widget.onScan(scannedCode);

            // Set flag to true to prevent further scans
            setState(() {
              hasScanned = true;
            });

            // Optionally, close the scanner after successful scan
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
