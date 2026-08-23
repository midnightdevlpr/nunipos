import 'package:flutter/material.dart';

import '../../../models/cart_discount.dart';
import '../../../models/cart_item.dart';
import '../dashboard_colors.dart';

/// The "Apply cart discount" popup: a percent/fixed-amount toggle, a custom
/// numeric keypad (there's no assumption of a physical keyboard on a POS
/// terminal), and a below-cost-price confirmation before applying.
class DiscountDialog extends StatefulWidget {
  const DiscountDialog({
    super.key,
    required this.cartItems,
    required this.subtotal,
    required this.onApply,
    required this.onClear,
  });

  final List<CartItem> cartItems;
  final double subtotal;
  final ValueChanged<CartDiscount> onApply;
  final VoidCallback onClear;

  @override
  State<DiscountDialog> createState() => _DiscountDialogState();
}

class _DiscountDialogState extends State<DiscountDialog>
    with SingleTickerProviderStateMixin {
  late final _tabController = TabController(length: 2, vsync: this);
  DiscountUnit _unit = DiscountUnit.percent;
  String _buffer = '0';

  void _tapDigit(String digit) {
    setState(() {
      if (_buffer == '0' && digit != '.') {
        _buffer = digit;
      } else if (digit == '.' && _buffer.contains('.')) {
        // ignore a second decimal point
      } else {
        _buffer += digit;
      }
    });
  }

  void _backspace() {
    setState(() {
      _buffer = _buffer.length > 1
          ? _buffer.substring(0, _buffer.length - 1)
          : '0';
    });
  }

  Future<bool?> _confirmBelowCost(List<String> itemNames) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: DashboardColors.toolbarBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Invalid price',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Sale price of the following items is below their cost price: '
                        '${itemNames.join(', ')}. Selling with price below the cost price '
                        'will result in a negative profit.',
                        style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Are you sure you wish to continue?',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: DashboardColors.border),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            ),
                            child: const Text('Yes'),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: DashboardColors.border),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            ),
                            child: const Text('No'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onEnter() async {
    if (_tabController.index == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item discount isn\'t available yet.')),
      );
      return;
    }

    final value = double.tryParse(_buffer) ?? 0;
    final discount = CartDiscount(unit: _unit, value: value);
    final ratio = discount.ratioFor(widget.subtotal);
    final belowCost = widget.cartItems
        .where(
          (item) =>
              item.product.cost > 0 &&
              item.product.price * ratio < item.product.cost,
        )
        .map((item) => item.product.name)
        .toSet()
        .toList();

    if (belowCost.isNotEmpty) {
      final proceed = await _confirmBelowCost(belowCost);
      if (proceed != true) return;
    }

    widget.onApply(discount);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: DashboardColors.toolbarBackground,
      alignment: Alignment.topCenter,
      insetPadding: const EdgeInsets.only(top: 90),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TabBar(
                controller: _tabController,
                labelColor: DashboardColors.accentBlue,
                unselectedLabelColor: Colors.white70,
                indicatorColor: DashboardColors.accentBlue,
                labelStyle: const TextStyle(fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontSize: 13),
                labelPadding: const EdgeInsets.symmetric(vertical: 8),
                tabs: const [
                  Tab(text: 'Cart discount'),
                  Tab(text: 'Item discount'),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Apply cart discount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _UnitButton(
                            label: '%',
                            selected: _unit == DiscountUnit.percent,
                            onTap: () =>
                                setState(() => _unit = DiscountUnit.percent),
                          ),
                        ),
                        Expanded(
                          child: _UnitButton(
                            label: 'Ksh',
                            selected: _unit == DiscountUnit.fixed,
                            onTap: () =>
                                setState(() => _unit = DiscountUnit.fixed),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Discount',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _buffer,
                          style: const TextStyle(
                            color: DashboardColors.accentBlue,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _unit == DiscountUnit.percent ? '%' : 'Ksh',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: DashboardColors.border, height: 16),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: SizedBox(
                  height: 180,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _padKey('1', () => _tapDigit('1')),
                            _padKey('4', () => _tapDigit('4')),
                            _padKey('7', () => _tapDigit('7')),
                            _padKey('-', () => _tapDigit('-')),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            _padKey('2', () => _tapDigit('2')),
                            _padKey('5', () => _tapDigit('5')),
                            _padKey('8', () => _tapDigit('8')),
                            _padKey('0', () => _tapDigit('0')),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            _padKey('3', () => _tapDigit('3')),
                            _padKey('6', () => _tapDigit('6')),
                            _padKey('9', () => _tapDigit('9')),
                            _padKey('.', () => _tapDigit('.')),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            _padKey(
                              null,
                              _backspace,
                              icon: Icons.backspace_outlined,
                              flex: 1,
                            ),
                            _padKey(
                              'esc',
                              () => Navigator.of(context).pop(),
                              flex: 1,
                            ),
                            _padKey(
                              null,
                              _onEnter,
                              icon: Icons.keyboard_return,
                              flex: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  widget.onClear();
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: DashboardColors.border),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_outline, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Clear discounts',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _padKey(
    String? label,
    VoidCallback onTap, {
    IconData? icon,
    int flex = 1,
  }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: InkWell(
          onTap: onTap,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: DashboardColors.border),
              borderRadius: BorderRadius.circular(2),
            ),
            child: icon != null
                ? Icon(icon, color: Colors.white, size: 18)
                : Text(
                    label ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
          ),
        ),
      ),
    );
  }
}

class _UnitButton extends StatelessWidget {
  const _UnitButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? DashboardColors.accentBlue : null,
          border: Border.all(
            color: selected
                ? DashboardColors.accentBlue
                : DashboardColors.border,
          ),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
