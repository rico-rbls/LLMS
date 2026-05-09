/// lib/screens/login_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/colors.dart';
import '../providers/auth_provider.dart';
import 'onboarding_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;

  late AnimationController _gradientController;
  late Animation<Color?> _color1;
  late Animation<Color?> _color2;

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    _color1 = TweenSequence<Color?>([
      TweenSequenceItem(weight: 1.0, tween: ColorTween(begin: AppColors.libPurple, end: AppColors.purple700)),
      TweenSequenceItem(weight: 1.0, tween: ColorTween(begin: AppColors.purple700, end: AppColors.purple600)),
      TweenSequenceItem(weight: 1.0, tween: ColorTween(begin: AppColors.purple600, end: AppColors.libPurple)),
    ]).animate(_gradientController);

    _color2 = TweenSequence<Color?>([
      TweenSequenceItem(weight: 1.0, tween: ColorTween(begin: AppColors.purple800, end: AppColors.purple900)),
      TweenSequenceItem(weight: 1.0, tween: ColorTween(begin: AppColors.purple900, end: AppColors.purple800)),
      TweenSequenceItem(weight: 1.0, tween: ColorTween(begin: AppColors.purple800, end: AppColors.purple700)),
    ]).animate(_gradientController);
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _fillDemo() {
    _emailCtrl.text = 'juan@university.edu';
    _passwordCtrl.text = 'password123';
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final ok = await ref.read(authProvider.notifier).login(_emailCtrl.text.trim(), _passwordCtrl.text);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ref.read(authProvider).error ?? 'Login failed.', style: GoogleFonts.inter()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Stack(
            children: [
              // ── Background Gradient ──────────────────────────────────────
              AnimatedBuilder(
                animation: _gradientController,
                builder: (context, child) {
                  return Container(
                    height: 400,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_color1.value ?? AppColors.libPurple, _color2.value ?? AppColors.purple800],
                      ),
                    ),
                  );
                },
              ),

              // ── Scrollable Content ───────────────────────────────────────
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Header Content (Logo, Title, Subtitle)
                    SizedBox(
                      height: 360,
                      child: Stack(
                        children: [
                          // Parallax Decorative Circles
                          Positioned(
                            top: -40, right: -40,
                            child: Container(
                              width: 200, height: 200,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.08)),
                            ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: 0, end: 20, duration: 8.seconds),
                          ),
                          Positioned(
                            bottom: 60, left: -60,
                            child: Container(
                              width: 150, height: 150,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.05)),
                            ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: 0, end: -30, duration: 10.seconds),
                          ),
                          // Logo & Text
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 40),
                                Container(
                                  width: 90, height: 90,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 48),
                                ).animate(onPlay: (c) => c.repeat(reverse: true))
                                 .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 2.seconds)
                                 .shimmer(duration: 3.seconds, color: Colors.white24),
                                const SizedBox(height: 24),
                                Text(
                                  'LibLog',
                                  style: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(width: 16, height: 2, color: Colors.white.withOpacity(0.5)),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Digital Library Logbook System',
                                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.9)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Form Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 30, offset: const Offset(0, -10)),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Welcome back', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.foreground)),
                            const SizedBox(height: 4),
                            Text('Sign in to your account', style: GoogleFonts.inter(fontSize: 14, color: AppColors.mutedForeground)),
                            const SizedBox(height: 32),

                            // Email Field
                            Text('Email', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.foreground)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _emailCtrl,
                              decoration: _inputDecoration(Icons.school_outlined, 'you@university.edu'),
                              validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                            ),
                            const SizedBox(height: 20),

                            // Password Field
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Password', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.foreground)),
                                TextButton(
                                  onPressed: () {},
                                  child: Text('Forgot password?', style: GoogleFonts.inter(fontSize: 13, color: AppColors.libPurple, fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            TextFormField(
                              controller: _passwordCtrl,
                              obscureText: _obscure,
                              decoration: _inputDecoration(Icons.lock_outline, 'Enter your password').copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                ),
                              ),
                              validator: (v) => (v == null || v.length < 6) ? 'Minimum 6 characters' : null,
                            ),
                            const SizedBox(height: 32),

                            // Login Button
                            ElevatedButton(
                              onPressed: auth.isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.libPurple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: auth.isLoading
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : Text('Sign In', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
                            ),
                            
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(child: Divider(color: AppColors.border)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text('or', style: GoogleFonts.inter(fontSize: 12, color: AppColors.mutedForeground)),
                                ),
                                Expanded(child: Divider(color: AppColors.border)),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Demo Button
                            GestureDetector(
                              onTap: _fillDemo,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.libPurple.withOpacity(0.3), width: 1.5, style: BorderStyle.solid),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.menu_book_outlined, color: AppColors.libPurple, size: 18),
                                    const SizedBox(width: 10),
                                    Text('Use Demo Account', style: GoogleFonts.inter(color: AppColors.libPurple, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Footer Section
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Don't have an account? ", style: GoogleFonts.inter(color: AppColors.mutedForeground)),
                              GestureDetector(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OnboardingScreen())),
                                child: Text('Register', style: GoogleFonts.inter(color: AppColors.libPurple, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          Text(
                            'By signing in, you agree to our Terms of Service & Privacy Policy',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(fontSize: 10, color: AppColors.mutedForeground.withOpacity(0.7)),
                          ),
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
    );
  }

  InputDecoration _inputDecoration(IconData icon, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.mutedForeground.withOpacity(0.5)),
      prefixIcon: Icon(icon, size: 20, color: AppColors.mutedForeground),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.libPurple, width: 1.5)),
    );
  }
}
