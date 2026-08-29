import 'package:flutter/material.dart';

import '../../../models/product.dart';
import '../../../models/search_mode.dart';
import '../../../utils/currency.dart';
import '../../dashboard/dashboard_colors.dart';
import '../products/print_dialog.dart';

/// The Management area's "Price lists" section. There's no multi-price-list
/// feature yet, so this shows the one implicit price list ("Products") that
/// already exists — the same prices/markup the Products module and the POS
/// dashboard use — rather than fabricating additional lists.
class ManagementPriceListsPage extends StatefulWidget {
  const ManagementPriceListsPage({super.key, required this.products});

  final List<Product> products;

  @override
  State<ManagementPriceListsPage> createState() => _ManagementPriceListsPageState();
}

class _ManagementPriceListsPageState extends State<ManagementPriceListsPage> {
  final _searchController = TextEditingController();
  SearchMode _searchMode = SearchMode.all;

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

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$feature coming soon.')));
  }

  List<Product> get _filtered {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return widget.products;
    return widget.products.where((p) {
      switch (_searchMode) {
        case SearchMode.all:
          return p.name.toLowerCase().contains(query) ||
              p.code.toLowerCase().contains(query) ||
              p.barcode.toLowerCase().contains(query);
        case SearchMode.barcode:
          return p.barcode.toLowerCase().contains(query);
        case SearchMode.code:
          return p.code.toLowerCase().contains(query);
        case SearchMode.name:
          return p.name.toLowerCase().contains(query);
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Toolbar(onRefresh: () => setState(() {}), onComingSoon: _showComingSoon),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(
                width: 260,
                child: Column(
                  children: [
                    Expanded(
                      child: _SideList(
                        title: 'Price lists',
                        subtitle: 'Select product prices or price list to edit',
                        icon: Icons.sell_outlined,
                        itemLabel: 'Products',
                      ),
                    ),
                    Divider(color: DashboardColors.border, height: 1),
                    Expanded(
                      child: _SideList(
                        title: 'Product groups',
                        subtitle: 'Filter items by product groups',
                        icon: Icons.folder_outlined,
                        itemLabel: 'Products',
                      ),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(width: 1, color: DashboardColors.border),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 48,
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: DashboardColors.border)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        children: [
                          _SearchModeChip(
                            glyph: '*',
                            highlighted: _searchMode == SearchMode.all,
                            onTap: () => setState(() => _searchMode = SearchMode.all),
                          ),
                          _SearchModeChip(
                            icon: Icons.qr_code_scanner,
                            highlighted: _searchMode == SearchMode.barcode,
                            onTap: () => setState(() => _searchMode = SearchMode.barcode),
                          ),
                          _SearchModeChip(
                            icon: Icons.tag,
                            highlighted: _searchMode == SearchMode.code,
                            onTap: () => setState(() => _searchMode = SearchMode.code),
                          ),
                          _SearchModeChip(
                            icon: Icons.sell_outlined,
                            highlighted: _searchMode == SearchMode.name,
                            onTap: () => setState(() => _searchMode = SearchMode.name),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                              cursorColor: DashboardColors.accentGreen,
                              decoration: InputDecoration(
                                hintText: _searchMode.hintText,
                                hintStyle: const TextStyle(color: DashboardColors.textMuted),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          _SearchModeChip(icon: Icons.search, onTap: () {}),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Products count: ${widget.products.length}',
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: DashboardColors.textMuted, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const _TableHeader(),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(
                              child: Text(
                                'No products to display',
                                style: TextStyle(color: DashboardColors.textMuted, fontSize: 14, fontStyle: FontStyle.italic),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (context, i) => _PriceListRow(product: filtered[i]),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.onRefresh, required this.onComingSoon});

  final VoidCallback onRefresh;
  final ValueChanged<String> onComingSoon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: DashboardColors.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _ToolbarButton(icon: Icons.refresh, label: 'Refresh', onTap: onRefresh),
            _ToolbarButton(icon: Icons.add, label: 'New price list', onTap: () => onComingSoon('Adding a price list')),
            const _ToolbarButton(icon: Icons.edit_outlined, label: 'Edit', onTap: null),
            const _ToolbarButton(icon: Icons.delete_outline, label: 'Delete', onTap: null),
            _ToolbarButton(icon: Icons.print_outlined, label: 'Print', onTap: () => showPrintDialog(context)),
            _ToolbarButton(icon: Icons.picture_as_pdf_outlined, label: 'Save as PDF', onTap: () => onComingSoon('Save as PDF')),
            _ToolbarButton(icon: Icons.table_chart_outlined, label: 'Excel', onTap: () => onComingSoon('Excel export')),
            const _ToolbarButton(icon: Icons.copy_outlined, label: 'Copy price list', onTap: null),
            const _ToolbarButton(icon: Icons.percent, label: 'Edit prices', onTap: null),
            const _ToolbarButton(icon: Icons.sell_outlined, label: 'Product prices', onTap: null),
            _ToolbarButton(icon: Icons.help_outline, label: 'Help', onTap: () => onComingSoon('Help')),
          ],
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final color = enabled ? Colors.white : DashboardColors.textMuted;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            SizedBox(
              width: 90,
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: color, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SideList extends StatelessWidget {
  const _SideList({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.itemLabel,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String itemLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: DashboardColors.textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: DashboardColors.accentBlue,
            borderRadius: BorderRadius.circular(2),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(itemLabel, style: const TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchModeChip extends StatelessWidget {
  const _SearchModeChip({this.icon, this.glyph, required this.onTap, this.highlighted = false})
      : assert(icon != null || glyph != null);

  final IconData? icon;
  final String? glyph;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = highlighted ? DashboardColors.accentBlue : Colors.white;
    return IconButton(
      icon: icon != null
          ? Icon(icon, color: color, size: 18)
          : Text(glyph!, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
      onPressed: onTap,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(color: DashboardColors.textMuted, fontSize: 13, fontWeight: FontWeight.w600);
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: DashboardColors.border)),
      ),
      child: const Row(
        children: [
          Expanded(flex: 2, child: Text('Code', style: style)),
          Expanded(flex: 4, child: Text('Product', style: style)),
          Expanded(flex: 2, child: Text('Cost price', style: style, textAlign: TextAlign.right)),
          Expanded(flex: 2, child: Text('Markup', style: style, textAlign: TextAlign.right)),
          Expanded(flex: 2, child: Text('Price', style: style, textAlign: TextAlign.right)),
          Expanded(flex: 2, child: Text('Tax inclusive', style: style, textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text('Taxes', style: style)),
        ],
      ),
    );
  }
}

class _PriceListRow extends StatelessWidget {
  const _PriceListRow({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(color: Colors.white, fontSize: 14);
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(product.code, maxLines: 1, overflow: TextOverflow.ellipsis, style: style)),
          Expanded(flex: 4, child: Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: style)),
          Expanded(
            flex: 2,
            child: Text(formatCurrency(product.cost), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right, style: style),
          ),
          Expanded(
            flex: 2,
            child: Text('${product.markup.toStringAsFixed(0)}%', maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right, style: style),
          ),
          Expanded(
            flex: 2,
            child: Text(formatCurrency(product.price), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right, style: style),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.center,
              child: product.priceIncludesTax
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : const SizedBox.shrink(),
            ),
          ),
          const Expanded(flex: 2, child: Text('')),
        ],
      ),
    );
  }
}
