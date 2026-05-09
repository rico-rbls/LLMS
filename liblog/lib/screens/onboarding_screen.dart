/// lib/screens/onboarding_screen.dart
/// 5-step registration wizard with draft persistence and confetti on final step.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/colors.dart';
import '../providers/auth_provider.dart';
import '../providers/store_provider.dart';
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

  // Accumulated form data
  final _data = <String, dynamic>{};

  // Step 1 controllers
  final _fullNameCtrl   = TextEditingController();
  final _emailCtrl      = TextEditingController();
  final _passwordCtrl   = TextEditingController();
  bool _obscure         = true;

  // Step 2
  final _uniIdCtrl      = TextEditingController();

  // Step 3
  String _role          = 'student';

  // Step 4
  final _programCtrl    = TextEditingController();
  final _deptCtrl       = TextEditingController();
  final _yearCtrl       = TextEditingController();

  // Step 5 — notifications
  bool _notifDue        = true;
  bool _notifReserv     = true;
  bool _notifAnnounce   = false;

  static const _roles = ['student', 'faculty', 'visitor'];
  static const _roleLabels = {'student': 'Student', 'faculty': 'Faculty', 'visitor': 'Visitor'};
  static const _roleIcons  = {
    'student': Icons.school_outlined,
    'faculty': Icons.work_outline,
    'visitor': Icons.person_outline,
  };

  final _stepTitles = [
    'Create Account',
    'University Details',
    'Your Role',
    'Academic Info',
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
      _fullNameCtrl.text = savedData['fullName'] ?? '';
      _emailCtrl.text    = savedData['email'] ?? '';
      _uniIdCtrl.text    = savedData['universityId'] ?? '';
      _role              = savedData['role'] ?? 'student';
      _programCtrl.text  = savedData['program'] ?? '';
      _deptCtrl.text     = savedData['department'] ?? '';
      _yearCtrl.text     = savedData['yearLevel'] ?? '';
      _step              = savedStep;
    }
  }

  @override
  void dispose() {
    _confetti.dispose();
    _pageCtrl.dispose();
    _fullNameCtrl.dispose(); _emailCtrl.dispose(); _passwordCtrl.dispose();
    _uniIdCtrl.dispose(); _programCtrl.dispose(); _deptCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  void _persistDraft() {
    final storage = ref.read(storageServiceProvider);
    storage.saveOnboardingStep(_step);
    storage.saveOnboardingData({
      'fullName': _fullNameCtrl.text,
      'email': _emailCtrl.text,
      'universityId': _uniIdCtrl.text,
      'role': _role,
      'program': _programCtrl.text,
      'department': _deptCtrl.text,
      'yearLevel': _yearCtrl.text,
    });
  }

  bool _canContinue() {
    switch (_step) {
      case 0: return _fullNameCtrl.text.isNotEmpty &&
                     _emailCtrl.text.contains('@') &&
                     _passwordCtrl.text.length >= 6;
      case 1: return _uniIdCtrl.text.isNotEmpty;
      case 2: return _role.isNotEmpty;
      case 3: return _role == 'visitor' || _programCtrl.text.isNotEmpty;
      case 4: return true;
      default: return false;
    }
  }

  void _next() {
    if (!_canContinue()) return;
    _persistDraft();
    if (_step == 4) { _submit(); return; }
    setState(() => _step++);
    _pageCtrl.animateToPage(_step,
        duration: 300.ms, curve: Curves.easeInOut);
    if (_step == 4) _confetti.play();
  }

  void _back() {
    if (_step == 0) { Navigator.pop(context); return; }
    setState(() => _step--);
    _pageCtrl.animateToPage(_step,
        duration: 300.ms, curve: Curves.easeInOut);
  }

  Future<void> _submit() async {
    final userData = {
      'fullName': _fullNameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'password': hashPassword(_passwordCtrl.text),
      'universityId': _uniIdCtrl.text.trim(),
      'role': _role,
      'program': _programCtrl.text.trim(),
      'department': _deptCtrl.text.trim(),
      'yearLevel': _yearCtrl.text.trim(),
      'avatarInitials': getAvatarInitials(_fullNameCtrl.text.trim()),
      'notificationDueDate': _notifDue,
      'notificationReservation': _notifReserv,
      'notificationAnnouncements': _notifAnnounce,
    };
    await ref.read(authProvider.notifier).register(userData);
    if (mounted) Navigator.pop(context);
  }

  // ── Step pages ──────────────────────────────────────────────────────────

  Widget _buildStep1() => _StepPage(
    title: 'Create Your Account',
    subtitle: 'Set up your login credentials',
    child: Column(children: [
      _field('Full Name', _fullNameCtrl, Icons.person_outline, onChanged: (_) => setState(() {})),
      const SizedBox(height: 16),
      _field('Email', _emailCtrl, Icons.email_outlined,
        type: TextInputType.emailAddress, onChanged: (_) => setState(() {})),
      const SizedBox(height: 16),
      TextFormField(
        controller: _passwordCtrl,
        obscureText: _obscure,
        decoration: InputDecoration(
          labelText: 'Password',
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
        onChanged: (_) => setState(() {}),
      ),
    ]),
  );

  Widget _buildStep2() => _StepPage(
    title: 'University Details',
    subtitle: 'Enter your university ID number',
    child: _field('University ID', _uniIdCtrl, Icons.badge_outlined,
      onChanged: (_) => setState(() {})),
  );

  Widget _buildStep3() => _StepPage(
    title: 'Your Role',
    subtitle: 'Select how you use the library',
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
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? AppColors.libPurple : AppColors.border,
                width: selected ? 2 : 1,
              ),
              color: selected ? AppColors.purple50 : Colors.white,
            ),
            child: Row(children: [
              Icon(_roleIcons[role], color: selected ? AppColors.libPurple : AppColors.gray500),
              const SizedBox(width: 12),
              Text(_roleLabels[role]!,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.libPurple : AppColors.foreground)),
              const Spacer(),
              if (selected) const Icon(Icons.check_circle, color: AppColors.libPurple),
            ]),
          ),
        );
      }).toList(),
    ),
  );

  Widget _buildStep4() => _StepPage(
    title: 'Academic Information',
    subtitle: _role == 'visitor'
        ? 'No additional info needed for visitors'
        : 'Help us personalise your experience',
    child: _role == 'visitor'
        ? const Icon(Icons.check_circle_outline, size: 64, color: AppColors.libPurple)
        : Column(children: [
            _field(_role == 'faculty' ? 'Department' : 'Program/Course',
              _programCtrl, Icons.book_outlined, onChanged: (_) => setState(() {})),
            const SizedBox(height: 16),
            if (_role == 'student') ...[
              _field('Year Level (e.g. 3rd Year)', _yearCtrl, Icons.calendar_today_outlined,
                onChanged: (_) => setState(() {})),
            ] else ...[
              _field('College/Department', _deptCtrl, Icons.domain_outlined,
                onChanged: (_) => setState(() {})),
            ],
          ]),
  );

  Widget _buildStep5() => _StepPage(
    title: 'Notification Preferences',
    subtitle: 'Choose what alerts you receive',
    child: Column(children: [
      _toggle('Due Date Reminders', 'Get notified when books are due', _notifDue,
        (v) => setState(() => _notifDue = v)),
      const SizedBox(height: 12),
      _toggle('Reservation Alerts', 'Know when reserved books are ready', _notifReserv,
        (v) => setState(() => _notifReserv = v)),
      const SizedBox(height: 12),
      _toggle('System Announcements', 'Library news and events', _notifAnnounce,
        (v) => setState(() => _notifAnnounce = v)),
    ]),
  );

  // ── Helpers ─────────────────────────────────────────────────────────────

  static Widget _field(String label, TextEditingController ctrl,
      IconData icon, {TextInputType? type, void Function(String)? onChanged}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    );
  }

  static Widget _toggle(String title, String sub, bool value,
      void Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 2),
          Text(sub, style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
        ])),
        Switch(value: value, onChanged: onChanged),
      ]),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final pages = [_buildStep1(), _buildStep2(), _buildStep3(), _buildStep4(), _buildStep5()];
    final auth  = ref.watch(authProvider);
    final canContinue = _canContinue();

    return Scaffold(
      body: Stack(
        children: [
          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 20,
              colors: const [
                AppColors.libPurple, AppColors.purple300,
                Colors.white, AppColors.chart4,
              ],
            ),
          ),

          Column(
            children: [
              // ── Header ──────────────────────────────────────────────
              Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 20, right: 20, bottom: 24,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.libPurple, AppColors.purple800],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    GestureDetector(
                      onTap: _back,
                      child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    ),
                    const Spacer(),
                    Text('Step ${_step + 1} of 5',
                      style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ]),
                  const SizedBox(height: 16),
                  // Progress dots
                  Row(children: List.generate(5, (i) => AnimatedContainer(
                    duration: 300.ms,
                    margin: const EdgeInsets.only(right: 6),
                    width:  i == _step ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: i <= _step ? Colors.white : Colors.white38,
                    ),
                  ))),
                  const SizedBox(height: 12),
                  Text(_stepTitles[_step],
                    style: const TextStyle(color: Colors.white,
                      fontSize: 22, fontWeight: FontWeight.w700)),
                ]),
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
              Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24,
                  MediaQuery.of(context).padding.bottom + 16),
                child: ElevatedButton(
                  onPressed: (canContinue && !auth.isLoading) ? _next : null,
                  child: auth.isLoading
                    ? const SizedBox(height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(_step == 4 ? 'Create Account 🎉' : 'Continue'),
                ),
              ),
            ],
          ),
        ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Text(title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700))
              .animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 4),
          Text(subtitle,
            style: const TextStyle(color: AppColors.mutedForeground, fontSize: 14))
              .animate().fadeIn(duration: 300.ms, delay: 60.ms),
          const SizedBox(height: 24),
          child.animate().fadeIn(duration: 300.ms, delay: 120.ms)
               .slideY(begin: 0.08, end: 0),
        ],
      ),
    );
  }
}
