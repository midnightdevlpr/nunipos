import 'package:flutter/material.dart';

import '../home_screen.dart';
import '../../services/auth_service.dart';
import 'registration_wizard.dart';

/// Final onboarding screen shown after the registration wizard steps.
/// Creates the admin account once the user confirms they're ready to continue.
class RegistrationCompleteScreen extends StatelessWidget {
  const RegistrationCompleteScreen({super.key, required this.draft});

  final RegistrationDraft draft;

  void _finish(BuildContext context) {
    final result = AuthService.instance.register(
      name: '${draft.firstName} ${draft.lastName}'.trim(),
      email: draft.email,
      password: draft.password,
    );

    if (!result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.errorMessage!)),
      );
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RegistrationColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: RegistrationColors.success,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 68),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Onboarding completed',
                  style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w300),
                ),
                const SizedBox(height: 16),
                Text(
                  'Congratulations! You are set and ready to go.\n'
                  'Next, open "Management" section to add some products and start selling.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 15),
                ),
                const SizedBox(height: 28),
                OutlinedButton(
                  onPressed: () => _finish(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Close & Continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
