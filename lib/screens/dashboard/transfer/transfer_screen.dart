import 'package:flutter/material.dart';

import '../../../models/cart_item.dart';
import '../../../models/held_order.dart';
import '../../../models/product.dart';
import '../../../services/auth_service.dart';
import '../../../utils/currency.dart';
import '../dashboard_colors.dart';
import 'open_orders_screen.dart';
import 'select_rounds_screen.dart';
import 'user_password_screen.dart';

/// Result of a confirmed transfer: how many units of each product were
/// moved out of the current order, the destination order number, and who
/// (if anyone) re-authenticated to authorize it.
class TransferResult {
  const TransferResult({required this.quantities, required this.orderNumber, this.authorizedBy});

  final Map<Product, int> quantities;
  final int orderNumber;
  final String? authorizedBy;
}

/// Lets the user move some or all quantity of the current order's line items
/// out to a destination order number, picked from currently open orders (or
/// a brand new one). Whole rounds can be moved at once via "Transfer
/// rounds" as a shortcut to selecting each line individually.
class TransferScreen extends StatefulWidget {
  const TransferScreen({
    super.key,
    required this.items,
    required this.heldOrders,
    required this.onCreateNewOrder,
  });

  final List<CartItem> items;
  final List<HeldOrder> heldOrders;
  final int Function() onCreateNewOrder;

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  late final Map<Product, int> _left = {
    for (final item in widget.items) item.product: item.quantity,
  };
  final Map<Product, int> _right = {};

  Product? _selectedLeft;
  Product? _selectedRight;
  int? _orderNumber;
  String? _authorizedBy;

  late final int _totalUnits = widget.items.fold(0, (sum, item) => sum + item.quantity);

  bool get _canConfirm => _right.isNotEmpty && _orderNumber != null;

  void _moveRight(Product product, int amount) {
    setState(() {
      final available = _left[product] ?? 0;
      final moved = amount.clamp(0, available);
      if (moved <= 0) return;

      final remaining = available - moved;
      if (remaining <= 0) {
        _left.remove(product);
        if (_selectedLeft == product) _selectedLeft = null;
      } else {
        _left[product] = remaining;
      }
      _right[product] = (_right[product] ?? 0) + moved;
    });
  }

  void _moveLeft(Product product, int amount) {
    setState(() {
      final available = _right[product] ?? 0;
      final moved = amount.clamp(0, available);
      if (moved <= 0) return;

      final remaining = available - moved;
      if (remaining <= 0) {
        _right.remove(product);
        if (_selectedRight == product) _selectedRight = null;
      } else {
        _right[product] = remaining;
      }
      _left[product] = (_left[product] ?? 0) + moved;
    });
  }

  void _moveAllRight() {
    setState(() {
      for (final entry in _left.entries.toList()) {
        _right[entry.key] = (_right[entry.key] ?? 0) + entry.value;
      }
      _left.clear();
      _selectedLeft = null;
    });
  }

  void _moveAllLeft() {
    setState(() {
      for (final entry in _right.entries.toList()) {
        _left[entry.key] = (_left[entry.key] ?? 0) + entry.value;
      }
      _right.clear();
      _selectedRight = null;
    });
  }

  Future<void> _editTransferQuantity() async {
    final product = _selectedLeft;
    if (product == null) return;
    final available = _left[product] ?? 0;
    final controller = TextEditingController(text: available.toString());

    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DashboardColors.toolbarBackground,
        title: const Text('Quantity to transfer', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            helperText: 'Available: $available',
            helperStyle: const TextStyle(color: DashboardColors.textMuted),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final value = int.tryParse(controller.text.trim());
              Navigator.of(context).pop(value);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (result != null && result > 0) _moveRight(product, result);
  }

  Future<void> _selectOrderNumber() async {
    final selection = await Navigator.of(context).push<OrderSelection>(
      MaterialPageRoute(builder: (_) => OpenOrdersScreen(orders: widget.heldOrders)),
    );
    if (selection == null) return;

    final orderNumber = selection.isNew ? widget.onCreateNewOrder() : selection.orderNumber;
    if (orderNumber != null) setState(() => _orderNumber = orderNumber);
  }

  Future<void> _authorizeUser() async {
    final confirmed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const UserPasswordScreen()),
    );
    if (confirmed == true) {
      setState(() => _authorizedBy = AuthService.instance.currentUser.value?.name);
    }
  }

  Future<void> _selectRounds() async {
    final quantities = await Navigator.of(context).push<Map<Product, int>>(
      MaterialPageRoute(builder: (_) => SelectRoundsScreen(items: widget.items)),
    );
    if (quantities == null) return;
    quantities.forEach((product, qty) => _moveRight(product, qty));
  }

  void _notAvailable(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature isn\'t available yet.')),
    );
  }

  void _confirm() {
    if (!_canConfirm) return;
    Navigator.of(context).pop(
      TransferResult(quantities: Map.of(_right), orderNumber: _orderNumber!, authorizedBy: _authorizedBy),
    );
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
                Text(
                  'Transfer ($_totalUnits)',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w300),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: DashboardColors.border)),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text('Order items', style: TextStyle(color: DashboardColors.accentBlue, fontSize: 15)),
                ),
                const SizedBox(width: 90),
                const Expanded(
                  child: Text(
                    'Selected items for transfer',
                    style: TextStyle(color: DashboardColors.accentBlue, fontSize: 15),
                  ),
                ),
                const SizedBox(width: 230),
              ],
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _ItemList(
                    quantities: _left,
                    selected: _selectedLeft,
                    onSelect: (p) => setState(() => _selectedLeft = p),
                  ),
                ),
                SizedBox(
                  width: 90,
                  child: _TransferControls(
                    canMoveOneRight: _selectedLeft != null && (_left[_selectedLeft] ?? 0) > 0,
                    canMoveAllRight: _left.isNotEmpty,
                    canEditQuantity: _selectedLeft != null,
                    canMoveOneLeft: _selectedRight != null && (_right[_selectedRight] ?? 0) > 0,
                    canMoveAllLeft: _right.isNotEmpty,
                    onMoveOneRight: () => _moveRight(_selectedLeft!, 1),
                    onMoveAllRight: _moveAllRight,
                    onEditQuantity: _editTransferQuantity,
                    onMoveOneLeft: () => _moveLeft(_selectedRight!, 1),
                    onMoveAllLeft: _moveAllLeft,
                  ),
                ),
                const VerticalDivider(width: 1, color: DashboardColors.border),
                Expanded(
                  child: _ItemList(
                    quantities: _right,
                    selected: _selectedRight,
                    onSelect: (p) => setState(() => _selectedRight = p),
                  ),
                ),
                const VerticalDivider(width: 1, color: DashboardColors.border),
                SizedBox(
                  width: 230,
                  child: _TransferSidebar(
                    orderNumber: _orderNumber,
                    authorizedBy: _authorizedBy,
                    onSelectOrder: _selectOrderNumber,
                    onUser: _authorizeUser,
                    onTransferAll: _moveAllRight,
                    onRemoveAll: _moveAllLeft,
                    onTransferRounds: _selectRounds,
                    onOpenOrders: _selectOrderNumber,
                    onTransferAllOrders: () => _notAvailable('Transfer all orders'),
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

class _ItemList extends StatelessWidget {
  const _ItemList({required this.quantities, required this.selected, required this.onSelect});

  final Map<Product, int> quantities;
  final Product? selected;
  final ValueChanged<Product> onSelect;

  @override
  Widget build(BuildContext context) {
    final entries = quantities.entries.where((e) => e.value > 0).toList();
    if (entries.isEmpty) return const SizedBox.shrink();

    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final isSelected = entry.key == selected;
        return InkWell(
          onTap: () => onSelect(entry.key),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? DashboardColors.accentBlue : null,
              border: const Border(bottom: BorderSide(color: DashboardColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key.name,
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '#1 ${entry.value}x${formatCurrency(entry.key.price)}',
                        style: const TextStyle(color: DashboardColors.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Text(
                  formatCurrency(entry.key.price * entry.value),
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TransferControls extends StatelessWidget {
  const _TransferControls({
    required this.canMoveOneRight,
    required this.canMoveAllRight,
    required this.canEditQuantity,
    required this.canMoveOneLeft,
    required this.canMoveAllLeft,
    required this.onMoveOneRight,
    required this.onMoveAllRight,
    required this.onEditQuantity,
    required this.onMoveOneLeft,
    required this.onMoveAllLeft,
  });

  final bool canMoveOneRight;
  final bool canMoveAllRight;
  final bool canEditQuantity;
  final bool canMoveOneLeft;
  final bool canMoveAllLeft;
  final VoidCallback onMoveOneRight;
  final VoidCallback onMoveAllRight;
  final VoidCallback onEditQuantity;
  final VoidCallback onMoveOneLeft;
  final VoidCallback onMoveAllLeft;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StepButton(
          label: '1',
          icon: Icons.chevron_right,
          enabled: canMoveOneRight,
          onTap: onMoveOneRight,
        ),
        const SizedBox(height: 8),
        _IconOnlyButton(
          icon: Icons.keyboard_double_arrow_right,
          enabled: canMoveAllRight,
          onTap: onMoveAllRight,
        ),
        const SizedBox(height: 24),
        _EditButton(enabled: canEditQuantity, onTap: onEditQuantity),
        const SizedBox(height: 24),
        _StepButton(
          label: '1',
          icon: Icons.chevron_left,
          reversed: true,
          enabled: canMoveOneLeft,
          onTap: onMoveOneLeft,
        ),
        const SizedBox(height: 8),
        _IconOnlyButton(
          icon: Icons.keyboard_double_arrow_left,
          enabled: canMoveAllLeft,
          onTap: onMoveAllLeft,
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.onTap,
    this.reversed = false,
  });

  final String label;
  final IconData icon;
  final bool enabled;
  final bool reversed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? Colors.white : DashboardColors.textMuted;
    final children = [
      Text(label, style: TextStyle(color: color, fontSize: 15)),
      Icon(icon, color: color, size: 20),
    ];
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: reversed ? children.reversed.toList() : children,
        ),
      ),
    );
  }
}

class _IconOnlyButton extends StatelessWidget {
  const _IconOnlyButton({required this.icon, required this.enabled, required this.onTap});

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: enabled ? Colors.white : DashboardColors.textMuted),
      onPressed: enabled ? onTap : null,
    );
  }
}

class _EditButton extends StatelessWidget {
  const _EditButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled ? Colors.white : DashboardColors.border,
        ),
        child: Icon(Icons.edit, size: 18, color: enabled ? Colors.black87 : DashboardColors.textMuted),
      ),
    );
  }
}

class _TransferSidebar extends StatelessWidget {
  const _TransferSidebar({
    required this.orderNumber,
    required this.authorizedBy,
    required this.onSelectOrder,
    required this.onUser,
    required this.onTransferAll,
    required this.onRemoveAll,
    required this.onTransferRounds,
    required this.onOpenOrders,
    required this.onTransferAllOrders,
  });

  final int? orderNumber;
  final String? authorizedBy;
  final VoidCallback onSelectOrder;
  final VoidCallback onUser;
  final VoidCallback onTransferAll;
  final VoidCallback onRemoveAll;
  final VoidCallback onTransferRounds;
  final VoidCallback onOpenOrders;
  final VoidCallback onTransferAllOrders;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Order number', style: TextStyle(color: Colors.white, fontSize: 14)),
              const Spacer(),
              if (orderNumber == null)
                const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18)
              else
                Text(
                  orderNumber!.toString(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _SidebarButton(icon: Icons.grid_view, label: 'Select order', onTap: onSelectOrder),
          const SizedBox(height: 8),
          _SidebarButton(
            icon: Icons.people_alt_outlined,
            label: authorizedBy ?? 'User',
            onTap: onUser,
          ),
          const SizedBox(height: 32),
          _SidebarButton(icon: Icons.arrow_forward, label: 'Transfer all', onTap: onTransferAll),
          const SizedBox(height: 8),
          _SidebarButton(icon: Icons.arrow_back, label: 'Remove all', onTap: onRemoveAll),
          const SizedBox(height: 8),
          _SidebarButton(icon: Icons.layers_outlined, label: 'Transfer rounds', onTap: onTransferRounds),
          const SizedBox(height: 8),
          _SidebarButton(icon: Icons.grid_view, label: 'Open orders', onTap: onOpenOrders),
          const SizedBox(height: 8),
          _SidebarButton(
            icon: Icons.people_outline,
            label: 'Transfer all orders',
            onTap: onTransferAllOrders,
            enabled: false,
          ),
        ],
      ),
    );
  }
}

class _SidebarButton extends StatelessWidget {
  const _SidebarButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? Colors.white : DashboardColors.textMuted;
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: DashboardColors.border),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: color, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
