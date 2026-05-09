/// lib/screens/home_screen.dart
/// Dashboard: greeting, streak, announcements carousel, current borrow, recommendations.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/colors.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _announcementCtrl = PageController();
  Timer? _announcementTimer;
  int _announcementIndex = 0;
  bool _libraryOpen = true;

  static const _announcements = [
    {'title': 'Extended Hours for Finals Week',
     'body': 'The library will be open until 10 PM from May 12–20.',
     'icon': '📢'},
    {'title': 'New AI/ML Arrivals',
     'body': '5 new titles on Machine Learning are now available!',
     'icon': '🆕'},
  ];

  static const _recommended = [
    {'title': 'Clean Code',           'author': 'R. Martin',    'available': true},
    {'title': 'Deep Learning',        'author': 'Goodfellow',   'available': false},
    {'title': 'Design Patterns',      'author': 'GoF',          'available': true},
    {'title': 'The Pragmatic Programmer', 'author': 'Hunt',     'available': true},
  ];

  static const _trending = [
    {'title': 'Introduction to Algorithms', 'borrows': 23},
    {'title': 'Clean Code',                 'borrows': 18},
    {'title': 'Deep Learning',              'borrows': 15},
    {'title': 'Database System Concepts',   'borrows': 12},
    {'title': 'Design Patterns',            'borrows': 9},
  ];

  @override
  void initState() {
    super.initState();
    _announcementTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      setState(() {
        _announcementIndex =
            (_announcementIndex + 1) % _announcements.length;
      });
      _announcementCtrl.animateToPage(_announcementIndex,
          duration: 500.ms, curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _announcementTimer?.cancel();
    _announcementCtrl.dispose();
    super.dispose();
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning,';
    if (h < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  String _dateLabel() {
    final now = DateTime.now();
    const months = ['JAN','FEB','MAR','APR','MAY','JUN',
                    'JUL','AUG','SEP','OCT','NOV','DEC'];
    const days   = ['SUNDAY','MONDAY','TUESDAY','WEDNESDAY',
                    'THURSDAY','FRIDAY','SATURDAY'];
    return '${days[now.weekday % 7]}, ${months[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final firstName = user?.fullName.split(' ').first ?? 'there';

    return RefreshIndicator(
      onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
      color: AppColors.libPurple,
      child: ListView(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            bottom: 24),
        children: [
          // ── Top Bar ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                // Streak pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF97316),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Text('🔥', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text('${user?.streakCount ?? 0} day streak',
                      style: const TextStyle(color: Colors.white,
                          fontSize: 12, fontWeight: FontWeight.w600)),
                  ]),
                ),
                const Spacer(),
                // Notification bell
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.notifications_none_rounded,
                      color: AppColors.foreground, size: 20),
                ),
                const SizedBox(width: 8),
                // Settings gear
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.settings_outlined,
                      color: AppColors.foreground, size: 20),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),

          // ── Greeting ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_dateLabel(),
                  style: const TextStyle(fontSize: 11,
                      color: AppColors.mutedForeground,
                      fontWeight: FontWeight.w500, letterSpacing: 0.5)),
                const SizedBox(height: 6),
                // Split-weight greeting per FEATURES.md §2.3
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 24, color: AppColors.foreground),
                    children: [
                      TextSpan(text: '${_greeting()} ',
                        style: const TextStyle(fontWeight: FontWeight.w400)),
                      TextSpan(text: '$firstName!',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                if (user != null && user.program != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text('${user.program} · ${user.yearLevel ?? user.role}',
                      style: const TextStyle(fontSize: 13,
                          color: AppColors.mutedForeground)),
                  ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 80.ms),

          // ── Library Status ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(children: [
                // Pulsing green dot
                _libraryOpen
                  ? Container(
                      width: 10, height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.green),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(begin: const Offset(1, 1), end: const Offset(1.4, 1.4),
                           duration: 2000.ms)
                  : Container(width: 10, height: 10,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.red)),
                const SizedBox(width: 8),
                Text(_libraryOpen ? 'Library is Open' : 'Library is Closed',
                  style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13,
                    color: _libraryOpen ? Colors.green : Colors.red)),
                const Spacer(),
                Text(_libraryOpen ? 'Closes at 9:00 PM' : 'Opens at 7:00 AM',
                  style: const TextStyle(fontSize: 12,
                      color: AppColors.mutedForeground)),
              ]),
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 120.ms),

          const SizedBox(height: 20),

          // ── Announcements Carousel ─────────────────────────────────────
          _SectionHeader(title: 'Announcements', icon: Icons.campaign_rounded)
              .animate().fadeIn(duration: 400.ms, delay: 160.ms),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: PageView.builder(
                  controller: _announcementCtrl,
                  onPageChanged: (i) => setState(() => _announcementIndex = i),
                  itemCount: _announcements.length,
                  itemBuilder: (_, i) {
                    final a = _announcements[i];
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(children: [
                        Text(a['icon']!, style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(a['title']!, maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 13)),
                            const SizedBox(height: 3),
                            Text(a['body']!, maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12,
                                  color: AppColors.mutedForeground)),
                          ],
                        )),
                      ]),
                    );
                  },
                ),
              ),
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 160.ms),
          const SizedBox(height: 8),
          // Dot indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_announcements.length, (i) =>
              AnimatedContainer(
                duration: 200.ms,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _announcementIndex ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: i == _announcementIndex
                      ? AppColors.libPurple
                      : AppColors.border,
                ),
              )),
          ),
          const SizedBox(height: 20),

          // ── Current Borrow ─────────────────────────────────────────────
          _SectionHeader(title: 'Current Borrow', icon: Icons.bookmark_rounded)
              .animate().fadeIn(duration: 400.ms, delay: 200.ms),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(children: [
                // Animated gradient left border
                Container(
                  width: 4, height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: const LinearGradient(
                      colors: [AppColors.libPurple, AppColors.purple300],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                )
                  .animate()
                  .scaleY(begin: 0, end: 1, duration: 600.ms,
                          curve: Curves.easeOut),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Introduction to Algorithms',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      const Text('Cormen et al.',
                        style: TextStyle(fontSize: 12,
                            color: AppColors.mutedForeground)),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: 0.6,
                          backgroundColor: AppColors.purple100,
                          color: AppColors.libPurple,
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(children: [
                        const Text('Due in',
                          style: TextStyle(fontSize: 11,
                              color: AppColors.mutedForeground)),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.purple50,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: const Text('6 days',
                            style: TextStyle(fontSize: 11,
                                color: AppColors.libPurple,
                                fontWeight: FontWeight.w600)),
                        ),
                      ]),
                    ],
                  ),
                ),
              ]),
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

          const SizedBox(height: 20),

          // ── Recommended For You ──────────────────────────────────────
          _SectionHeader(title: 'Recommended For You', icon: Icons.auto_awesome_rounded)
              .animate().fadeIn(duration: 400.ms, delay: 240.ms),
          const SizedBox(height: 10),
          SizedBox(
            height: 160,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: _recommended.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final book = _recommended[i];
                return Container(
                  width: 110,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16)),
                        child: Container(
                          height: 90, width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.purple200,
                                AppColors.libPurple.withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Icon(Icons.menu_book_rounded,
                              color: Colors.white, size: 36),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(book['title'] as String,
                              maxLines: 2, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Row(children: [
                              Container(
                                width: 6, height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: (book['available'] as bool)
                                      ? Colors.green : Colors.red,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  (book['available'] as bool)
                                      ? 'Available' : 'Unavail.',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: (book['available'] as bool)
                                        ? Colors.green : Colors.red),
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(
                    duration: 300.ms, delay: Duration(milliseconds: 260 + i * 60));
              },
            ),
          ),

          const SizedBox(height: 20),

          // ── Trending in Your Department ──────────────────────────────
          _SectionHeader(title: 'Trending', icon: Icons.trending_up_rounded)
              .animate().fadeIn(duration: 400.ms, delay: 300.ms),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: List.generate(_trending.length, (i) {
                  final item = _trending[i];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 2),
                    leading: Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: i == 0 ? AppColors.libPurple : AppColors.purple50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text('${i + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 12,
                            color: i == 0 ? Colors.white : AppColors.libPurple)),
                      ),
                    ),
                    title: Text(item['title'] as String,
                      style: const TextStyle(fontSize: 13,
                          fontWeight: FontWeight.w600)),
                    trailing: Text('${item['borrows']} borrows',
                      style: const TextStyle(fontSize: 11,
                          color: AppColors.mutedForeground)),
                  );
                }),
              ),
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(children: [
        Text(title, style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w700)),
        const Spacer(),
        Icon(icon, color: AppColors.libPurple, size: 20),
      ]),
    );
  }
}
