import 'package:flutter/material.dart';

import '../../../models/held_order.dart';
import '../../../models/service_type.dart';
import '../../../utils/currency.dart';
import '../dashboard_colors.dart';

/// What the user picked on the Open orders screen: an existing held order,
/// or a request to create a brand new one as the transfer destination.
class OrderSelection {
  const OrderSelection.existing(this.orderNumber) : isNew = false;
  const OrderSelection.createNew()
      : orderNumber = null,
        isNew = true;

  final int? orderNumber;
  final bool isNew;
}

/// Lists currently parked/open orders so one can be picked as a transfer
/// destination, or a brand new order can be started for the same purpose.
class OpenOrdersScreen extends StatefulWidget {
  const OpenOrdersScreen({super.key, required this.orders});

  final List<HeldOrder> orders;

  @override
  State<OpenOrdersScreen> createState() => _OpenOrdersScreenState();
}

class _OpenOrdersScreenState extends State<OpenOrdersScreen> {
  int? _selected;

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
                  'Open orders',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w300),
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
              border: Border(bottom: BorderSide(color: DashboardColors.accentBlue, width: 2)),
            ),
            child: const Row(
              children: [
                Expanded(flex: 2, child: Text('Order / Customer name', style: TextStyle(color: Colors.white))),
                Expanded(flex: 2, child: Text('Total', style: TextStyle(color: Colors.white))),
                Expanded(flex: 2, child: Text('Service type', style: TextStyle(color: Colors.white))),
                Expanded(flex: 3, child: Text('Customer', style: TextStyle(color: Colors.white))),
              ],
            ),
          ),
          Expanded(
            child: widget.orders.isEmpty
                ? const Center(
                    child: Text('No open orders', style: TextStyle(color: DashboardColors.textMuted)),
                  )
                : ListView.builder(
                    itemCount: widget.orders.length,
                    itemBuilder: (context, index) {
                      final order = widget.orders[index];
                      final isSelected = order.orderNumber == _selected;
                      return InkWell(
                        onTap: () => setState(() => _selected = order.orderNumber),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? DashboardColors.accentBlue : null,
                            border: const Border(bottom: BorderSide(color: DashboardColors.border)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(order.displayName, style: const TextStyle(color: Colors.white)),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  formatCurrency(order.total),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  order.serviceType == ServiceType.dineIn ? 'Dine-in' : 'Takeaway',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  (order.customer == null || order.customer!.isWalkIn)
                                      ? '-'
                                      : order.customer!.name,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
                OutlinedButton.icon(
                  onPressed: _selected == null
                      ? null
                      : () => Navigator.of(context).pop(OrderSelection.existing(_selected!)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    disabledForegroundColor: DashboardColors.textMuted,
                    side: const BorderSide(color: DashboardColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Select order'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(const OrderSelection.createNew()),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: DashboardColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New sale'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
