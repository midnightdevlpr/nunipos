import 'package:flutter/material.dart';

import '../models/cart_discount.dart';
import '../models/cart_item.dart';
import '../models/customer.dart';
import '../models/held_order.dart';
import '../models/product.dart';
import '../models/service_type.dart';
import '../services/auth_service.dart';
import 'dashboard/cart_panel.dart';
import 'dashboard/customer/customer_search_screen.dart';
import 'dashboard/dashboard_colors.dart';
import 'dashboard/discount/discount_dialog.dart';
import 'dashboard/dashboard_secondary_bar.dart';
import 'dashboard/dashboard_status_bar.dart';
import 'dashboard/dashboard_toolbar.dart';
import 'dashboard/new_sale/order_name_screen.dart';
import 'dashboard/new_sale/service_type_screen.dart';
import 'dashboard/product_grid.dart';
import 'dashboard/product_search_screen.dart';
import 'dashboard/transfer/transfer_screen.dart';
import 'login_screen.dart';

/// The main sales screen shown after login/registration.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _products = [
    Product(
      name: 'Dola Oil 5 litres',
      price: 5120.00,
      icon: Icons.local_shipping_outlined,
      description: 'Dola Oil',
      code: 'DOLA5L',
      barcode: '0000000001',
      quantityOnHand: 1,
      quantityUnit: 'Litres',
      cost: 5000.00,
    ),
  ];

  final _searchController = TextEditingController();
  final List<CartItem> _cart = [];
  ServiceType _serviceType = ServiceType.dineIn;
  String _orderName = '';
  Customer? _customer;
  final List<Customer> _customers = [];
  final List<HeldOrder> _heldOrders = [];
  int _nextOrderNumber = 1;
  CartDiscount? _cartDiscount;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> get _filteredProducts {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _products;
    return _products.where((p) => p.name.toLowerCase().contains(query)).toList();
  }

  double get _subtotal => _cart.fold(0, (sum, item) => sum + item.lineTotal);
  double get _discountedSubtotal =>
      _cartDiscount?.discountedSubtotal(_subtotal) ?? _subtotal;
  // Placeholder until tax settings from the registration wizard are wired up.
  double get _tax => 0;
  double get _total => _discountedSubtotal + _tax;

  void _addToCart(Product product) {
    setState(() {
      final existing = _cart.where((item) => item.product == product);
      if (existing.isNotEmpty) {
        existing.first.quantity++;
      } else {
        _cart.add(CartItem(product: product));
      }
    });
  }

  void _removeCartItem(int index) {
    setState(() => _cart.removeAt(index));
  }

  void _voidOrder() {
    setState(() {
      _cart.clear();
      _cartDiscount = null;
    });
  }

  void _openDiscountDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => DiscountDialog(
        cartItems: _cart,
        subtotal: _subtotal,
        onApply: (discount) => setState(() => _cartDiscount = discount),
        onClear: () => setState(() => _cartDiscount = null),
      ),
    );
  }

  Future<void> _startNewSale() async {
    final orderName = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const OrderNameScreen()),
    );
    if (orderName == null || !mounted) return;

    final serviceType = await Navigator.of(context).push<ServiceType>(
      MaterialPageRoute(builder: (_) => ServiceTypeScreen(initial: _serviceType)),
    );
    if (serviceType == null || !mounted) return;

    setState(() {
      _cart.clear();
      _cartDiscount = null;
      _orderName = orderName;
      _serviceType = serviceType;
    });
  }

  Future<void> _changeServiceType() async {
    final serviceType = await Navigator.of(context).push<ServiceType>(
      MaterialPageRoute(builder: (_) => ServiceTypeScreen(initial: _serviceType)),
    );
    if (serviceType != null) setState(() => _serviceType = serviceType);
  }

  Future<void> _openCustomerSearch() async {
    final selected = await Navigator.of(context).push<Customer>(
      MaterialPageRoute(
        builder: (_) => CustomerSearchScreen(
          customers: _customers,
          initial: _customer ?? Customer.walkIn,
        ),
      ),
    );
    if (selected == null) return;
    setState(() {
      _customer = selected;
      if (!selected.isWalkIn && !_customers.contains(selected)) {
        _customers.add(selected);
      }
    });
  }

  int _createNewHeldOrder() {
    final orderNumber = _nextOrderNumber++;
    _heldOrders.add(HeldOrder(orderNumber: orderNumber, items: [], serviceType: _serviceType));
    return orderNumber;
  }

  void _saveSale() {
    if (_cart.isEmpty) {
      _showComingSoon('Nothing to save');
      return;
    }
    setState(() {
      final orderNumber = _nextOrderNumber++;
      _heldOrders.add(
        HeldOrder(
          orderNumber: orderNumber,
          items: _cart.map((item) => CartItem(product: item.product, quantity: item.quantity)).toList(),
          serviceType: _serviceType,
          customer: _customer,
          orderName: _orderName,
        ),
      );
      _cart.clear();
      _orderName = '';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order #${_heldOrders.last.orderNumber} saved.')),
    );
  }

  Future<void> _openTransfer() async {
    final result = await Navigator.of(context).push<TransferResult>(
      MaterialPageRoute(
        builder: (_) => TransferScreen(
          items: _cart,
          heldOrders: _heldOrders,
          onCreateNewOrder: _createNewHeldOrder,
        ),
      ),
    );
    if (result == null) return;

    setState(() {
      final destination = _heldOrders.firstWhere((order) => order.orderNumber == result.orderNumber);
      result.quantities.forEach((product, moved) {
        final cartIndex = _cart.indexWhere((item) => item.product == product);
        if (cartIndex == -1) return;
        final remaining = _cart[cartIndex].quantity - moved;
        if (remaining <= 0) {
          _cart.removeAt(cartIndex);
        } else {
          _cart[cartIndex].quantity = remaining;
        }

        final destIndex = destination.items.indexWhere((item) => item.product == product);
        if (destIndex == -1) {
          destination.items.add(CartItem(product: product, quantity: moved));
        } else {
          destination.items[destIndex].quantity += moved;
        }
      });
    });

    if (!mounted) return;
    final authorizedBy = result.authorizedBy;
    final message = authorizedBy == null
        ? 'Transferred to order #${result.orderNumber}.'
        : 'Transferred to order #${result.orderNumber} (authorized by $authorizedBy).';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openSearch() async {
    final selected = await Navigator.of(context).push<Product>(
      MaterialPageRoute(builder: (_) => ProductSearchScreen(products: _products)),
    );
    if (selected != null) _addToCart(selected);
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature coming soon.')),
    );
  }

  void _logout() {
    AuthService.instance.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showMenu() {
    showMenu<void>(
      context: context,
      position: const RelativeRect.fromLTRB(1000, 60, 16, 0),
      items: [
        PopupMenuItem<void>(
          onTap: _logout,
          child: const Text('Sign out'),
        ),
      ],
    );
  }

  static const _cartPanelWidth = 400.0;

  @override
  Widget build(BuildContext context) {
    final primaryActions = [
      ToolbarAction(icon: Icons.search, label: 'Search', onTap: _openSearch),
      ToolbarAction(
        icon: Icons.person_outline,
        label: (_customer == null || _customer!.isWalkIn) ? 'Customer' : _customer!.name,
        onTap: _openCustomerSearch,
      ),
      ToolbarAction(icon: Icons.swap_horiz, label: 'Transfer', onTap: _openTransfer),
      ToolbarAction(icon: Icons.percent, label: 'Discount', onTap: _openDiscountDialog),
      ToolbarAction(icon: Icons.add, label: 'New sale', onTap: _startNewSale),
      ToolbarAction(icon: Icons.assignment_return_outlined, label: 'Refund', onTap: () => _showComingSoon('Refund')),
      ToolbarAction(icon: Icons.badge_outlined, label: '---', onTap: () => _showComingSoon('This action')),
      ToolbarAction(icon: Icons.inbox_outlined, label: 'Cash drawer', onTap: () => _showComingSoon('Cash drawer')),
      ToolbarAction(
        icon: _serviceType == ServiceType.dineIn ? Icons.event_seat_outlined : Icons.shopping_bag_outlined,
        label: _serviceType == ServiceType.dineIn ? 'Dine-in' : 'Takeaway',
        onTap: _changeServiceType,
      ),
    ];
    final shortcutActions = [
      ToolbarAction(icon: Icons.save_outlined, label: 'Save sale', shortcut: 'F9', onTap: _saveSale),
      ToolbarAction(
        icon: Icons.payment,
        label: 'Payment',
        shortcut: 'F10',
        highlighted: true,
        onTap: () => _showComingSoon('Payment'),
      ),
      ToolbarAction(icon: Icons.money, label: 'Cash', shortcut: 'F12', onTap: () => _showComingSoon('Cash payment')),
      ToolbarAction(icon: Icons.credit_card, label: 'Card', onTap: () => _showComingSoon('Card payment')),
      ToolbarAction(icon: Icons.receipt_long_outlined, label: 'Check', onTap: () => _showComingSoon('Check payment')),
    ];

    return Scaffold(
      backgroundColor: DashboardColors.background,
      body: Column(
        children: [
          DashboardToolbar(
            primaryActions: primaryActions,
            shortcutActions: shortcutActions,
            onMenuTap: _showMenu,
          ),
          DashboardSecondaryBar(
            cartPanelWidth: _cartPanelWidth,
            searchController: _searchController,
            onDelete: () => _showComingSoon('Delete'),
            onQuantity: () => _showComingSoon('Quantity'),
            onDash: () => _showComingSoon('This action'),
            onIconAction: _showComingSoon,
            onOpenSearch: _openSearch,
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: _cartPanelWidth,
                  child: CartPanel(
                    items: _cart,
                    subtotal: _discountedSubtotal,
                    originalSubtotal: _cartDiscount != null ? _subtotal : null,
                    tax: _tax,
                    total: _total,
                    orderName: _orderName,
                    onRemoveItem: _removeCartItem,
                    onVoidOrder: _voidOrder,
                    onLock: () => _showComingSoon('Lock'),
                    onRepeatRound: () => _showComingSoon('Repeat round'),
                  ),
                ),
                const VerticalDivider(width: 1, color: DashboardColors.border),
                Expanded(
                  child: ProductGrid(products: _filteredProducts, onProductTap: _addToCart),
                ),
              ],
            ),
          ),
          DashboardStatusBar(currentPage: 1, totalPages: 1, onAction: _showComingSoon),
        ],
      ),
    );
  }
}
