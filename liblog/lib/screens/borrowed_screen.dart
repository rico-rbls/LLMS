/// lib/screens/borrowed_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../config/colors.dart';
import '../providers/borrow_provider.dart';

class BorrowedScreen extends ConsumerStatefulWidget {
  const BorrowedScreen({super.key});
  @override
  ConsumerState<BorrowedScreen> createState() => _BorrowedScreenState();
}

class _BorrowedScreenState extends ConsumerState<BorrowedScreen> {
  late ConfettiController _confettiCtrl;
  bool _showReturnSuccess = false;

  @override
  void initState() {
    super.initState();
    _confettiCtrl = ConfettiController(duration: const Duration(milliseconds: 800));
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    super.dispose();
  }

  void _returnBook(String id) {
    setState(() => _showReturnSuccess = true);
    _confettiCtrl.play();

    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _showReturnSuccess = false);
      ref.read(borrowProvider.notifier).returnBook(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final records = ref.watch(borrowProvider);
    final active = records.where((r) => !r.isReturned).toList();
    final history = records.where((r) => r.isReturned).toList();
    
    final overdueCount = active.where((r) => r.isOverdue).length;
    final totalFines = active.where((r) => r.isOverdue).fold<int>(0, (sum, r) => sum + (r.daysOverdue * 5));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                // Header & Tabs
                Container(
                  color: Theme.of(context).cardColor,
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('My Loans', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
                        ),
                      ),
                      TabBar(
                        labelColor: AppColors.libPurple,
                        unselectedLabelColor: AppColors.mutedForeground,
                        indicatorColor: AppColors.libPurple,
                        tabs: [
                          Tab(text: 'Active (${active.length})'),
                          Tab(text: 'History (${history.length})'),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: TabBarView(
                    children: [
                      // Active Tab
                      ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          if (overdueCount > 0) ...[
                            _buildFinesCard(totalFines, overdueCount),
                            const SizedBox(height: 20),
                          ],
                          ...active.map((r) => _buildActiveCard(r)).toList(),
                          if (active.isEmpty)
                            const Center(child: Text('No active loans')),
                        ],
                      ),
                      
                      // History Tab
                      ListView(
                        padding: const EdgeInsets.all(20),
                        children: history.map((r) => _buildHistoryCard(r)).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Success Overlay
            if (_showReturnSuccess)
              Container(
                color: Colors.white.withOpacity(0.9),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.green, size: 80)
                        .animate().scale(curve: Curves.elasticOut, duration: 600.ms),
                    const SizedBox(height: 16),
                    const Text('Book Returned!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700))
                        .animate().fadeIn(duration: 400.ms),
                  ],
                ),
              ),
              
            // Confetti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiCtrl,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: 0.05,
                numberOfParticles: 20,
                colors: const [AppColors.libPurple, Colors.green, Colors.orange, Colors.blue],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinesCard(int fines, int count) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Overdue Fines', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
                Text('₱${fines.toStringAsFixed(2)} total for $count item(s)', style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1, end: 0);
  }

  Widget _buildActiveCard(BorrowRecord r) {
    final color = r.isOverdue ? Colors.red : (r.daysUntilDue <= 3 ? Colors.orange : AppColors.libPurple);
    final badgeText = r.isOverdue ? 'Overdue ${r.daysOverdue} days' : 'Due in ${r.daysUntilDue} days';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Color Indicator
          Container(
            width: 6, height: 100,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.bookTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(r.author, style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(badgeText, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () => _returnBook(r.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.libPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Return'),
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildHistoryCard(BorrowRecord r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.bookTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(r.author, style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
              const SizedBox(width: 4),
              Text('Returned ${r.returnDate?.month}/${r.returnDate?.day}', style: const TextStyle(fontSize: 12, color: Colors.green)),
            ],
          ),
        ],
      ),
    );
  }
}
