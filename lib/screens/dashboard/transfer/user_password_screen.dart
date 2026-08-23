import 'package:flutter/material.dart';

import '../../../services/auth_service.dart';
import '../../../widgets/virtual_keyboard.dart';
import '../dashboard_colors.dart';

/// Re-authenticates the current staff member by password before letting a
/// transfer be assigned to them. There's no multi-user staff directory yet,
/// so this confirms against the signed-in account rather than switching
/// users.
class UserPasswordScreen extends StatefulWidget {
  const UserPasswordScreen({super.key});

  @override
  State<UserPasswordScreen> createState() => _UserPasswordScreenState();
}

class _UserPasswordScreenState extends State<UserPasswordScreen> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (AuthService.instance.verifyCurrentPassword(_controller.text)) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _error = 'Incorrect password.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DashboardColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 100),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(Icons.person, color: Colors.white, size: 76),
                  ),
                  const SizedBox(width: 32),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      const Text('Password', style: TextStyle(color: Colors.white, fontSize: 15)),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 320,
                        child: TextField(
                          controller: _controller,
                          obscureText: true,
                          autofocus: true,
                          style: const TextStyle(color: Colors.white),
                          cursorColor: DashboardColors.accentBlue,
                          onChanged: (_) {
                            if (_error != null) setState(() => _error = null);
                          },
                          onSubmitted: (_) => _submit(),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: DashboardColors.background,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.arrow_forward, color: Colors.white),
                              onPressed: _submit,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(2),
                              borderSide: BorderSide(
                                color: _error != null ? DashboardColors.accentRed : DashboardColors.border,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(2),
                              borderSide: BorderSide(
                                color: _error != null ? DashboardColors.accentRed : DashboardColors.border,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(2),
                              borderSide: BorderSide(
                                color: _error != null ? DashboardColors.accentRed : DashboardColors.accentBlue,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 6),
                        Text(_error!, style: const TextStyle(color: DashboardColors.accentRed, fontSize: 13)),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: DashboardColors.accentGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text('OK'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.of(context).pop(false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: DashboardColors.accentRed,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            icon: const Icon(Icons.close, size: 18),
                            label: const Text('Cancel'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: VirtualKeyboard(controller: _controller, onEnter: _submit),
            ),
          ],
        ),
      ),
    );
  }
}
