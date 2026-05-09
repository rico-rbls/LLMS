/// lib/screens/login_screen.dart
/// Login UI: living dual-layer gradient header, pulsing logo, demo auto-fill.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/colors.dart';
import '../providers/auth_provider.dart';
import 'onboarding_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey      = GlobalKey<FormState>();
  bool _obscure = true;

  // ── Living gradient animation ──────────────────────────────────────────
  // Two layers cycling through 4 color states each (8s & 10s per FEATURES.md)
  static const _gradientSets = [
    [Color(0xFF652D90), Color(0xFF3A1850)],
    [Color(0xFF9B5BBF), Color(0xFF522575)],
    [Color(0xFF4A2068), Color(0xFF1a0e2e)],
    [Color(0xFF7B3FA8), Color(0xFF3A1850)],
  ];
  int _gradientIndex = 0;
  late Timer _gradientTimer;

  @override
  void initState() {
    super.initState();
    _gradientTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      setState(() => _gradientIndex = (_gradientIndex + 1) % _gradientSets.length);
    });
  }

  @override
  void dispose() {
    _gradientTimer.cancel();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _fillDemo() {
    _emailCtrl.text    = 'juan@university.edu';
    _passwordCtrl.text = 'password123';
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final ok = await ref.read(authProvider.notifier)
        .login(_emailCtrl.text.trim(), _passwordCtrl.text);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ref.read(authProvider).error ?? 'Login failed.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final colors = _gradientSets[_gradientIndex];

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Gradient header ────────────────────────────────────────
            AnimatedContainer(
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
              height: 320,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors,
                ),
              ),
              child: Stack(
                children: [
                  // Decorative circles
                  Positioned(top: -40, right: -40,
                    child: Container(width: 180, height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06),
                      ))),
                  Positioned(bottom: -20, left: -30,
                    child: Container(width: 140, height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.04),
                      ))),
                  // Pulsing logo
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 48),
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.auto_stories,
                            color: Colors.white, size: 44),
                        )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scale(begin: const Offset(1, 1),
                                 end:   const Offset(1.08, 1.08),
                                 duration: 2000.ms, curve: Curves.easeInOut)
                          .then()
                          .fade(begin: 0.85, end: 1.0, duration: 2000.ms),
                        const SizedBox(height: 16),
                        const Text('LibLog',
                          style: TextStyle(color: Colors.white,
                            fontSize: 28, fontWeight: FontWeight.w700,
                            letterSpacing: -0.5)),
                        const SizedBox(height: 4),
                        Text('Your Digital Library Companion',
                          style: TextStyle(color: Colors.white.withOpacity(0.80),
                            fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Form ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    const Text('Welcome Back',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('Sign in to your account',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                    const SizedBox(height: 28),

                    // Email
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) => (v == null || !v.contains('@'))
                          ? 'Enter a valid email' : null,
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) => (v == null || v.length < 6)
                          ? 'Minimum 6 characters' : null,
                    ),
                    const SizedBox(height: 28),

                    // Sign In button
                    ElevatedButton(
                      onPressed: auth.isLoading ? null : _submit,
                      child: auth.isLoading
                        ? const SizedBox(height: 20, width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                        : const Text('Sign In'),
                    ),
                    const SizedBox(height: 12),

                    // Demo button
                    OutlinedButton.icon(
                      icon: const Icon(Icons.science_outlined, size: 18),
                      label: const Text('Use Demo Account'),
                      onPressed: _fillDemo,
                    ),
                    const SizedBox(height: 20),

                    // Register link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account? ",
                          style: TextStyle(color: Colors.grey[600])),
                        GestureDetector(
                          onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                              builder: (_) => const OnboardingScreen())),
                          child: const Text('Register',
                            style: TextStyle(
                              color: AppColors.libPurple,
                              fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
