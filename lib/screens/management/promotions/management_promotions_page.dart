import 'package:flutter/material.dart';

import '../../dashboard/dashboard_colors.dart';

/// The Management area's "Promotions" section. There's no promotions
/// feature/backend yet, so this honestly shows the real empty state rather
/// than fabricated sample promotions; creating one is wired to a "coming
/// soon" notice until that feature is specified.
class ManagementPromotionsPage extends StatefulWidget {
  const ManagementPromotionsPage({super.key});

  @override
  State<ManagementPromotionsPage> createState() => _ManagementPromotionsPageState();
}

class _ManagementPromotionsPageState extends State<ManagementPromotionsPage> {
  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$feature coming soon.')));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Toolbar(onRefresh: () => setState(() {}), onComingSoon: _showComingSoon),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.visibility_off_outlined, size: 64, color: DashboardColors.textMuted),
                const SizedBox(height: 20),
                const Text(
                  'No promotions',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _showComingSoon('Creating a promotion'),
                  child: const Text(
                    'Create new promotion',
                    style: TextStyle(color: DashboardColors.accentBlue, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.onRefresh, required this.onComingSoon});

  final VoidCallback onRefresh;
  final ValueChanged<String> onComingSoon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: DashboardColors.border)),
      ),
      child: Row(
        children: [
          _ToolbarButton(icon: Icons.refresh, label: 'Refresh', onTap: onRefresh),
          _ToolbarButton(
            icon: Icons.add,
            label: 'Add promotion',
            onTap: () => onComingSoon('Creating a promotion'),
          ),
          const _ToolbarButton(icon: Icons.edit_outlined, label: 'Edit', onTap: null),
          const _ToolbarButton(icon: Icons.delete_outline, label: 'Delete', onTap: null),
          _ToolbarButton(icon: Icons.help_outline, label: 'Help', onTap: () => onComingSoon('Help')),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final color = enabled ? Colors.white : DashboardColors.textMuted;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
