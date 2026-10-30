import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../shared/providers/pending_auth_provider.dart';
import '../../theme/app_theme.dart';

class VerifyScreen extends ConsumerStatefulWidget {
  const VerifyScreen({super.key});

  @override
  ConsumerState<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends ConsumerState<VerifyScreen> {
  String _otp = '';
  String? _error;
  bool _resending = false;

  void _verify(String value) {
    if (value == '123456') {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _error = 'Invalid code. Try 123456');
    }
  }

  Future<void> _resend() async {
    setState(() => _resending = true);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _resending = false;
      _error = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Code resent (demo: 123456)'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pending = ref.watch(pendingAuthProvider);

    // Guard: nothing to verify (e.g. deep-linked, app restarted mid-flow).
    if (pending == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Verify')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.s24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'No pending verification.',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: AppTheme.s8),
                const Text(
                  'Please start again from login or register.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                ),
                const SizedBox(height: AppTheme.s16),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Go back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final title = switch (pending.flow) {
      AuthFlow.login => 'Verify your login',
      AuthFlow.register => 'Verify your account',
      AuthFlow.forgot => 'Verify your contact',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Verify')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppTheme.s16),
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: AppTheme.s8),
              Text(
                'We sent a 6-digit code to ${pending.contact}.',
                style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 4),
              const Text(
                'Demo code: 123456',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: AppTheme.s24),
              PinCodeTextField(
                appContext: context,
                length: 6,
                keyboardType: TextInputType.number,
                animationType: AnimationType.fade,
                onChanged: (v) {
                  _otp = v;
                  if (_error != null) setState(() => _error = null);
                },
                onCompleted: _verify,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(AppTheme.rMd),
                  fieldHeight: 56,
                  fieldWidth: 48,
                  activeColor: AppTheme.primary,
                  inactiveColor: AppTheme.border,
                  selectedColor: AppTheme.primary,
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: AppTheme.s12),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.danger,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: AppTheme.s24),
              FilledButton(
                onPressed: _otp.length == 6 ? () => _verify(_otp) : null,
                child: const Text('Verify'),
              ),
              const SizedBox(height: AppTheme.s8),
              TextButton(
                onPressed: _resending ? null : _resend,
                child: _resending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Resend code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}