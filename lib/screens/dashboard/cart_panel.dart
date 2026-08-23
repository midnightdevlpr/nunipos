import 'package:flutter/material.dart';

import '../../models/cart_item.dart';
import '../../utils/currency.dart';
import 'dashboard_colors.dart';

/// Left-hand panel: current sale's line items and totals.
class CartPanel extends StatelessWidget {
  const CartPanel({
    super.key,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.onRemoveItem,
    required this.onVoidOrder,
    required this.onLock,
    required this.onRepeatRound,
    this.orderName = '',
    this.originalSubtotal,
  });

  final List<CartItem> items;
  final double subtotal;
  final double tax;
  final double total;
  final ValueChanged<int> onRemoveItem;
  final VoidCallback onVoidOrder;
  final VoidCallback onLock;
  final VoidCallback onRepeatRound;
  final String orderName;
  final double? originalSubtotal;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (orderName.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: DashboardColors.border)),
            ),
            child: Text(
              orderName,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        Expanded(
          child: items.isEmpty
              ? const Center(
                  child: Text('No items', style: TextStyle(color: DashboardColors.textMuted, fontSize: 16)),
                )
              : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Container(
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: DashboardColors.border)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close, color: DashboardColors.accentRed, size: 18),
                            onPressed: () => onRemoveItem(index),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.name,
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                ),
                                Text(
                                  '${item.quantity}x ${formatCurrency(item.product.price)}',
                                  style: const TextStyle(color: DashboardColors.textMuted, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            formatCurrency(item.lineTotal),
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        const Divider(color: DashboardColors.border, height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            children: [
              if (originalSubtotal != null && originalSubtotal! > subtotal)
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    formatCurrency(originalSubtotal!),
                    style: const TextStyle(
                      color: DashboardColors.textMuted,
                      fontSize: 13,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ),
              _TotalRow(label: 'Subtotal', value: formatCurrency(subtotal)),
              _TotalRow(label: 'Tax', value: formatCurrency(tax)),
              const Divider(color: DashboardColors.border, height: 16),
              _TotalRow(
                label: 'Total',
                value: formatCurrency(total),
                bold: true,
                fontSize: 22,
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _BottomActionButton(
                icon: Icons.delete_outline,
                label: 'Void order',
                filled: true,
                onTap: items.isEmpty ? null : onVoidOrder,
              ),
            ),
            Expanded(
              child: _BottomActionButton(icon: Icons.lock_outline, label: 'Lock', onTap: onLock),
            ),
            Expanded(
              child: _BottomActionButton(
                icon: Icons.repeat,
                label: 'Repeat round',
                onTap: onRepeatRound,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.label, required this.value, this.bold = false, this.fontSize = 15});

  final String label;
  final String value;
  final bool bold;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: Colors.white,
      fontSize: fontSize,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}

class _BottomActionButton extends StatelessWidget {
  const _BottomActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: filled ? (onTap == null ? DashboardColors.accentRed.withValues(alpha: 0.4) : DashboardColors.accentRed) : null,
          border: const Border(top: BorderSide(color: DashboardColors.border)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
