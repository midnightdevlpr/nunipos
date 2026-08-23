enum DiscountUnit { percent, fixed }

/// A discount applied to the whole cart, either as a percentage off or a
/// flat amount off the subtotal.
class CartDiscount {
  const CartDiscount({required this.unit, required this.value});

  final DiscountUnit unit;
  final double value;

  /// The multiplier to apply to each item's price to get its discounted
  /// price, proportionally allocating a flat [DiscountUnit.fixed] amount
  /// across the whole subtotal.
  double ratioFor(double subtotal) {
    if (unit == DiscountUnit.percent) {
      return (1 - value / 100).clamp(0, 1);
    }
    if (subtotal <= 0) return 1;
    return ((subtotal - value).clamp(0, subtotal)) / subtotal;
  }

  double discountedSubtotal(double subtotal) => subtotal * ratioFor(subtotal);
}
