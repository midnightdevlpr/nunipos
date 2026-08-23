import 'package:flutter/material.dart';

import '../../registration/registration_wizard.dart';

/// First step of starting a new sale: an optional order or customer name.
class OrderNameScreen extends StatefulWidget {
  const OrderNameScreen({super.key});

  @override
  State<OrderNameScreen> createState() => _OrderNameScreenState();
}

class _OrderNameScreenState extends State<OrderNameScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _continue() => Navigator.of(context).pop(_controller.text.trim());
  void _cancel() => Navigator.of(context).pop();

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
                const Icon(Icons.emoji_people, size: 110, color: Colors.white),
                const SizedBox(height: 24),
                const Text(
                  'Order or customer name',
                  style: TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w300),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 420,
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _continue(),
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    cursorColor: RegistrationColors.accent,
                    decoration: InputDecoration(
                      hintText: 'Enter order name or number',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.45)),
                      suffixIcon: const Icon(Icons.edit_outlined, color: Colors.white54, size: 18),
                      filled: true,
                      fillColor: RegistrationColors.fieldFill,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: _continue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: RegistrationColors.success,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      ),
                      child: const Text('Continue'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _cancel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: RegistrationColors.error,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
