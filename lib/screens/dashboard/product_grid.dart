import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../utils/currency.dart';
import 'dashboard_colors.dart';

/// Right-hand panel: the grid of sellable products (searching/filtering
/// lives in the shared secondary bar above).
class ProductGrid extends StatelessWidget {
  const ProductGrid({super.key, required this.products, required this.onProductTap});

  final List<Product> products;
  final ValueChanged<Product> onProductTap;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Center(
        child: Text('No products found', style: TextStyle(color: DashboardColors.textMuted)),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisExtent: 150,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _ProductCard(product: product, onTap: () => onProductTap(product));
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: DashboardColors.border),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(product.icon, color: DashboardColors.accentGreen, size: 40),
            const SizedBox(height: 10),
            Text(
              product.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              formatCurrency(product.price),
              style: const TextStyle(color: DashboardColors.textMuted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
