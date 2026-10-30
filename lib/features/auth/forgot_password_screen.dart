import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/providers/pending_auth_provider.dart';
import '../../theme/app_theme.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _contactFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _contactController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _showNewPassword = false;
  bool _obscure = true;
  bool _navigating = false;

  @override
  void dispose() {
    _contactController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_contactFormKey.currentState!.validate()) return;
    if (_navigating) return;
    setState(() => _navigating = true);

    ref.read(pendingAuthProvider.notifier).set(PendingAuth(
      contact: _contactController.text.trim(),
      flow: AuthFlow.forgot,
    ));

    final verified = await context.push<bool>('/verify');
    if (!mounted) return;
    setState(() => _navigating = false);

    if (verified == true) {
      setState(() => _showNewPassword = true);
    }
  }

  void _resetPassword() {
    if (!_passwordFormKey.currentState!.validate()) return;
    ref.read(pendingAuthProvider.notifier).clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password reset successful. Please log in.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.s16),
          child: _showNewPassword ? _buildNewPassword() : _buildContactForm(),
        ),
      ),
    );
  }

  Widget _buildContactForm() {
    return Form(
      key: _contactFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppTheme.s24),
          Text('Reset your password',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppTheme.s8),
          Text(
            'Enter the email or phone you registered with. We\'ll send a code to verify it\'s you.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppTheme.textMuted),
          ),
          const SizedBox(height: AppTheme.s24),
          TextFormField(
            controller: _contactController,
            keyboardType: TextInputType.emailAddress,
            decoration:
                const InputDecoration(labelText: 'Email or phone'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: AppTheme.s16),
          FilledButton(
            onPressed: _navigating ? null : _sendOtp,
            child: _navigating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Send code'),
          ),
          const SizedBox(height: AppTheme.s8),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Back to login'),
          ),
        ],
      ),
    );
  }

  Widget _buildNewPassword() {
    return Form(
      key: _passwordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppTheme.s24),
          Text('Set a new password',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppTheme.s8),
          Text(
            'Choose a new password for your account.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppTheme.textMuted),
          ),
          const SizedBox(height: AppTheme.s24),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: 'New password',
              suffixIcon: IconButton(
                icon: Icon(_obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            validator: (v) =>
                (v == null || v.length < 6) ? 'Minimum 6 characters' : null,
          ),
          const SizedBox(height: AppTheme.s12),
          TextFormField(
            controller: _confirmController,
            obscureText: _obscure,
            decoration:
                const InputDecoration(labelText: 'Confirm password'),
            validator: (v) => v != _passwordController.text
                ? 'Passwords do not match'
                : null,
          ),
          const SizedBox(height: AppTheme.s16),
          FilledButton(
            onPressed: _resetPassword,
            child: const Text('Reset password'),
          ),
        ],
      ),
    );
  }
}