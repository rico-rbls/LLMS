/// lib/screens/qr_scan_screen.dart — Placeholder
import 'package:flutter/material.dart';
import '../config/colors.dart';

class QrScanScreen extends StatelessWidget {
  const QrScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0d0d1a),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.libPurple, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.qr_code_scanner,
                  color: AppColors.libPurple, size: 80),
            ),
            const SizedBox(height: 24),
            const Text('QR Scanner',
              style: TextStyle(color: Colors.white, fontSize: 20,
                  fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('Coming soon',
              style: TextStyle(color: Colors.white54, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
