import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../utils/currency.dart';
import 'dashboard_colors.dart';

/// Full-screen product search: filter by name, product code, or barcode,
/// preview the match, and confirm to add it to the sale.
class ProductSearchScreen extends StatefulWidget {
  const ProductSearchScreen({super.key, required this.products});

  final List<Product> products;

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _barcodeController = TextEditingController();

  Product? _selected;

  @override
  void initState() {
    super.initState();
    for (final controller in [_nameController, _codeController, _barcodeController]) {
      controller.addListener(_onQueryChanged);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  void _onQueryChanged() => setState(() {});

  List<Product> get _results {
    final name = _nameController.text.trim().toLowerCase();
    final code = _codeController.text.trim().toLowerCase();
    final barcode = _barcodeController.text.trim().toLowerCase();

    return widget.products.where((product) {
      if (name.isNotEmpty && !product.name.toLowerCase().contains(name)) return false;
      if (code.isNotEmpty && !product.code.toLowerCase().contains(code)) return false;
      if (barcode.isNotEmpty && !product.barcode.toLowerCase().contains(barcode)) return false;
      return true;
    }).toList();
  }

  void _select(Product product) => setState(() => _selected = product);

  void _confirm() {
    if (_selected == null) return;
    Navigator.of(context).pop(_selected);
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;

    return Scaffold(
      backgroundColor: DashboardColors.background,
      body: Column(
        children: [
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: DashboardColors.border)),
            ),
            child: Row(
              children: [
                const Text('Search', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w300)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
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
                    children: [
                      _SearchField(controller: _nameController, hint: 'Search', autofocus: true),
                      _SearchField(controller: _codeController, hint: 'Product code'),
                      _SearchField(controller: _barcodeController, hint: 'Barcode'),
                      const Divider(color: DashboardColors.border, height: 1),
                      Expanded(
                        child: ListView.builder(
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            final product = results[index];
                            final isSelected = product == _selected;
                            return InkWell(
                              onTap: () => _select(product),
                              child: Container(
                                width: double.infinity,
                                color: isSelected ? DashboardColors.accentBlue : null,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Text(
                                  product.name,
                                  style: const TextStyle(color: Colors.white, fontSize: 15),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1, color: DashboardColors.border),
                Expanded(
                  child: _selected == null
                      ? const Center(
                          child: Text(
                            'Select a product to see details',
                            style: TextStyle(color: DashboardColors.textMuted),
                          ),
                        )
                      : _ProductDetail(product: _selected!, formatCurrency: formatCurrency),
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
                  onPressed: _selected == null ? null : _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DashboardColors.accentGreen,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: DashboardColors.accentGreen.withValues(alpha: 0.4),
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

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.hint, this.autofocus = false});

  final TextEditingController controller;
  final String hint;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: DashboardColors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.search, color: DashboardColors.textMuted, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: autofocus,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              cursorColor: DashboardColors.accentBlue,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: DashboardColors.textMuted),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              if (controller.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.close, color: DashboardColors.textMuted, size: 18),
                onPressed: controller.clear,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProductDetail extends StatelessWidget {
  const _ProductDetail({required this.product, required this.formatCurrency});

  final Product product;
  final String Function(double) formatCurrency;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _DetailRow(label: 'Price:', value: formatCurrency(product.price), bold: true),
          const SizedBox(height: 6),
          _DetailRow(label: 'Description:', value: product.description),
          Expanded(
            child: Center(
              child: Icon(product.icon, size: 160, color: DashboardColors.accentGreen),
            ),
          ),
          const Divider(color: DashboardColors.border),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    children: [
                      const TextSpan(text: 'Quantity on hand: '),
                      TextSpan(
                        text: '${product.quantityOnHand} ${product.quantityUnit}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 140,
          child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
