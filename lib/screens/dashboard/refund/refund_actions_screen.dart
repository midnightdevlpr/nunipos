import 'package:flutter/material.dart';

import '../../../models/cart_item.dart';
import '../../../models/refund_payment_type.dart';
import '../../../utils/currency.dart';
import '../dashboard_colors.dart';

enum _ReceiptAction { printReceipt, printInvoice, sendEmail, savePdf }

/// Step 2 of the refund flow: shows the receipt breakdown and lets the
/// cashier pick how the customer gets it.
class RefundActionsScreen extends StatefulWidget {
  const RefundActionsScreen({
    super.key,
    required this.items,
    required this.originalSubtotal,
    required this.discountedTotal,
    required this.hasDiscount,
    required this.paymentType,
  });

  final List<CartItem> items;
  final double originalSubtotal;
  final double discountedTotal;
  final bool hasDiscount;
  final RefundPaymentType paymentType;

  @override
  State<RefundActionsScreen> createState() => _RefundActionsScreenState();
}

class _RefundActionsScreenState extends State<RefundActionsScreen> {
  _ReceiptAction _selected = _ReceiptAction.printReceipt;
  bool _dontShowAgain = false;
  String? _note;

  Future<void> _addNotes() async {
    final controller = TextEditingController(text: _note ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DashboardColors.toolbarBackground,
        title: const Text('Add notes', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null) setState(() => _note = result.isEmpty ? null : result);
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
                      border: Border(right: BorderSide(color: DashboardColors.border), bottom: BorderSide(color: DashboardColors.border)),
                    ),
                    child: const Text('Items', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w300)),
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
                          child: Text('Actions', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w300)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(false),
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
                SizedBox(width: 390, child: _ReceiptBreakdown(items: widget.items, hasDiscount: widget.hasDiscount, originalSubtotal: widget.originalSubtotal, discountedTotal: widget.discountedTotal, paymentType: widget.paymentType)),
                const VerticalDivider(width: 1, color: DashboardColors.border),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Column(
                      children: [
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Icon(Icons.assignment_return_outlined, color: Colors.white, size: 36),
                            const SizedBox(width: 12),
                            const Text('Refund: ', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w300)),
                            Text(
                              formatCurrency(widget.originalSubtotal),
                              style: const TextStyle(color: DashboardColors.accentRed, fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'How would the customer like their receipt?',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w300),
                        ),
                        const SizedBox(height: 32),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            _ActionTile(
                              icon: Icons.receipt_long_outlined,
                              label: 'Print receipt',
                              selected: _selected == _ReceiptAction.printReceipt,
                              onTap: () => setState(() => _selected = _ReceiptAction.printReceipt),
                            ),
                            _ActionTile(
                              icon: Icons.print_outlined,
                              label: 'Print invoice',
                              selected: _selected == _ReceiptAction.printInvoice,
                              onTap: () => setState(() => _selected = _ReceiptAction.printInvoice),
                            ),
                            _ActionTile(
                              icon: Icons.email_outlined,
                              label: 'Send email',
                              selected: _selected == _ReceiptAction.sendEmail,
                              onTap: () => setState(() => _selected = _ReceiptAction.sendEmail),
                            ),
                            _ActionTile(
                              icon: Icons.picture_as_pdf_outlined,
                              label: 'Save as PDF',
                              selected: _selected == _ReceiptAction.savePdf,
                              onTap: () => setState(() => _selected = _ReceiptAction.savePdf),
                            ),
                            _ActionTile(
                              icon: Icons.edit_outlined,
                              label: 'Add notes',
                              selected: false,
                              onTap: _addNotes,
                            ),
                          ],
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
              children: [
                InkWell(
                  onTap: () => setState(() => _dontShowAgain = !_dontShowAgain),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: _dontShowAgain,
                        activeThumbColor: DashboardColors.accentGreen,
                        onChanged: (value) => setState(() => _dontShowAgain = value),
                      ),
                      const SizedBox(width: 4),
                      const Text("Don't show this again", style: TextStyle(color: Colors.white, fontSize: 13)),
                    ],
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DashboardColors.accentGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  ),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptBreakdown extends StatelessWidget {
  const _ReceiptBreakdown({
    required this.items,
    required this.hasDiscount,
    required this.originalSubtotal,
    required this.discountedTotal,
    required this.paymentType,
  });

  final List<CartItem> items;
  final bool hasDiscount;
  final double originalSubtotal;
  final double discountedTotal;
  final RefundPaymentType paymentType;

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
        const Divider(color: DashboardColors.border, height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              if (hasDiscount)
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    formatCurrency(originalSubtotal),
                    style: const TextStyle(color: DashboardColors.textMuted, fontSize: 13, decoration: TextDecoration.lineThrough),
                  ),
                ),
              _TotalRow(label: 'Subtotal', value: formatCurrency(discountedTotal)),
              const _TotalRow(label: 'Tax', value: '0.00'),
              const Divider(color: DashboardColors.border, height: 16),
              _TotalRow(label: 'Total', value: formatCurrency(discountedTotal), bold: true, fontSize: 22),
              const Divider(color: DashboardColors.border, height: 16),
              _TotalRow(label: '${paymentType.label}:', value: formatCurrency(discountedTotal)),
            ],
          ),
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
    final style = TextStyle(color: Colors.white, fontSize: fontSize, fontWeight: bold ? FontWeight.bold : FontWeight.normal);
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

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.label, required this.selected, required this.onTap});

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 220,
        height: 120,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: selected ? DashboardColors.accentBlue : DashboardColors.border, width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
