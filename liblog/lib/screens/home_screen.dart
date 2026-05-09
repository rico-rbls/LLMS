/// lib/screens/home_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:fl_chart/fl_chart.dart';

import '../config/colors.dart';
import '../providers/auth_provider.dart';
import '../providers/resource_provider.dart';
import 'resource_detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _announcementCtrl = PageController();
  Timer? _announcementTimer;

  static const _announcements = [
    {
      'title': 'Extended Library Hours for Finals Week',
      'body': 'Read full',
    },
    {
      'title': 'New AI/ML Arrivals',
      'body': 'Read full',
    },
  ];

  static const _recommended = [
    {'id': '1', 'title': 'ACM Computing Surveys', 'author': 'Association for Computing...', 'category': 'research', 'available': true},
    {'id': '2', 'title': 'Journal of Computer Science', 'author': 'Various Authors', 'category': 'research', 'available': false},
    {'id': '1', 'title': 'Introduction to Algorithms', 'author': 'Thomas H. Cormen, C...', 'category': 'book', 'available': true},
  ];

  static const _trending = [
    {'title': 'Scientific American April 2026', 'author': 'Springer Nature', 'borrows': 142},
    {'title': 'Time Magazine Spring 2026', 'author': 'Time USA, LLC', 'borrows': 128},
    {'title': 'National Geographic March 2026', 'author': 'National Geographic Society', 'borrows': 97},
    {'title': 'ACM Computing Surveys', 'author': 'Association for Computing Machinery', 'borrows': 85},
    {'title': 'Proceedings of NeurIPS 2025', 'author': 'NeurIPS Conference', 'borrows': 76},
  ];

  @override
  void initState() {
    super.initState();
    _announcementTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      if (_announcementCtrl.hasClients) {
        int next = _announcementCtrl.page!.round() + 1;
        if (next >= _announcements.length) next = 0;
        _announcementCtrl.animateToPage(next, duration: 500.ms, curve: Curves.easeInOut);
      }
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
    const months = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'];
    const days   = ['SUNDAY','MONDAY','TUESDAY','WEDNESDAY','THURSDAY','FRIDAY','SATURDAY'];
    return '${days[now.weekday % 7]}, ${months[now.month - 1]} ${now.day}';
  }

  TextStyle _inter([TextStyle? style]) {
    return GoogleFonts.inter(textStyle: style);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final firstName = user?.fullName.split(' ').first ?? 'Juan';
    final primary = Theme.of(context).primaryColor; // Should be #652D90

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16, bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Bar ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // Streak pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF97316),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text('x5 day streak!', style: _inter(const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Notification bell
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: AppColors.border)),
                        child: Icon(Icons.notifications_outlined, color: primary, size: 20),
                      ),
                      Positioned(
                        top: -4, right: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: Text('3', style: _inter(const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  // Settings gear
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: AppColors.border)),
                    child: Icon(Icons.settings_outlined, color: primary, size: 20),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),

            // ── Greeting & Date ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_dateLabel(), style: _inter(const TextStyle(fontSize: 12, color: AppColors.mutedForeground, fontWeight: FontWeight.w600, letterSpacing: 0.5))),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: _inter(const TextStyle(fontSize: 26, color: AppColors.foreground)),
                      children: [
                        TextSpan(text: '${_greeting()} ', style: const TextStyle(fontWeight: FontWeight.w400)),
                        TextSpan(text: '$firstName!', style: const TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(9999), border: Border.all(color: Colors.green.shade100)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text('Library Open · Closes 9PM', style: _inter(const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green))),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

            // ── Announcements Carousel ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  color: AppColors.purple50,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4)),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Announcements', style: _inter(const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
                      const SizedBox(height: 12),
                      Expanded(
                        child: PageView.builder(
                          controller: _announcementCtrl,
                          itemCount: _announcements.length,
                          itemBuilder: (context, index) {
                            final a = _announcements[index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(a['title']!, style: _inter(TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primary))),
                                    ),
                                    const Icon(Icons.close_rounded, size: 16, color: AppColors.mutedForeground),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(a['body']!, style: _inter(TextStyle(fontSize: 12, color: primary, fontWeight: FontWeight.w500))),
                              ],
                            );
                          },
                        ),
                      ),
                      Center(
                        child: SmoothPageIndicator(
                          controller: _announcementCtrl,
                          count: _announcements.length,
                          effect: ExpandingDotsEffect(
                            activeDotColor: primary,
                            dotColor: AppColors.purple200,
                            dotHeight: 6, dotWidth: 6,
                            expansionFactor: 3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

            const SizedBox(height: 20),

            // ── Attendance & Reading Goal ────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 170,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Attendance', style: _inter(const TextStyle(fontSize: 14, fontWeight: FontWeight.w700))),
                          const Spacer(),
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text('5', style: _inter(const TextStyle(fontSize: 40, fontWeight: FontWeight.w800))),
                                const SizedBox(width: 4),
                                Text('visits', style: _inter(const TextStyle(fontSize: 12, color: AppColors.mutedForeground))),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('7 hours', style: _inter(const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
                              Container(width: 1, height: 12, color: AppColors.border, margin: const EdgeInsets.symmetric(horizontal: 10)),
                              Text('x5', style: _inter(const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.orange))),
                              Text(' streak', style: _inter(const TextStyle(fontSize: 11, color: AppColors.mutedForeground))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 170,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Reading Goal', style: _inter(const TextStyle(fontSize: 14, fontWeight: FontWeight.w700))),
                          const SizedBox(height: 16),
                          Expanded(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                PieChart(
                                  PieChartData(
                                    sectionsSpace: 0,
                                    centerSpaceRadius: 28,
                                    startDegreeOffset: -90,
                                    sections: [
                                      PieChartSectionData(value: 3, color: primary, radius: 8, showTitle: false),
                                      PieChartSectionData(value: 21, color: AppColors.purple50, radius: 8, showTitle: false),
                                    ],
                                  ),
                                ),
                                Text('3/24', style: _inter(TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: primary))),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: Column(
                              children: [
                                Text('21 more to go', style: _inter(const TextStyle(fontSize: 11, color: AppColors.mutedForeground))),
                                const SizedBox(height: 2),
                                Text('Change', style: _inter(TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: primary))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

            const SizedBox(height: 20),

            // ── Current Borrow ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: primary.withOpacity(0.3), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Current Borrow', style: _inter(const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(9999)),
                          child: Text('Take Home', style: _inter(TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.blue.shade700))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Introduction to Algorithms', style: _inter(const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
                              const SizedBox(height: 4),
                              Text('Thomas H. Cormen, Charles E. Leiserson', style: _inter(const TextStyle(fontSize: 12, color: AppColors.mutedForeground))),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.yellow.shade100, borderRadius: BorderRadius.circular(9999)),
                          child: Text('0 days left', style: _inter(TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.yellow.shade900))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.purple50, borderRadius: BorderRadius.circular(9999), border: Border.all(color: AppColors.border)),
                      child: Text('Computer Science', style: _inter(TextStyle(fontSize: 11, color: primary, fontWeight: FontWeight.w500))),
                    ),
                    const SizedBox(height: 16),
                    Container(height: 4, width: double.infinity, decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Borrowed 4/24/2026', style: _inter(const TextStyle(fontSize: 11, color: AppColors.mutedForeground))),
                        Text('Due 5/8/2026', style: _inter(const TextStyle(fontSize: 11, color: AppColors.mutedForeground))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {},
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('View Details', style: _inter(TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: primary))),
                            const SizedBox(width: 4),
                            Icon(Icons.chevron_right_rounded, size: 16, color: primary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 400.ms),

            const SizedBox(height: 32),

            // ── Recommended For You ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text('Recommended for You', style: _inter(const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
                  const Spacer(),
                  Text('See All', style: _inter(TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: primary))),
                  Icon(Icons.chevron_right_rounded, size: 16, color: primary),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: _recommended.length,
                itemBuilder: (_, i) {
                  final book = _recommended[i];
                  return Padding(
                    padding: EdgeInsets.only(right: i == _recommended.length - 1 ? 0 : 16),
                    child: GestureDetector(
                    onTap: () {
                      ref.read(selectedResourceIdProvider.notifier).state = book['id'] as String;
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ResourceDetailScreen()));
                    },
                    child: SizedBox(
                      width: 140,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: primary.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(16),
                                image: const DecorationImage(
                                  image: AssetImage('assets/images/covers/cover_placeholder.png'), // Will fail gracefully if missing
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  // Gradient overlay
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: LinearGradient(
                                        colors: [primary, AppColors.purple400],
                                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                                      ),
                                    ),
                                  ),
                                  Center(child: Icon(Icons.menu_book_rounded, color: Colors.white.withOpacity(0.5), size: 40)),
                                  Positioned(
                                    top: 12, left: 12, right: 12,
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                                          child: Text(book['category'] as String, style: _inter(TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: primary))),
                                        ),
                                        const Spacer(),
                                        if (i == 0 || i == 1) // "For You" star tag for some
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(4)),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.star_rounded, size: 10, color: Colors.white),
                                                const SizedBox(width: 2),
                                                Text('For You', style: _inter(const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white))),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(book['title'] as String, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: _inter(const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, height: 1.2))),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: double.infinity,
                            child: Text(book['author'] as String, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: _inter(const TextStyle(fontSize: 11, color: AppColors.mutedForeground))),
                          ),
                        ],
                      ),
                    ),
                  )).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: 400 + (i * 100)));
                },
              ),
            ),

            const SizedBox(height: 32),

            // ── Trending in Your Department ──────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text('Trending in Your Department', style: _inter(const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
                  const Spacer(),
                  Text('See All', style: _inter(TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: primary))),
                  Icon(Icons.chevron_right_rounded, size: 16, color: primary),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: List.generate(_trending.length, (i) {
                  final item = _trending[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            color: primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text('${i + 1}', style: _inter(const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white))),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['title'] as String, style: _inter(const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                              const SizedBox(height: 2),
                              Text(item['author'] as String, style: _inter(const TextStyle(fontSize: 12, color: AppColors.mutedForeground))),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${item['borrows']} borrows', style: _inter(const TextStyle(fontSize: 11, color: AppColors.mutedForeground))),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: 500 + (i * 100)));
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
