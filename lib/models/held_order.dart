import 'cart_item.dart';
import 'customer.dart';
import 'service_type.dart';

/// An order that's been parked (saved) or created as a transfer destination,
/// separate from whatever the active cart currently holds.
class HeldOrder {
  HeldOrder({
    required this.orderNumber,
    required this.items,
    required this.serviceType,
    this.customer,
    this.orderName = '',
  });

  final int orderNumber;
  final List<CartItem> items;
  final ServiceType serviceType;
  final Customer? customer;
  final String orderName;

  String get displayName => orderName.isNotEmpty ? orderName : orderNumber.toString();
  double get total => items.fold(0, (sum, item) => sum + item.lineTotal);
}
