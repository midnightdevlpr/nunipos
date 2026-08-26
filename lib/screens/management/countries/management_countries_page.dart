import 'package:flutter/material.dart';

import '../../../models/country_codes.dart';
import '../../dashboard/dashboard_colors.dart';

/// The Management area's "Countries" section: a reference list of every
/// ISO 3166-1 country and its 2-letter code. This is standard reference
/// data (not business data), so it's shown in full rather than the
/// representative subset used by the customer form's country picker.
class ManagementCountriesPage extends StatefulWidget {
  const ManagementCountriesPage({super.key});

  @override
  State<ManagementCountriesPage> createState() => _ManagementCountriesPageState();
}

class _ManagementCountriesPageState extends State<ManagementCountriesPage> {
  int? _selectedIndex;

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$feature coming soon.')));
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = _selectedIndex != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: DashboardColors.border)),
          ),
          child: Row(
            children: [
              _ToolbarButton(icon: Icons.refresh, label: 'Refresh', onTap: () => setState(() {})),
              _ToolbarButton(
                icon: Icons.add,
                label: 'New country',
                onTap: () => _showComingSoon('Adding a country'),
              ),
              _ToolbarButton(
                icon: Icons.edit_outlined,
                label: 'Edit',
                onTap: hasSelection ? () => _showComingSoon('Editing a country') : null,
              ),
              const _ToolbarButton(icon: Icons.delete_outline, label: 'Delete', onTap: null),
            ],
          ),
        ),
        const _TableHeader(),
        Expanded(
          child: ListView.builder(
            itemCount: countryCodes.length,
            itemBuilder: (context, index) {
              final country = countryCodes[index];
              final selected = _selectedIndex == index;
              return InkWell(
                onTap: () => setState(() => _selectedIndex = index),
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  color: selected ? DashboardColors.accentBlue.withValues(alpha: 0.25) : null,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          country.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          country.code,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600);
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: DashboardColors.accentBlue, width: 2)),
      ),
      child: const Row(
        children: [
          Expanded(flex: 4, child: Text('Name', style: style)),
          Expanded(flex: 1, child: Text('Code', style: style)),
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
