import 'package:flutter/material.dart';

import 'dashboard_colors.dart';

class ToolbarAction {
  const ToolbarAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.shortcut,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final String? shortcut;
  final bool highlighted;
  final VoidCallback onTap;
}

/// The full-width row of primary actions at the top of the sales dashboard,
/// split into a general-actions group and a checkout-shortcuts group.
class DashboardToolbar extends StatelessWidget {
  const DashboardToolbar({
    super.key,
    required this.primaryActions,
    required this.shortcutActions,
    required this.onMenuTap,
  });

  final List<ToolbarAction> primaryActions;
  final List<ToolbarAction> shortcutActions;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: DashboardColors.toolbarBackground,
        border: Border(
          top: BorderSide(color: DashboardColors.border),
          bottom: BorderSide(color: DashboardColors.border),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final action in primaryActions) _ToolbarButton(action: action),
                  const _GroupGap(),
                  for (final action in shortcutActions) _ToolbarButton(action: action),
                ],
              ),
            ),
          ),
          const _GroupGap(),
          _IconOnlyButton(icon: Icons.menu, onTap: onMenuTap),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({required this.action});

  final ToolbarAction action;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (action.shortcut != null)
          Text(
            action.shortcut!,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          )
        else
          Icon(action.icon, color: Colors.white, size: 22),
        const SizedBox(height: 4),
        Text(action.label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );

    return InkWell(
      onTap: action.onTap,
      child: Container(
        width: 96,
        height: 92,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: action.highlighted ? DashboardColors.accentGreen : null,
          border: const Border(right: BorderSide(color: DashboardColors.border)),
        ),
        child: content,
      ),
    );
  }
}

/// A wider gap between logical groups of toolbar buttons.
class _GroupGap extends StatelessWidget {
  const _GroupGap();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 92,
      child: Center(
        child: Container(width: 1, height: 60, color: DashboardColors.border),
      ),
    );
  }
}

class _IconOnlyButton extends StatelessWidget {
  const _IconOnlyButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 92,
        alignment: Alignment.center,
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}
