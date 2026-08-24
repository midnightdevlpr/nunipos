import 'package:flutter/material.dart';

import '../../../models/cart_item.dart';
import '../../../models/refund_payment_type.dart';
import '../../../utils/currency.dart';
import '../dashboard_colors.dart';
import 'refund_actions_screen.dart';

/// Step 1 of the refund flow: pick a receipt number and payment type for
/// the refund, then hand off to [RefundActionsScreen] to pick how the
/// customer gets their receipt.
class RefundScreen extends StatefulWidget {
  const RefundScreen({
    super.key,
    required this.items,
    required this.originalSubtotal,
    required this.discountedTotal,
    required this.hasDiscount,
  });

  final List<CartItem> items;
  final double originalSubtotal;
  final double discountedTotal;
  final bool hasDiscount;

  @override
  State<RefundScreen> createState() => _RefundScreenState();
}

class _RefundScreenState extends State<RefundScreen> {
  final _receiptController = TextEditingController();
  RefundPaymentType _paymentType = RefundPaymentType.cash;

  @override
  void initState() {
    super.initState();
    _receiptController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _receiptController.dispose();
    super.dispose();
  }

  bool get _canConfirm => _receiptController.text.trim().isNotEmpty;

  Future<void> _confirm() async {
    if (!_canConfirm) return;
    final done = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => RefundActionsScreen(
          items: widget.items,
          originalSubtotal: widget.originalSubtotal,
          discountedTotal: widget.discountedTotal,
          hasDiscount: widget.hasDiscount,
          paymentType: _paymentType,
        ),
      ),
    );
    if (done == true && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DashboardColors.background,
      body: Column(
        children: [
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: DashboardColors.border)),
            ),
            child: Row(
              children: [
                const Text(
                  'Refund items',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w300),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: 390, child: _ItemsSummary(items: widget.items, hasDiscount: widget.hasDiscount, discountedTotal: widget.discountedTotal)),
                const VerticalDivider(width: 1, color: DashboardColors.border),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.assignment_return_outlined, color: Colors.white, size: 44),
                          const SizedBox(height: 16),
                          const Text(
                            'Enter receipt number and payment type to confirm refund',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300),
                          ),
                          const SizedBox(height: 24),
                          const SizedBox(width: 150, child: Divider(color: DashboardColors.border)),
                          const SizedBox(height: 24),
                          const Text('Receipt number', style: TextStyle(color: DashboardColors.accentBlue, fontSize: 13)),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 390,
                            child: TextField(
                              controller: _receiptController,
                              autofocus: true,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                              cursorColor: DashboardColors.accentBlue,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: DashboardColors.background,
                                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: DashboardColors.border)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: DashboardColors.border)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: DashboardColors.accentBlue, width: 2)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text('Refund payment type', style: TextStyle(color: Colors.white, fontSize: 14)),
                          const SizedBox(height: 12),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              for (final type in RefundPaymentType.values)
                                _PaymentTypeButton(
                                  type: type,
                                  selected: _paymentType == type,
                                  onTap: () => setState(() => _paymentType = type),
                                ),
                            ],
                          ),
                        ],
                      ),
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
                  onPressed: _canConfirm ? _confirm : null,
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
                  onPressed: () => Navigator.of(context).pop(false),
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

class _ItemsSummary extends StatelessWidget {
  const _ItemsSummary({required this.items, required this.hasDiscount, required this.discountedTotal});

  final List<CartItem> items;
  final bool hasDiscount;
  final double discountedTotal;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
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
                          Text(item.product.name, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                          Text(
                            '${item.quantity} x ${formatCurrency(item.product.price)}',
                            style: const TextStyle(color: DashboardColors.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Text(formatCurrency(item.lineTotal), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            },
          ),
        ),
        if (hasDiscount)
          Container(
            width: double.infinity,
            color: DashboardColors.accentBlue,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text('Cart discount applied', style: TextStyle(color: Colors.white, fontSize: 13)),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'TOTAL REFUND AMOUNT',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    '-${formatCurrency(discountedTotal)}',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentTypeButton extends StatelessWidget {
  const _PaymentTypeButton({required this.type, required this.selected, required this.onTap});

  final RefundPaymentType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 130,
            height: 70,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? DashboardColors.accentBlue : null,
              border: Border.all(color: selected ? DashboardColors.accentBlue : DashboardColors.border),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              type.label.toUpperCase(),
              style: TextStyle(color: Colors.white, fontWeight: selected ? FontWeight.bold : FontWeight.normal),
            ),
          ),
          if (selected)
            Positioned(
              top: -10,
              left: -10,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: DashboardColors.accentBlue),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
            ),
        ],
      ),
    );
  }
}
