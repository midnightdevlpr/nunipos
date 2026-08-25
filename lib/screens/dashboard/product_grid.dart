import 'dart:io';

import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../models/product_colors.dart';
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
    final background = productColors[product.color];
    final isTinted = background != null && background.a > 0;
    final contentColor = isTinted && background.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    final nameColor = isTinted ? contentColor : Colors.white;
    final priceColor = isTinted ? contentColor.withValues(alpha: 0.75) : DashboardColors.textMuted;
    final iconColor = isTinted ? contentColor : DashboardColors.accentGreen;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        decoration: BoxDecoration(
          color: isTinted ? background : null,
          border: Border.all(color: DashboardColors.border),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (product.imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.file(
                  File(product.imagePath!),
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(product.icon, color: iconColor, size: 40),
                ),
              )
            else
              Icon(product.icon, color: iconColor, size: 40),
            const SizedBox(height: 10),
            Text(
              product.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: nameColor, fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              formatCurrency(product.price),
              style: TextStyle(color: priceColor, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
