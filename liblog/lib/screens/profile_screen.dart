/// lib/screens/profile_screen.dart — Placeholder
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/colors.dart';
import '../providers/auth_provider.dart';
import '../utils/auth.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final initials = user != null ? getAvatarInitials(user.fullName) : '?';

    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              left: 20, right: 20, bottom: 32,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.libPurple, AppColors.purple800],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
            ),
            child: Column(children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(initials, style: const TextStyle(
                    color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 12),
              Text(user?.fullName ?? 'Guest',
                style: const TextStyle(color: Colors.white, fontSize: 18,
                    fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(user?.email ?? '',
                style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(user?.role.toUpperCase() ?? '',
                  style: const TextStyle(color: Colors.white, fontSize: 12,
                      fontWeight: FontWeight.w600)),
              ),
            ]),
          ),
          const Expanded(
            child: Center(
              child: Text('Full profile coming soon',
                style: TextStyle(color: AppColors.mutedForeground)),
            ),
          ),
        ],
      ),
    );
  }
}
