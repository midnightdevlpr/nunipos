import 'package:flutter/material.dart';

import '../../../models/cart_item.dart';
import '../../../models/product.dart';
import '../../../utils/currency.dart';
import '../dashboard_colors.dart';

class _RoundSummary {
  _RoundSummary({required this.round, required this.items});

  final int round;
  final List<CartItem> items;

  double get total => items.fold(0, (sum, item) => sum + item.lineTotal);
  Map<Product, int> get quantities => {
        for (final item in items) item.product: item.quantity,
      };
}

/// Groups the order's items by round and lets whole rounds be checked off
/// as a quick way to select everything for a round at once, instead of
/// moving each line individually.
class SelectRoundsScreen extends StatefulWidget {
  const SelectRoundsScreen({super.key, required this.items});

  final List<CartItem> items;

  @override
  State<SelectRoundsScreen> createState() => _SelectRoundsScreenState();
}

class _SelectRoundsScreenState extends State<SelectRoundsScreen> {
  late final List<_RoundSummary> _rounds = _groupByRound(widget.items);
  late final Set<int> _selected = {for (final r in _rounds) r.round};

  List<_RoundSummary> _groupByRound(List<CartItem> items) {
    final byRound = <int, List<CartItem>>{};
    for (final item in items) {
      byRound.putIfAbsent(item.round, () => []).add(item);
    }
    final rounds = byRound.entries.map((e) => _RoundSummary(round: e.key, items: e.value)).toList();
    rounds.sort((a, b) => a.round.compareTo(b.round));
    return rounds;
  }

  double get _subtotal => widget.items.fold(0, (sum, item) => sum + item.lineTotal);

  void _confirm() {
    final quantities = <Product, int>{};
    for (final round in _rounds) {
      if (!_selected.contains(round.round)) continue;
      round.quantities.forEach((product, qty) {
        quantities[product] = (quantities[product] ?? 0) + qty;
      });
    }
    Navigator.of(context).pop(quantities);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DashboardColors.background,
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    alignment: Alignment.centerLeft,
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(color: DashboardColors.border),
                        bottom: BorderSide(color: DashboardColors.border),
                      ),
                    ),
                    child: const Text(
                      'Order Items',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w300),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    alignment: Alignment.centerLeft,
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: DashboardColors.border)),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Select rounds to transfer',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w300),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: widget.items.length,
                          itemBuilder: (context, index) {
                            final item = widget.items[index];
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide(color: DashboardColors.border)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.product.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${item.quantity} x ${formatCurrency(item.product.price)}',
                                          style: const TextStyle(color: DashboardColors.textMuted, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    formatCurrency(item.lineTotal),
                                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const Divider(color: DashboardColors.border, height: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Column(
                          children: [
                            _TotalRow(label: 'Subtotal', value: formatCurrency(_subtotal)),
                            const _TotalRow(label: 'Tax', value: '0.00'),
                            const Divider(color: DashboardColors.border, height: 16),
                            _TotalRow(
                              label: 'Total',
                              value: formatCurrency(_subtotal),
                              bold: true,
                              fontSize: 22,
                              color: DashboardColors.accentBlue,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1, color: DashboardColors.border),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _ActionBox(
                              icon: Icons.check_box_outlined,
                              label: 'Select all',
                              onTap: () => setState(() => _selected.addAll(_rounds.map((r) => r.round))),
                            ),
                            const SizedBox(width: 12),
                            _ActionBox(
                              icon: Icons.indeterminate_check_box_outlined,
                              label: 'Select none',
                              onTap: () => setState(_selected.clear),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        for (final round in _rounds)
                          InkWell(
                            onTap: () => setState(() {
                              if (_selected.contains(round.round)) {
                                _selected.remove(round.round);
                              } else {
                                _selected.add(round.round);
                              }
                            }),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                    value: _selected.contains(round.round),
                                    activeColor: DashboardColors.accentBlue,
                                    onChanged: (checked) => setState(() {
                                      if (checked ?? false) {
                                        _selected.add(round.round);
                                      } else {
                                        _selected.remove(round.round);
                                      }
                                    }),
                                  ),
                                  Text(
                                    '#${round.round} (${formatCurrency(round.total)})',
                                    style: const TextStyle(color: Colors.white, fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: DashboardColors.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: _selected.isEmpty ? null : _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DashboardColors.accentGreen,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: DashboardColors.accentGreen.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('OK'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DashboardColors.accentRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBox extends StatelessWidget {
  const _ActionBox({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: DashboardColors.border),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.fontSize = 15,
    this.color = Colors.white,
  });

  final String label;
  final String value;
  final bool bold;
  final double fontSize;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final weight = bold ? FontWeight.bold : FontWeight.normal;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white, fontSize: fontSize, fontWeight: weight),
            ),
          ),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(value, style: TextStyle(color: color, fontSize: fontSize, fontWeight: weight)),
            ),
          ),
        ],
      ),
    );
  }
}
