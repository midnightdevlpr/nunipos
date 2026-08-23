import 'package:flutter/material.dart';

import 'registration_complete_screen.dart';
import 'registration_step3_screen.dart';
import 'registration_wizard.dart';

enum LayoutMode { standard, visual }

/// Step 4 (final) of the registration wizard: sales screen layout preference.
///
/// The actual Standard/Visual sales screens aren't built yet — this only
/// captures the preference. Completing this step creates the admin account.
class RegistrationStep4Screen extends StatefulWidget {
  const RegistrationStep4Screen({
    super.key,
    required this.draft,
    required this.priceDisplayMode,
  });

  final RegistrationDraft draft;
  final PriceDisplayMode priceDisplayMode;

  @override
  State<RegistrationStep4Screen> createState() => _RegistrationStep4ScreenState();
}

class _RegistrationStep4ScreenState extends State<RegistrationStep4Screen> {
  LayoutMode _selected = LayoutMode.standard;
  bool _virtualKeyboardEnabled = false;

  void _showInfoDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Layouts and workspace'),
        content: const Text(
          'Standard layout suits a physical keyboard and barcode scanner. Visual '
          'layout shows your products and groups as tappable tiles, better suited '
          'for touch screens. You can switch this anytime from Settings.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Got it')),
        ],
      ),
    );
  }

  void _onNext() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RegistrationCompleteScreen(draft: widget.draft),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RegistrationWizardScaffold(
      currentStep: 3,
      onBack: () => Navigator.of(context).pop(),
      onNext: _onNext,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose Layout',
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w300),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _showInfoDialog,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.help_outline, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Learn more about layouts and workspace',
                    style: TextStyle(color: RegistrationColors.accent, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.start,
              spacing: 70,
              runSpacing: 24,
              children: [
                _LayoutOption(
                  icon: Icons.north_west,
                  selected: _selected == LayoutMode.standard,
                  title: 'Standard',
                  description: 'Use this layout if you are using barcodes or have a physical '
                      'keyboard attached to your computer.',
                  onTap: () => setState(() => _selected = LayoutMode.standard),
                ),
                _LayoutOption(
                  icon: Icons.touch_app,
                  selected: _selected == LayoutMode.visual,
                  title: 'Visual',
                  description: 'Use this layout if you wish to visually display your products '
                      'and groups on sales screen.',
                  onTap: () => setState(() => _selected = LayoutMode.visual),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: _virtualKeyboardEnabled,
                  activeThumbColor: RegistrationColors.accent,
                  onChanged: (value) => setState(() => _virtualKeyboardEnabled = value),
                ),
                const SizedBox(width: 4),
                const Text('Enable virtual keyboard', style: TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _LayoutOption extends StatelessWidget {
  const _LayoutOption({
    required this.icon,
    required this.selected,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: SizedBox(
          width: 250,
          child: Column(
            children: [
              const SizedBox(height: 18),
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  SizedBox(
                    width: 110,
                    height: 110,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(Icons.desktop_windows_outlined, size: 100, color: Colors.white),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Icon(icon, size: 34, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  if (selected)
                    Positioned(
                      top: -14,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: RegistrationColors.success,
                          boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 4)],
                        ),
                        child: const Icon(Icons.check, color: Colors.white, size: 20),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
