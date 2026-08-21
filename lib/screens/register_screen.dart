import 'package:flutter/material.dart';

import 'registration/registration_step2_screen.dart';
import 'registration/registration_wizard.dart';

/// Step 1 of the registration wizard: collect the admin email address.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const routeName = '/register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onNext() {
    final email = _emailController.text.trim();
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (email.isEmpty) {
      setState(() => _errorText = 'Enter your email address');
      return;
    }
    if (!emailPattern.hasMatch(email)) {
      setState(() => _errorText = 'Enter a valid email address');
      return;
    }

    setState(() => _errorText = null);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RegistrationStep2Screen(initialEmail: email)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RegistrationWizardScaffold(
      currentStep: 0,
      onNext: _onNext,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_outline, size: 72, color: Colors.white),
            const SizedBox(height: 14),
            const Text(
              'Registration',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w300,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 24),
            const _InfoBanner(
              text: 'This email will be set to default admin account and can be used '
                  'to reset password. You can change this email address anytime.',
            ),
            const SizedBox(height: 18),
            const Text(
              'Your email address',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              style: const TextStyle(color: Colors.white, fontSize: 16),
              cursorColor: RegistrationColors.accent,
              onChanged: (_) {
                if (_errorText != null) setState(() => _errorText = null);
              },
              onSubmitted: (_) => _onNext(),
              decoration: InputDecoration(
                hintText: 'you@example.com',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                filled: true,
                fillColor: RegistrationColors.fieldFill,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(2),
                  borderSide: const BorderSide(color: RegistrationColors.accent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(2),
                  borderSide: const BorderSide(color: RegistrationColors.accent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(2),
                  borderSide: const BorderSide(color: RegistrationColors.accent, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (_errorText != null)
              Text(
                _errorText!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: RegistrationColors.error, fontSize: 12),
              )
            else
              Text(
                'Your email is kept strictly confidential. We will use your email to '
                'provide more personalized support and to send you latest updates, '
                'only if you wish. We hate "spam", too.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 12),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 48,
            color: RegistrationColors.accent,
            child: const Icon(Icons.info_outline, color: Colors.white, size: 22),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: RegistrationColors.accent),
                  right: BorderSide(color: RegistrationColors.accent),
                  bottom: BorderSide(color: RegistrationColors.accent),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              alignment: Alignment.centerLeft,
              child: Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
