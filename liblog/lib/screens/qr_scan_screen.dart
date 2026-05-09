/// lib/screens/qr_scan_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/colors.dart';
import '../providers/attendance_provider.dart';

class QrScanScreen extends ConsumerStatefulWidget {
  const QrScanScreen({super.key});
  @override
  ConsumerState<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends ConsumerState<QrScanScreen> with SingleTickerProviderStateMixin {
  late AnimationController _scanCtrl;
  Timer? _simTimer;
  bool _isScanning = false;
  bool _isSuccess = false;
  String _mode = 'attendance'; // attendance or checkout

  @override
  void initState() {
    super.initState();
    _scanCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _simTimer?.cancel();
    _scanCtrl.dispose();
    super.dispose();
  }

  void _startScan() {
    setState(() {
      _isScanning = true;
      _isSuccess = false;
    });
    _scanCtrl.repeat(reverse: true);

    _simTimer?.cancel();
    // 5-second simulated sequence (2s wait -> 3s scan -> success)
    _simTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      _scanCtrl.stop();
      setState(() {
        _isScanning = false;
        _isSuccess = true;
      });
      if (_mode == 'attendance') {
        ref.read(attendanceProvider.notifier).logAttendance();
      }
      _showSuccessModal();
    });
  }

  void _showSuccessModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64, height: 64,
              decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 40),
            ).animate().scale(curve: Curves.elasticOut, duration: 800.ms),
            const SizedBox(height: 16),
            Text(
              _mode == 'attendance' ? 'Attendance Logged!' : 'Checkout Successful!',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              '${DateTime.now().toLocal()}'.split('.')[0],
              style: const TextStyle(color: AppColors.mutedForeground),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() => _isSuccess = false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.libPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0d0d1a), // Explicit dark background
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Scanner', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      _mode == 'attendance' ? 'Attendance' : 'Checkout',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            
            const Spacer(),

            // Viewfinder
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Bounds
                  Container(
                    width: 256, height: 256,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  // Corners
                  ..._buildCorners(),
                  
                  // Scan Line Animation
                  if (_isScanning)
                    AnimatedBuilder(
                      animation: _scanCtrl,
                      builder: (ctx, child) => Positioned(
                        top: _scanCtrl.value * 250,
                        child: Container(
                          width: 256, height: 4,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.transparent, AppColors.libPurpleLight, Colors.transparent],
                            ),
                            boxShadow: [BoxShadow(color: AppColors.libPurple.withOpacity(0.5), blurRadius: 8)],
                          ),
                        ),
                      ),
                    ),

                  // Center Icon / Action
                  if (!_isScanning && !_isSuccess)
                    GestureDetector(
                      onTap: _startScan,
                      child: Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.libPurple.withOpacity(0.8),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: AppColors.libPurple.withOpacity(0.4), blurRadius: 16)],
                        ),
                        child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 36),
                      ),
                    ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1,1), end: const Offset(1.1, 1.1), duration: 1.seconds),
                ],
              ),
            ),
            
            const Spacer(),

            // Status Text
            Text(
              _isScanning ? 'Hold steady...' : 'Tap center to simulate scan',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 15),
            ),

            const SizedBox(height: 40),

            // Mode Toggle
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(child: _buildModeBtn('Attendance', 'attendance')),
                  Expanded(child: _buildModeBtn('Checkout', 'checkout')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeBtn(String label, String value) {
    final active = _mode == value;
    return GestureDetector(
      onTap: () => setState(() => _mode = value),
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? AppColors.libPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.white.withOpacity(0.5),
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCorners() {
    return [
      Positioned(top: -2, left: -2, child: _corner(top: true, left: true)),
      Positioned(top: -2, right: -2, child: _corner(top: true, left: false)),
      Positioned(bottom: -2, left: -2, child: _corner(top: false, left: true)),
      Positioned(bottom: -2, right: -2, child: _corner(top: false, left: false)),
    ];
  }

  Widget _corner({required bool top, required bool left}) {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        border: Border(
          top: top ? const BorderSide(color: AppColors.libPurple, width: 4) : BorderSide.none,
          bottom: !top ? const BorderSide(color: AppColors.libPurple, width: 4) : BorderSide.none,
          left: left ? const BorderSide(color: AppColors.libPurple, width: 4) : BorderSide.none,
          right: !left ? const BorderSide(color: AppColors.libPurple, width: 4) : BorderSide.none,
        ),
        borderRadius: BorderRadius.only(
          topLeft: top && left ? const Radius.circular(24) : Radius.zero,
          topRight: top && !left ? const Radius.circular(24) : Radius.zero,
          bottomLeft: !top && left ? const Radius.circular(24) : Radius.zero,
          bottomRight: !top && !left ? const Radius.circular(24) : Radius.zero,
        ),
      ),
    );
  }
}
