import 'package:flutter/material.dart';

import '../../../models/service_type.dart';
import '../../registration/registration_wizard.dart';

/// Second step of starting a new sale: dine-in or takeaway.
class ServiceTypeScreen extends StatefulWidget {
  const ServiceTypeScreen({super.key, required this.initial});

  final ServiceType initial;

  @override
  State<ServiceTypeScreen> createState() => _ServiceTypeScreenState();
}

class _ServiceTypeScreenState extends State<ServiceTypeScreen> {
  late ServiceType _selected = widget.initial;

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
                const Text(
                  'Service type',
                  style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w300),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select service type for this order',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 15),
                ),
                const SizedBox(height: 48),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ServiceOption(
                      icon: Icons.event_seat,
                      label: 'Dine-in',
                      selected: _selected == ServiceType.dineIn,
                      onTap: () => setState(() => _selected = ServiceType.dineIn),
                    ),
                    const SizedBox(width: 80),
                    _ServiceOption(
                      icon: Icons.shopping_bag_outlined,
                      label: 'Takeaway',
                      selected: _selected == ServiceType.takeaway,
                      onTap: () => setState(() => _selected = ServiceType.takeaway),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(_selected),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RegistrationColors.success,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  ),
                  child: const Text('Continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ServiceOption extends StatelessWidget {
  const _ServiceOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: SizedBox(
          width: 140,
          child: Column(
            children: [
              Icon(icon, size: 90, color: Colors.white),
              const SizedBox(height: 12),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 16),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? RegistrationColors.success : null,
                  border: selected ? null : Border.all(color: Colors.white38, width: 2),
                ),
                child: selected ? const Icon(Icons.check, color: Colors.white, size: 24) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
