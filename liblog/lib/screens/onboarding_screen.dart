/// lib/screens/onboarding_screen.dart
/// 5-step registration wizard with draft persistence and confetti on final step.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/colors.dart';
import '../providers/auth_provider.dart';
import '../providers/store_provider.dart';
import '../utils/auth_utils.dart';
import '../utils/auth.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageCtrl = PageController();
  late final ConfettiController _confetti;

  int _step = 0;

  // Step 1: Role Selection
  String _role = 'student';
  static const _roles = ['student', 'faculty', 'visitor', 'librarian'];
  static const _roleLabels = {
    'student': 'Student',
    'faculty': 'Faculty',
    'visitor': 'Visitor',
    'librarian': 'Librarian'
  };
  static const _roleIcons = {
    'student': Icons.school_outlined,
    'faculty': Icons.work_outline,
    'visitor': Icons.person_outline,
    'librarian': Icons.local_library_outlined,
  };

  // Step 2: Personal Info
  final _fullNameCtrl = TextEditingController();
  final _uniIdCtrl = TextEditingController();

  // Step 3: Academic Info
  String? _selectedProgram;
  String? _selectedYear;
  static const _programs = [
    'BS Computer Science',
    'BS Information Technology',
    'BS Architecture',
    'AB Communication',
  ];
  static const _years = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
    '5th Year',
  ];

  // Step 4: Account Setup
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;

  // Step 5: Preferences
  bool _notifDue = true;
  bool _notifReserv = true;
  bool _notifAnnounce = false;

  final _stepTitles = [
    'Choose Your Role',
    'Personal Information',
    'Academic Information',
    'Account Setup',
    'Preferences',
  ];

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));

    // Rehydrate draft from storage
    final storage = ref.read(storageServiceProvider);
    final savedStep = storage.loadOnboardingStep();
    final savedData = storage.loadOnboardingData();
    if (savedData.isNotEmpty) {
      _role = savedData['role'] ?? 'student';
      _fullNameCtrl.text = savedData['fullName'] ?? '';
      _uniIdCtrl.text = savedData['universityId'] ?? '';
      _selectedProgram = savedData['program'];
      _selectedYear = savedData['yearLevel'];
      _emailCtrl.text = savedData['email'] ?? '';
      _step = savedStep;
      // We don't restore password for security
    }
  }

  @override
  void dispose() {
    _confetti.dispose();
    _pageCtrl.dispose();
    _fullNameCtrl.dispose();
    _uniIdCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _persistDraft() {
    final storage = ref.read(storageServiceProvider);
    storage.saveOnboardingStep(_step);
    storage.saveOnboardingData({
      'role': _role,
      'fullName': _fullNameCtrl.text,
      'universityId': _uniIdCtrl.text,
      'program': _selectedProgram ?? '',
      'yearLevel': _selectedYear ?? '',
      'email': _emailCtrl.text,
    });
  }

  bool _canContinue() {
    switch (_step) {
      case 0:
        return _role.isNotEmpty;
      case 1:
        return _fullNameCtrl.text.trim().isNotEmpty && _uniIdCtrl.text.trim().isNotEmpty;
      case 2:
        if (_role == 'visitor') return true;
        return _selectedProgram != null && _selectedYear != null;
      case 3:
        return _emailCtrl.text.contains('@') &&
               _passwordCtrl.text.length >= 6 &&
               _passwordCtrl.text == _confirmPasswordCtrl.text;
      case 4:
        return true;
      default:
        return false;
    }
  }

  void _next() {
    if (!_canContinue()) return;
    _persistDraft();
    if (_step == 4) {
      _submit();
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _step++);
    _pageCtrl.animateToPage(_step, duration: 300.ms, curve: Curves.easeInOut);
    if (_step == 4) _confetti.play();
  }

  void _back() {
    FocusScope.of(context).unfocus();
    if (_step == 0) {
      Navigator.pop(context);
      return;
    }
    setState(() => _step--);
    _pageCtrl.animateToPage(_step, duration: 300.ms, curve: Curves.easeInOut);
  }

  Future<void> _submit() async {
    final userData = {
      'role': _role,
      'fullName': _fullNameCtrl.text.trim(),
      'universityId': _uniIdCtrl.text.trim(),
      'program': _selectedProgram ?? '',
      'yearLevel': _selectedYear ?? '',
      'email': _emailCtrl.text.trim(),
      'password': AuthUtils.hashPassword(_passwordCtrl.text),
      'avatarInitials': getAvatarInitials(_fullNameCtrl.text.trim()),
      'notificationDueDate': _notifDue,
      'notificationReservation': _notifReserv,
      'notificationAnnouncements': _notifAnnounce,
    };
    await ref.read(authProvider.notifier).register(userData);
    if (mounted) {
      // Clear draft on successful registration
      ref.read(storageServiceProvider).saveOnboardingStep(0);
      ref.read(storageServiceProvider).saveOnboardingData({});
      Navigator.pop(context);
    }
  }

  // ── Step pages ──────────────────────────────────────────────────────────

  Widget _buildStep1() => _StepPage(
        title: 'Choose Your Role',
        subtitle: 'How will you be using LibLog?',
        child: Column(
          children: _roles.map((role) {
            final selected = _role == role;
            return GestureDetector(
              onTap: () => setState(() => _role = role),
              child: AnimatedContainer(
                duration: 200.ms,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? AppColors.libPurple : AppColors.border,
                    width: selected ? 2 : 1,
                  ),
                  color: selected ? AppColors.purple50 : Colors.white,
                ),
                child: Row(
                  children: [
                    Icon(_roleIcons[role], color: selected ? AppColors.libPurple : AppColors.mutedForeground),
                    const SizedBox(width: 16),
                    Text(
                      _roleLabels[role]!,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: selected ? AppColors.libPurple : AppColors.foreground,
                      ),
                    ),
                    const Spacer(),
                    if (selected) const Icon(Icons.check_circle, color: AppColors.libPurple),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      );

  Widget _buildStep2() => _StepPage(
        title: 'Personal Information',
        subtitle: 'Let us know who you are',
        child: Column(
          children: [
            _field('Full Name', _fullNameCtrl, Icons.person_outline, onChanged: (_) => setState(() {})),
            const SizedBox(height: 16),
            _field('University ID', _uniIdCtrl, Icons.badge_outlined, onChanged: (_) => setState(() {})),
          ],
        ),
      );

  Widget _buildStep3() => _StepPage(
        title: 'Academic Information',
        subtitle: _role == 'visitor' ? 'Not required for visitors' : 'Tell us about your studies',
        child: _role == 'visitor'
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Icon(Icons.check_circle_outline, size: 64, color: AppColors.libPurple),
                ),
              )
            : Column(
                children: [
                  _dropdown('Program / Department', _selectedProgram, _programs, (val) => setState(() => _selectedProgram = val)),
                  const SizedBox(height: 16),
                  _dropdown('Year Level', _selectedYear, _years, (val) => setState(() => _selectedYear = val)),
                ],
              ),
      );

  Widget _buildStep4() => _StepPage(
        title: 'Account Setup',
        subtitle: 'Create your login credentials',
        child: Column(
          children: [
            _field('Email', _emailCtrl, Icons.email_outlined, type: TextInputType.emailAddress, onChanged: (_) => setState(() {})),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscure,
              style: GoogleFonts.inter(color: AppColors.foreground),
              decoration: _passwordDecoration('Password', _obscure, () => setState(() => _obscure = !_obscure)),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordCtrl,
              obscureText: _obscureConfirm,
              style: GoogleFonts.inter(color: AppColors.foreground),
              decoration: _passwordDecoration('Confirm Password', _obscureConfirm, () => setState(() => _obscureConfirm = !_obscureConfirm)),
              onChanged: (_) => setState(() {}),
            ),
            if (_passwordCtrl.text.isNotEmpty && _confirmPasswordCtrl.text.isNotEmpty && _passwordCtrl.text != _confirmPasswordCtrl.text)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: Text('Passwords do not match', style: GoogleFonts.inter(color: Colors.red, fontSize: 12)),
              ),
          ],
        ),
      );

  Widget _buildStep5() => _StepPage(
        title: 'Preferences',
        subtitle: 'Customize your notification alerts',
        child: Column(
          children: [
            _toggle('Due Date Reminders', 'Get notified before your books are due', _notifDue, (v) => setState(() => _notifDue = v)),
            const SizedBox(height: 12),
            _toggle('Reservation Alerts', 'Know when reserved items are ready', _notifReserv, (v) => setState(() => _notifReserv = v)),
            const SizedBox(height: 12),
            _toggle('System Announcements', 'Library news, events, and updates', _notifAnnounce, (v) => setState(() => _notifAnnounce = v)),
          ],
        ),
      );

  // ── Helpers ─────────────────────────────────────────────────────────────

  static Widget _field(String label, TextEditingController ctrl, IconData icon, {TextInputType? type, void Function(String)? onChanged}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      onChanged: onChanged,
      style: GoogleFonts.inter(color: AppColors.foreground),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: AppColors.mutedForeground),
        prefixIcon: Icon(icon, color: AppColors.mutedForeground),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.libPurple, width: 2)),
      ),
    );
  }

  static Widget _dropdown(String label, String? value, List<String> items, void Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.inter()))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: AppColors.mutedForeground),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.libPurple, width: 2)),
      ),
    );
  }

  static InputDecoration _passwordDecoration(String label, bool obscure, VoidCallback toggle) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(color: AppColors.mutedForeground),
      prefixIcon: const Icon(Icons.lock_outline, color: AppColors.mutedForeground),
      suffixIcon: IconButton(
        icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.mutedForeground),
        onPressed: toggle,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.libPurple, width: 2)),
    );
  }

  static Widget _toggle(String title, String sub, bool value, void Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.foreground)),
                const SizedBox(height: 4),
                Text(sub, style: GoogleFonts.inter(color: AppColors.mutedForeground, fontSize: 13)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.libPurple,
          ),
        ],
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final pages = [_buildStep1(), _buildStep2(), _buildStep3(), _buildStep4(), _buildStep5()];
    final auth = ref.watch(authProvider);
    final canContinue = _canContinue();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Stack(
            children: [
              // Confetti overlay
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confetti,
                  blastDirectionality: BlastDirectionality.explosive,
                  numberOfParticles: 30,
                  colors: const [AppColors.libPurple, AppColors.purple300, AppColors.chart2, AppColors.chart4],
                ),
              ),

              Column(
                children: [
                  // ── Header ──────────────────────────────────────────────
                  Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 24,
                      left: 24,
                      right: 24,
                      bottom: 24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _back,
                              child: const Icon(Icons.arrow_back_ios_new, color: AppColors.foreground, size: 20),
                            ),
                            const Spacer(),
                            Text('Step ${_step + 1} of 5', style: GoogleFonts.inter(color: AppColors.mutedForeground, fontSize: 14, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Progress dots
                        Row(
                          children: List.generate(
                            5,
                            (i) => Expanded(
                              child: AnimatedContainer(
                                duration: 300.ms,
                                margin: const EdgeInsets.only(right: 6),
                                height: 6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: i <= _step ? AppColors.libPurple : AppColors.border,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(_stepTitles[_step], style: GoogleFonts.inter(color: AppColors.foreground, fontSize: 24, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),

                  // ── Step body ────────────────────────────────────────────
                  Expanded(
                    child: PageView(
                      controller: _pageCtrl,
                      physics: const NeverScrollableScrollPhysics(),
                      children: pages,
                    ),
                  ),

                  // ── Next / Submit button ──────────────────────────────────
                  Container(
                    padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -4)),
                      ],
                    ),
                    child: Row(
                      children: [
                        if (_step > 0) ...[
                          TextButton(
                            onPressed: _back,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                              foregroundColor: AppColors.mutedForeground,
                            ),
                            child: Text('Back', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: ElevatedButton(
                            onPressed: (canContinue && !auth.isLoading) ? _next : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.libPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                              disabledBackgroundColor: AppColors.libPurple.withOpacity(0.3),
                            ),
                            child: auth.isLoading
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : Text(
                                    _step == 4 ? 'Complete Setup 🎉' : 'Continue',
                                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Reusable step page wrapper ─────────────────────────────────────────────

class _StepPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _StepPage({required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.foreground))
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.1, end: 0),
          const SizedBox(height: 4),
          Text(subtitle, style: GoogleFonts.inter(color: AppColors.mutedForeground, fontSize: 14))
              .animate()
              .fadeIn(duration: 300.ms, delay: 60.ms),
          const SizedBox(height: 32),
          child.animate().fadeIn(duration: 300.ms, delay: 120.ms).slideY(begin: 0.08, end: 0),
        ],
      ),
    );
  }
}
