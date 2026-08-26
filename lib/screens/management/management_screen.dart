import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../dashboard/dashboard_colors.dart';
import 'management_dashboard_page.dart';
import 'products/management_products_page.dart';
import 'promotions/management_promotions_page.dart';
import 'stock/management_stock_page.dart';
import 'users/management_users_page.dart';

class ManagementSection {
  const ManagementSection({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

const List<ManagementSection> managementSections = [
  ManagementSection(icon: Icons.dashboard_outlined, label: 'Dashboard'),
  ManagementSection(icon: Icons.description_outlined, label: 'Documents'),
  ManagementSection(icon: Icons.sell_outlined, label: 'Products'),
  ManagementSection(icon: Icons.price_change_outlined, label: 'Price lists'),
  ManagementSection(icon: Icons.inventory_2_outlined, label: 'Stock'),
  ManagementSection(icon: Icons.bar_chart_outlined, label: 'Reporting'),
  ManagementSection(icon: Icons.people_outline, label: 'Customers & suppliers'),
  ManagementSection(icon: Icons.favorite_border, label: 'Promotions'),
  ManagementSection(icon: Icons.vpn_key_outlined, label: 'Users & security'),
  ManagementSection(icon: Icons.credit_card_outlined, label: 'Payment types'),
  ManagementSection(icon: Icons.public, label: 'Countries'),
  ManagementSection(icon: Icons.percent, label: 'Tax rates'),
  ManagementSection(icon: Icons.apartment_outlined, label: 'My company'),
];

/// The Management area opened from the side menu: its own sidebar of
/// sections plus a content area. Only "Dashboard" has a built-out page for
/// now; the rest show a placeholder until their features are specified.
class ManagementScreen extends StatefulWidget {
  const ManagementScreen({
    super.key,
    required this.products,
    required this.onAddProduct,
    required this.onUpdateProduct,
    required this.onDeleteProduct,
  });

  final List<Product> products;
  final ValueChanged<Product> onAddProduct;
  final void Function(int index, Product product) onUpdateProduct;
  final ValueChanged<int> onDeleteProduct;

  @override
  State<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> {
  int _selectedIndex = 0;
  bool _sidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final selected = managementSections[_selectedIndex];

    return Scaffold(
      backgroundColor: DashboardColors.background,
      body: Column(
        children: [
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: DashboardColors.border)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Text.rich(
                  TextSpan(
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                    children: [
                      const TextSpan(text: 'Management', style: TextStyle(fontWeight: FontWeight.w600)),
                      TextSpan(text: '  •  ${selected.label}', style: const TextStyle(color: DashboardColors.textMuted)),
                    ],
                  ),
                ),
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
                _Sidebar(
                  collapsed: _sidebarCollapsed,
                  selectedIndex: _selectedIndex,
                  onSelect: (index) => setState(() => _selectedIndex = index),
                  onToggleCollapse: () => setState(() => _sidebarCollapsed = !_sidebarCollapsed),
                ),
                const VerticalDivider(width: 1, color: DashboardColors.border),
                Expanded(child: _buildContent(_selectedIndex, selected)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(int index, ManagementSection selected) {
    switch (index) {
      case 0:
        return const ManagementDashboardPage();
      case 2:
        return ManagementProductsPage(
          products: widget.products,
          onAddProduct: widget.onAddProduct,
          onUpdateProduct: widget.onUpdateProduct,
          onDeleteProduct: widget.onDeleteProduct,
        );
      case 4:
        return ManagementStockPage(products: widget.products);
      case 7:
        return const ManagementPromotionsPage();
      case 8:
        return const ManagementUsersPage();
      default:
        return Center(
          child: Text(
            '${selected.label} coming soon.',
            style: const TextStyle(color: DashboardColors.textMuted, fontSize: 16),
          ),
        );
    }
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.collapsed,
    required this.selectedIndex,
    required this.onSelect,
    required this.onToggleCollapse,
  });

  final bool collapsed;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onToggleCollapse;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: collapsed ? 64 : 275,
      color: DashboardColors.toolbarBackground,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: managementSections.length,
              itemBuilder: (context, index) {
                final section = managementSections[index];
                final isSelected = index == selectedIndex;
                return InkWell(
                  onTap: () => onSelect(index),
                  child: Container(
                    color: isSelected ? DashboardColors.accentBlue : null,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Row(
                      children: [
                        Icon(section.icon, color: Colors.white, size: 20),
                        if (!collapsed) ...[
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              section.label,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(color: DashboardColors.border, height: 1),
          IconButton(
            icon: Icon(collapsed ? Icons.chevron_right : Icons.chevron_left, color: Colors.white),
            onPressed: onToggleCollapse,
          ),
        ],
      ),
    );
  }
}
