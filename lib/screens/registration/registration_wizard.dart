import 'package:flutter/material.dart';

/// Shared look and chrome for the multi-step registration wizard.
class RegistrationColors {
  const RegistrationColors._();

  static const background = Color(0xFF2E2E2E);
  static const accent = Color(0xFF29ABE2);
  static const fieldFill = Color(0xFF3A3A3A);
  static const inactiveDot = Color(0xFF5A5A5A);
  static const error = Color(0xFFE04F4F);
  static const warning = Color(0xFFF2C230);
  static const success = Color(0xFF3DAA4E);
}

class StepDots extends StatelessWidget {
  const StepDots({super.key, required this.totalSteps, required this.currentStep});

  final int totalSteps;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalSteps, (index) {
        final isActive = index == currentStep;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? RegistrationColors.accent : RegistrationColors.inactiveDot,
          ),
        );
      }),
    );
  }
}

/// Common layout for every wizard step: dark background, scrollable centered
/// [child], step dots, and back/next arrows pinned to the bottom corners.
class RegistrationWizardScaffold extends StatelessWidget {
  const RegistrationWizardScaffold({
    super.key,
    required this.currentStep,
    required this.child,
    required this.onNext,
    this.onBack,
    this.totalSteps = 4,
  });

  final int currentStep;
  final int totalSteps;
  final Widget child;
  final VoidCallback? onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RegistrationColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: child,
              ),
            ),
            if (onBack != null)
              Positioned(
                left: 32,
                bottom: 24,
                child: IconButton(
                  iconSize: 32,
                  color: Colors.white,
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Back',
                  onPressed: onBack,
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 40,
              child: Center(
                child: StepDots(totalSteps: totalSteps, currentStep: currentStep),
              ),
            ),
            Positioned(
              right: 32,
              bottom: 24,
              child: IconButton(
                iconSize: 36,
                color: Colors.white,
                icon: const Icon(Icons.arrow_forward),
                tooltip: 'Next',
                onPressed: onNext,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A labeled text field styled to match the wizard: white label above a
/// dark-filled bordered input, switching to a red/warning state on error.
class WizardTextField extends StatefulWidget {
  const WizardTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.showRevealToggle = false,
    this.hasError = false,
    this.isValid = false,
    this.trailing,
    this.keyboardType,
    this.autofillHints,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final bool showRevealToggle;
  final bool hasError;
  final bool isValid;
  final Widget? trailing;
  final TextInputType? keyboardType;
  final List<String>? autofillHints;
  final ValueChanged<String>? onChanged;

  @override
  State<WizardTextField> createState() => _WizardTextFieldState();
}

class _WizardTextFieldState extends State<WizardTextField> {
  late bool _obscured = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.hasError
        ? RegistrationColors.error
        : widget.isValid
            ? RegistrationColors.success
            : const Color(0xFF6B6B6B);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.controller,
                obscureText: widget.showRevealToggle ? _obscured : widget.obscureText,
                keyboardType: widget.keyboardType,
                autofillHints: widget.autofillHints,
                onChanged: widget.onChanged,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                cursorColor: RegistrationColors.accent,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: RegistrationColors.fieldFill,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2),
                    borderSide: BorderSide(color: borderColor, width: 2),
                  ),
                ),
              ),
            ),
            if (widget.hasError) ...[
              const SizedBox(width: 8),
              const Icon(Icons.warning_rounded, color: RegistrationColors.warning, size: 22),
            ] else if (widget.isValid) ...[
              const SizedBox(width: 8),
              const Icon(Icons.check_circle, color: RegistrationColors.success, size: 22),
            ],
            if (widget.showRevealToggle) ...[
              const SizedBox(width: 8),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                iconSize: 20,
                color: Colors.white70,
                icon: Icon(_obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                tooltip: _obscured ? 'Show password' : 'Hide password',
                onPressed: () => setState(() => _obscured = !_obscured),
              ),
            ] else if (widget.trailing != null) ...[
              const SizedBox(width: 8),
              widget.trailing!,
            ],
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
