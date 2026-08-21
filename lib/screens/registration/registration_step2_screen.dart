import 'package:flutter/material.dart';

import 'registration_step3_screen.dart';
import 'registration_wizard.dart';

/// Step 2 of the registration wizard: the admin's name and login credentials.
class RegistrationStep2Screen extends StatefulWidget {
  const RegistrationStep2Screen({super.key, required this.initialEmail});

  final String initialEmail;

  @override
  State<RegistrationStep2Screen> createState() => _RegistrationStep2ScreenState();
}

class _RegistrationStep2ScreenState extends State<RegistrationStep2Screen> {
  late final _firstNameController = TextEditingController();
  late final _lastNameController = TextEditingController();
  late final _emailController = TextEditingController(text: widget.initialEmail);
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showValidation = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _passwordInvalid => _passwordController.text.length < 8;
  bool get _confirmInvalid =>
      _confirmPasswordController.text.isEmpty ||
      _confirmPasswordController.text != _passwordController.text;

  bool get _confirmHasContent => _confirmPasswordController.text.isNotEmpty;
  bool get _confirmMatches =>
      _confirmHasContent && _confirmPasswordController.text == _passwordController.text;
  bool get _confirmMismatch => _confirmHasContent && !_confirmMatches;

  void _showInfoDialog(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Got it')),
        ],
      ),
    );
  }

  void _onNext() {
    if (_passwordInvalid || _confirmInvalid) {
      setState(() => _showValidation = true);
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegistrationStep3Screen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RegistrationWizardScaffold(
      currentStep: 1,
      onBack: () => Navigator.of(context).pop(),
      onNext: _onNext,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Let's set your personal account",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please enter your name and login credentials used for admin access.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _showInfoDialog(
                'Users and default credentials',
                'The account you create here becomes the first admin user. You can '
                    'invite additional users with different roles later from Settings.',
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.help_outline, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Learn more about users and default credentials',
                      style: TextStyle(color: RegistrationColors.accent, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            WizardTextField(
              label: 'First name',
              controller: _firstNameController,
            ),
            WizardTextField(
              label: 'Last name',
              controller: _lastNameController,
            ),
            WizardTextField(
              label: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              trailing: IconButton(
                icon: const Icon(Icons.help_outline, color: Colors.white, size: 20),
                onPressed: () => _showInfoDialog(
                  'Email',
                  'Your email is used for admin login and to recover your password. '
                      'You can change it anytime.',
                ),
              ),
            ),
            WizardTextField(
              label: 'Password',
              controller: _passwordController,
              obscureText: true,
              showRevealToggle: true,
              autofillHints: const [AutofillHints.newPassword],
              hasError: _showValidation && _passwordInvalid,
              onChanged: (_) => setState(() {}),
            ),
            WizardTextField(
              label: 'Confirm password',
              controller: _confirmPasswordController,
              obscureText: true,
              showRevealToggle: true,
              autofillHints: const [AutofillHints.newPassword],
              hasError: (_showValidation && _confirmInvalid) || _confirmMismatch,
              isValid: _confirmMatches,
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
    );
  }
}
