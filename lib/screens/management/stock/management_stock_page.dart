import 'package:flutter/material.dart';

import '../../../models/product.dart';
import '../../../models/search_mode.dart';
import '../../../utils/currency.dart';
import '../../dashboard/dashboard_colors.dart';
import '../products/print_dialog.dart';

/// The Management area's "Stock" section: a read-only inventory report of
/// the same in-memory product list Products/the POS dashboard use, with
/// quantity-status filters and cost/value totals. There's no warehousing or
/// stock-movement model yet, so every figure here is derived directly from
/// each product's current quantityOnHand/cost/price rather than fabricated.
class ManagementStockPage extends StatefulWidget {
  const ManagementStockPage({super.key, required this.products});

  final List<Product> products;

  @override
  State<ManagementStockPage> createState() => _ManagementStockPageState();
}

class _ManagementStockPageState extends State<ManagementStockPage> {
  final _searchController = TextEditingController();
  SearchMode _searchMode = SearchMode.all;
  bool _negativeOnly = false;
  bool _nonZeroOnly = false;
  bool _zeroOnly = false;
  bool _activeOnly = false;

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

  bool _matchesSearch(Product p) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return true;
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
  }

  bool get _anyStatusFilterActive => _negativeOnly || _nonZeroOnly || _zeroOnly || _activeOnly;

  bool _matchesStatusFilter(Product p) {
    if (!_anyStatusFilterActive) return true;
    if (_negativeOnly && p.quantityOnHand < 0) return true;
    if (_nonZeroOnly && p.quantityOnHand != 0) return true;
    if (_zeroOnly && p.quantityOnHand == 0) return true;
    if (_activeOnly && p.active) return true;
    return false;
  }

  List<Product> get _filtered =>
      widget.products.where((p) => _matchesSearch(p) && _matchesStatusFilter(p)).toList();

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final negativeCount = widget.products.where((p) => p.quantityOnHand < 0).length;
    final zeroCount = widget.products.where((p) => p.quantityOnHand == 0).length;
    final activeCount = widget.products.where((p) => p.active).length;

    final totalCost = filtered.fold<double>(0, (sum, p) => sum + p.cost * p.quantityOnHand);
    final totalValue = filtered.fold<double>(0, (sum, p) => sum + p.price * p.quantityOnHand);

    return Column(
      children: [
        _Toolbar(onRefresh: () => setState(() {}), onComingSoon: _showComingSoon),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(width: 180, child: _ProductTree()),
              const VerticalDivider(width: 1, color: DashboardColors.border),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _FilterBar(
                      negativeOnly: _negativeOnly,
                      onNegativeChanged: (v) => setState(() => _negativeOnly = v),
                      nonZeroOnly: _nonZeroOnly,
                      onNonZeroChanged: (v) => setState(() => _nonZeroOnly = v),
                      zeroOnly: _zeroOnly,
                      onZeroChanged: (v) => setState(() => _zeroOnly = v),
                      activeOnly: _activeOnly,
                      onActiveChanged: (v) => setState(() => _activeOnly = v),
                      negativeCount: negativeCount,
                      zeroCount: zeroCount,
                      activeCount: activeCount,
                    ),
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
                              itemBuilder: (context, i) => _StockRow(product: filtered[i]),
                            ),
                    ),
                    _TotalsBar(totalCost: totalCost, totalValue: totalValue),
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
            _ToolbarButton(icon: Icons.history, label: 'Stock history', onTap: () => onComingSoon('Stock history')),
            _ToolbarButton(icon: Icons.print_outlined, label: 'Print', onTap: () => showPrintDialog(context)),
            _ToolbarButton(icon: Icons.picture_as_pdf_outlined, label: 'Save as PDF', onTap: () => onComingSoon('Save as PDF')),
            _ToolbarButton(icon: Icons.table_chart_outlined, label: 'Excel', onTap: () => onComingSoon('Excel export')),
            _ToolbarButton(icon: Icons.fact_check_outlined, label: 'Inventory count report', onTap: () => onComingSoon('Inventory count report')),
            const _ToolbarButton(icon: Icons.bolt_outlined, label: 'Quick inventory', onTap: null),
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
              width: 80,
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

class _ProductTree extends StatelessWidget {
  const _ProductTree();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: DashboardColors.accentBlue,
            borderRadius: BorderRadius.circular(2),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.folder_outlined, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Products', style: TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.negativeOnly,
    required this.onNegativeChanged,
    required this.nonZeroOnly,
    required this.onNonZeroChanged,
    required this.zeroOnly,
    required this.onZeroChanged,
    required this.activeOnly,
    required this.onActiveChanged,
    required this.negativeCount,
    required this.zeroCount,
    required this.activeCount,
  });

  final bool negativeOnly;
  final ValueChanged<bool> onNegativeChanged;
  final bool nonZeroOnly;
  final ValueChanged<bool> onNonZeroChanged;
  final bool zeroOnly;
  final ValueChanged<bool> onZeroChanged;
  final bool activeOnly;
  final ValueChanged<bool> onActiveChanged;
  final int negativeCount;
  final int zeroCount;
  final int activeCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: DashboardColors.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterSwitch(label: 'Negative quantity', value: negativeOnly, onChanged: onNegativeChanged),
            const SizedBox(width: 20),
            _FilterSwitch(label: 'Non zero quantity', value: nonZeroOnly, onChanged: onNonZeroChanged),
            const SizedBox(width: 20),
            _FilterSwitch(label: 'Zero quantity', value: zeroOnly, onChanged: onZeroChanged),
            const SizedBox(width: 20),
            _FilterSwitch(label: 'Active products', value: activeOnly, onChanged: onActiveChanged),
            const SizedBox(width: 24),
            _CountBadge(count: negativeCount, color: DashboardColors.accentRed),
            const SizedBox(width: 6),
            _CountBadge(count: zeroCount, color: DashboardColors.accentBlue),
            const SizedBox(width: 6),
            _CountBadge(count: activeCount, color: DashboardColors.accentGreen),
          ],
        ),
      ),
    );
  }
}

class _FilterSwitch extends StatelessWidget {
  const _FilterSwitch({required this.label, required this.value, required this.onChanged});

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.scale(
          scale: 0.75,
          child: Switch(
            value: value,
            activeThumbColor: DashboardColors.accentBlue,
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count, required this.color});

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 28),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
      alignment: Alignment.center,
      child: Text(
        '$count',
        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
      ),
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
          SizedBox(width: 20),
          Expanded(flex: 2, child: Text('Code', style: style)),
          Expanded(flex: 4, child: Text('Name', style: style)),
          Expanded(flex: 2, child: Text('Quantity', style: style, textAlign: TextAlign.right)),
          Expanded(flex: 2, child: Text('Unit', style: style)),
          Expanded(flex: 2, child: Text('Cost price', style: style, textAlign: TextAlign.right)),
          Expanded(flex: 2, child: Text('Cost', style: style, textAlign: TextAlign.right)),
          Expanded(flex: 2, child: Text('Cost incl. tax', style: style, textAlign: TextAlign.right)),
          Expanded(flex: 2, child: Text('Value', style: style, textAlign: TextAlign.right)),
          Expanded(flex: 2, child: Text('Value incl. tax', style: style, textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}

class _StockRow extends StatelessWidget {
  const _StockRow({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(color: Colors.white, fontSize: 14);
    final cost = product.cost * product.quantityOnHand;
    final value = product.price * product.quantityOnHand;
    final Color dotColor = product.quantityOnHand < 0
        ? DashboardColors.accentRed
        : product.quantityOnHand == 0
            ? DashboardColors.accentBlue
            : product.active
                ? DashboardColors.accentGreen
                : DashboardColors.textMuted;

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Icon(Icons.circle, size: 10, color: dotColor),
          ),
          Expanded(flex: 2, child: Text(product.code, maxLines: 1, overflow: TextOverflow.ellipsis, style: style)),
          Expanded(flex: 4, child: Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: style)),
          Expanded(
            flex: 2,
            child: Text('${product.quantityOnHand}', maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right, style: style),
          ),
          Expanded(flex: 2, child: Text(product.quantityUnit, maxLines: 1, overflow: TextOverflow.ellipsis, style: style)),
          Expanded(
            flex: 2,
            child: Text(formatCurrency(product.cost), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right, style: style),
          ),
          Expanded(
            flex: 2,
            child: Text(formatCurrency(cost), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right, style: style),
          ),
          Expanded(
            flex: 2,
            child: Text(formatCurrency(cost), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right, style: style),
          ),
          Expanded(
            flex: 2,
            child: Text(formatCurrency(value), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right, style: style),
          ),
          Expanded(
            flex: 2,
            child: Text(formatCurrency(value), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right, style: style),
          ),
        ],
      ),
    );
  }
}

class _TotalsBar extends StatelessWidget {
  const _TotalsBar({required this.totalCost, required this.totalValue});

  final double totalCost;
  final double totalValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: DashboardColors.border)),
      ),
      child: Wrap(
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.start,
        spacing: 48,
        runSpacing: 12,
        children: [
          _TotalsColumn(title: 'Cost price', rows: [
            _TotalsRow(label: 'Total cost:', value: totalCost),
            _TotalsRow(label: 'Total cost inc. tax:', value: totalCost),
          ]),
          _TotalsColumn(title: 'Sale price', rows: [
            _TotalsRow(label: 'Total:', value: totalValue),
            _TotalsRow(label: 'Total inc. tax:', value: totalValue),
          ]),
        ],
      ),
    );
  }
}

class _TotalsColumn extends StatelessWidget {
  const _TotalsColumn({required this.title, required this.rows});

  final String title;
  final List<_TotalsRow> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 4),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: DashboardColors.accentBlue, width: 2)),
          ),
          child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15)),
        ),
        const SizedBox(height: 6),
        ...rows,
      ],
    );
  }
}

class _TotalsRow extends StatelessWidget {
  const _TotalsRow({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: DashboardColors.textMuted, fontSize: 13),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            formatCurrency(value),
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
