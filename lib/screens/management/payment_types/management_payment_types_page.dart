import 'package:flutter/material.dart';

import '../../dashboard/dashboard_colors.dart';

/// Cash, Card, and Check are always enabled for quick payment, don't require
/// a customer, mark the transaction paid immediately, and print a receipt —
/// only [changeAllowed] differs (only cash makes sense to hand change back
/// for), so that's the only flag modeled per instance.
class _PaymentType {
  const _PaymentType({required this.name, required this.position, this.changeAllowed = false});

  final String name;
  final int position;
  final bool changeAllowed;
}

/// The Management area's "Payment types" section. Cash/Card/Check are the
/// built-in payment methods the sales screen's shortcut bar already offers,
/// shown here with their default behavior flags (e.g. only cash allows
/// giving change). There's no add/edit-payment-type feature yet, so those
/// stay wired to a "coming soon" notice.
class ManagementPaymentTypesPage extends StatefulWidget {
  const ManagementPaymentTypesPage({super.key});

  @override
  State<ManagementPaymentTypesPage> createState() => _ManagementPaymentTypesPageState();
}

class _ManagementPaymentTypesPageState extends State<ManagementPaymentTypesPage> {
  static const _paymentTypes = [
    _PaymentType(name: 'Cash', position: 1, changeAllowed: true),
    _PaymentType(name: 'Card', position: 2),
    _PaymentType(name: 'Check', position: 3),
  ];

  int? _selectedIndex;

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$feature coming soon.')));
  }

  static const _columns = <(String, double)>[
    ('Name', 200),
    ('Position', 90),
    ('Code', 90),
    ('Enabled', 90),
    ('Quick payment', 120),
    ('Customer required', 150),
    ('Change allowed', 130),
    ('Mark transaction as paid', 190),
    ('Print receipt', 120),
    ('Shortcut key', 120),
  ];

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
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _ToolbarButton(icon: Icons.refresh, label: 'Refresh', onTap: () => setState(() {})),
                _ToolbarButton(
                  icon: Icons.add,
                  label: 'New payment type',
                  onTap: () => _showComingSoon('Adding a payment type'),
                ),
                _ToolbarButton(
                  icon: Icons.edit_outlined,
                  label: 'Edit',
                  onTap: hasSelection ? () => _showComingSoon('Editing a payment type') : null,
                ),
                const _ToolbarButton(icon: Icons.delete_outline, label: 'Delete', onTap: null),
                _ToolbarButton(icon: Icons.help_outline, label: 'Help', onTap: () => _showComingSoon('Help')),
              ],
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: _columns.fold<double>(0, (sum, c) => sum + c.$2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 36,
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: DashboardColors.accentBlue, width: 2)),
                    ),
                    child: Row(
                      children: [
                        for (final column in _columns)
                          _Cell(
                            width: column.$2,
                            child: Text(
                              column.$1,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ),
                      ],
                    ),
                  ),
                  for (var i = 0; i < _paymentTypes.length; i++)
                    _PaymentTypeRow(
                      paymentType: _paymentTypes[i],
                      selected: _selectedIndex == i,
                      onTap: () => setState(() => _selectedIndex = i),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PaymentTypeRow extends StatelessWidget {
  const _PaymentTypeRow({required this.paymentType, required this.selected, required this.onTap});

  final _PaymentType paymentType;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(color: Colors.white, fontSize: 14);
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 40,
        color: selected ? DashboardColors.accentBlue.withValues(alpha: 0.25) : null,
        child: Row(
          children: [
            _Cell(width: 200, child: Text(paymentType.name, style: style)),
            _Cell(width: 90, child: Text('${paymentType.position}', style: style)),
            const _Cell(width: 90, child: SizedBox.shrink()),
            const _Cell(width: 90, child: _FlagIcon(true)),
            const _Cell(width: 120, child: _FlagIcon(true)),
            const _Cell(width: 150, child: _FlagIcon(false)),
            _Cell(width: 130, child: _FlagIcon(paymentType.changeAllowed)),
            const _Cell(width: 190, child: _FlagIcon(true)),
            const _Cell(width: 120, child: _FlagIcon(true)),
            const _Cell(width: 120, child: SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}

class _FlagIcon extends StatelessWidget {
  const _FlagIcon(this.value);

  final bool value;

  @override
  Widget build(BuildContext context) {
    if (!value) return const SizedBox.shrink();
    return const Icon(Icons.check, color: Colors.white, size: 18);
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.width, required this.child});

  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Align(alignment: Alignment.centerLeft, child: child),
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
            SizedBox(
              width: 90,
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: color, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
