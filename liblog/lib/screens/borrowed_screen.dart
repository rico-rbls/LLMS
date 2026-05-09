/// lib/screens/borrowed_screen.dart — Placeholder
import 'package:flutter/material.dart';
import '../config/colors.dart';

class BorrowedScreen extends StatelessWidget {
  const BorrowedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              left: 20, right: 20, bottom: 24,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.libPurple, AppColors.purple800],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
            ),
            child: const Text('My Loans',
              style: TextStyle(color: Colors.white, fontSize: 22,
                  fontWeight: FontWeight.w700)),
          ),
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_outlined, size: 64, color: AppColors.mutedForeground),
                  SizedBox(height: 16),
                  Text('No active loans', style: TextStyle(fontSize: 16,
                      fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  Text('Coming soon', style: TextStyle(color: AppColors.mutedForeground)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
