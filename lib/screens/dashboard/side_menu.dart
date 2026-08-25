import 'package:flutter/material.dart';

import 'dashboard_colors.dart';

/// The sliding right-hand navigation panel opened from the top-right menu
/// icon. Items are wired to a generic placeholder for now — their real
/// behavior comes later — except Sign out, which is already functional.
class DashboardSideMenu extends StatelessWidget {
  const DashboardSideMenu({
    super.key,
    required this.businessName,
    required this.onAction,
    required this.onSignOut,
    required this.onOpenManagement,
  });

  final String businessName;
  final ValueChanged<String> onAction;
  final VoidCallback onSignOut;
  final VoidCallback onOpenManagement;

  String _formattedDate() {
    final now = DateTime.now();
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${pad(now.day)}/${pad(now.month)}/${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: DashboardColors.toolbarBackground,
      shape: const RoundedRectangleBorder(),
      width: 380,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      businessName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w400),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(color: DashboardColors.border, height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _MenuItem(
                    icon: Icons.build_outlined,
                    label: 'Management',
                    onTap: onOpenManagement,
                  ),
                  const Divider(color: DashboardColors.border, height: 1, indent: 20, endIndent: 20),
                  const SizedBox(height: 8),
                  _MenuItem(
                    icon: Icons.fact_check_outlined,
                    label: 'View sales history',
                    onTap: () => onAction('View sales history'),
                  ),
                  _MenuItem(
                    icon: Icons.layers_outlined,
                    label: 'View open sales',
                    onTap: () => onAction('View open sales'),
                  ),
                  _MenuItem(
                    icon: Icons.move_to_inbox_outlined,
                    label: 'Cash In / Out',
                    onTap: () => onAction('Cash In / Out'),
                  ),
                  _MenuItem(
                    icon: Icons.edit_note_outlined,
                    label: 'Credit payments',
                    onTap: () => onAction('Credit payments'),
                  ),
                  _MenuItem(
                    icon: Icons.directions_run_outlined,
                    label: 'End of day',
                    onTap: () => onAction('End of day'),
                  ),
                  const _SectionLabel('User'),
                  _MenuItem(
                    icon: Icons.person_outline,
                    label: 'User info',
                    onTap: () => onAction('User info'),
                  ),
                  _MenuItem(
                    icon: Icons.logout_outlined,
                    label: 'Sign out',
                    onTap: onSignOut,
                  ),
                  const SizedBox(height: 24),
                  _MenuItem(
                    icon: Icons.campaign_outlined,
                    label: 'Feedback',
                    onTap: () => onAction('Feedback'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                _formattedDate(),
                style: const TextStyle(color: DashboardColors.textMuted, fontSize: 13),
              ),
            ),
            const Divider(color: DashboardColors.border, height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.tune, color: Colors.white),
                    onPressed: () => onAction('Settings'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.fullscreen, color: Colors.white),
                    onPressed: () => onAction('Fullscreen'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.power_settings_new, color: Colors.white),
                    onPressed: () => onAction('Power'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(color: DashboardColors.textMuted, fontSize: 12, letterSpacing: 0.5),
          ),
          const SizedBox(width: 10),
          const Expanded(child: Divider(color: DashboardColors.border, height: 1)),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 16),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
