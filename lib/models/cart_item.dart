import 'product.dart';

class CartItem {
  CartItem({required this.product, this.quantity = 1, this.round = 1});

  final Product product;
  int quantity;
  final int round;

  double get lineTotal => product.price * quantity;
}
