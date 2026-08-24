import 'package:flutter/material.dart';

import '../../models/search_mode.dart';
import 'dashboard_colors.dart';

/// Full-width bar below the primary toolbar: cart quick-actions on the left
/// (aligned with the cart panel's width) and product search/filters on the
/// right (aligned with the product grid).
class DashboardSecondaryBar extends StatelessWidget {
  const DashboardSecondaryBar({
    super.key,
    required this.cartPanelWidth,
    required this.searchController,
    required this.searchMode,
    required this.onSearchModeChanged,
    required this.onDelete,
    required this.onQuantity,
    required this.onDash,
    required this.onIconAction,
    required this.onOpenSearch,
  });

  final double cartPanelWidth;
  final TextEditingController searchController;
  final SearchMode searchMode;
  final ValueChanged<SearchMode> onSearchModeChanged;
  final VoidCallback onDelete;
  final VoidCallback onQuantity;
  final VoidCallback onDash;
  final ValueChanged<String> onIconAction;
  final VoidCallback onOpenSearch;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: DashboardColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: cartPanelWidth,
            child: Row(
              children: [
                Expanded(child: _HeaderBox(icon: Icons.close, label: 'Delete', onTap: onDelete)),
                Expanded(child: _HeaderBox(label: 'Quantity', selected: true, onTap: onQuantity)),
                Expanded(child: _HeaderBox(label: '---', onTap: onDash)),
              ],
            ),
          ),
          const VerticalDivider(width: 1, color: DashboardColors.border),
          Expanded(
            child: Row(
              children: [
                _IconChip(
                  glyph: '*',
                  highlighted: searchMode == SearchMode.all,
                  onTap: () => onSearchModeChanged(SearchMode.all),
                ),
                _IconChip(
                  icon: Icons.qr_code_scanner,
                  highlighted: searchMode == SearchMode.barcode,
                  onTap: () => onSearchModeChanged(SearchMode.barcode),
                ),
                _IconChip(
                  icon: Icons.tag,
                  highlighted: searchMode == SearchMode.code,
                  onTap: () => onSearchModeChanged(SearchMode.code),
                ),
                _IconChip(
                  icon: Icons.sell_outlined,
                  highlighted: searchMode == SearchMode.name,
                  onTap: () => onSearchModeChanged(SearchMode.name),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    cursorColor: DashboardColors.accentGreen,
                    decoration: InputDecoration(
                      hintText: searchMode.hintText,
                      hintStyle: const TextStyle(color: DashboardColors.textMuted),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                _IconChip(icon: Icons.search, onTap: onOpenSearch),
                _IconChip(icon: Icons.keyboard_alt_outlined, onTap: () => onIconAction('Virtual keyboard')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderBox extends StatelessWidget {
  const _HeaderBox({required this.label, required this.onTap, this.icon, this.selected = false});

  final IconData? icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: selected ? Colors.white70 : DashboardColors.border),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  const _IconChip({this.icon, this.glyph, required this.onTap, this.highlighted = false})
      : assert(icon != null || glyph != null);

  final IconData? icon;
  final String? glyph;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = highlighted ? DashboardColors.accentBlue : Colors.white;
    return IconButton(
      icon: icon != null
          ? Icon(icon, color: color, size: 20)
          : Text(glyph!, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
      onPressed: onTap,
    );
  }
}
