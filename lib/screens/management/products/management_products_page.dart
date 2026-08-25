import 'package:flutter/material.dart';

import '../../../models/product.dart';
import '../../../models/search_mode.dart';
import '../../../utils/currency.dart';
import '../../dashboard/dashboard_colors.dart';
import 'new_product_screen.dart' show ProductFormPanel;

/// The Management area's "Products" section: a single-group product tree on
/// the left and a searchable, sortable product table on the right. Products
/// live in the same in-memory list the POS dashboard sells from, so adding,
/// editing, or deleting here is reflected on the sales screen too.
class ManagementProductsPage extends StatefulWidget {
  const ManagementProductsPage({
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
  State<ManagementProductsPage> createState() => _ManagementProductsPageState();
}

class _ManagementProductsPageState extends State<ManagementProductsPage> {
  final _searchController = TextEditingController();
  SearchMode _searchMode = SearchMode.all;
  int? _selectedIndex;
  bool _showForm = false;
  bool _isEditing = false;

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

  List<int> get _filteredIndexes {
    final query = _searchController.text.trim().toLowerCase();
    final indexes = List.generate(widget.products.length, (i) => i);
    if (query.isEmpty) return indexes;
    return indexes.where((i) {
      final p = widget.products[i];
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

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$feature coming soon.')));
  }

  void _newProduct() {
    setState(() {
      _isEditing = false;
      _showForm = true;
    });
  }

  void _editProduct() {
    if (_selectedIndex == null) return;
    setState(() {
      _isEditing = true;
      _showForm = true;
    });
  }

  void _closeForm() {
    setState(() => _showForm = false);
  }

  void _saveForm(Product product) {
    setState(() {
      if (_isEditing && _selectedIndex != null) {
        widget.onUpdateProduct(_selectedIndex!, product);
      } else {
        widget.onAddProduct(product);
      }
      _showForm = false;
    });
  }

  Future<void> _deleteProduct() async {
    final index = _selectedIndex;
    if (index == null) return;
    final product = widget.products[index];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: DashboardColors.toolbarBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Delete product',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                const SizedBox(height: 12),
                Text(
                  'Delete "${product.name}"? This cannot be undone.',
                  style: const TextStyle(
                    color: DashboardColors.textMuted,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DashboardColors.accentRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (confirmed == true) {
      widget.onDeleteProduct(index);
      setState(() => _selectedIndex = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredIndexes;
    final hasSelection = _selectedIndex != null;

    return Column(
      children: [
        _Toolbar(
          hasSelection: hasSelection,
          onRefresh: () => setState(() {}),
          onNewProduct: _newProduct,
          onEditProduct: hasSelection ? _editProduct : null,
          onDeleteProduct: hasSelection ? _deleteProduct : null,
          onComingSoon: _showComingSoon,
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              const treeWidth = 180.0;
              const dividerWidth = 1.0;
              const minTableWidth = 220.0;
              // On a narrow window, drop the decorative product tree first so
              // the form panel and table keep enough room to stay usable.
              final showTree = !_showForm || constraints.maxWidth >= 900;
              final reservedForTree = showTree ? treeWidth + dividerWidth : 0.0;
              final panelWidth = _showForm
                  ? (constraints.maxWidth -
                            reservedForTree -
                            dividerWidth -
                            minTableWidth)
                        .clamp(0.0, 460.0)
                  : 0.0;
              return _buildContentRow(filtered, showTree, treeWidth, panelWidth);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContentRow(
    List<int> filtered,
    bool showTree,
    double treeWidth,
    double panelWidth,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showTree) ...[
          SizedBox(width: treeWidth, child: const _ProductTree()),
          const VerticalDivider(width: 1, color: DashboardColors.border),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 48,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: DashboardColors.border),
                  ),
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
                      onTap: () =>
                          setState(() => _searchMode = SearchMode.barcode),
                    ),
                    _SearchModeChip(
                      icon: Icons.tag,
                      highlighted: _searchMode == SearchMode.code,
                      onTap: () =>
                          setState(() => _searchMode = SearchMode.code),
                    ),
                    _SearchModeChip(
                      icon: Icons.sell_outlined,
                      highlighted: _searchMode == SearchMode.name,
                      onTap: () =>
                          setState(() => _searchMode = SearchMode.name),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                        cursorColor: DashboardColors.accentGreen,
                        decoration: InputDecoration(
                          hintText: _searchMode.hintText,
                          hintStyle: const TextStyle(
                            color: DashboardColors.textMuted,
                          ),
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
                        style: const TextStyle(
                          color: DashboardColors.textMuted,
                          fontSize: 13,
                        ),
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
                          style: TextStyle(
                            color: DashboardColors.textMuted,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, i) {
                          final index = filtered[i];
                          return _ProductRow(
                            product: widget.products[index],
                            selected: _selectedIndex == index,
                            onTap: () => setState(() => _selectedIndex = index),
                            onDoubleTap: () {
                              setState(() => _selectedIndex = index);
                              _editProduct();
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        if (_showForm) ...[
          const VerticalDivider(width: 1, color: DashboardColors.border),
          SizedBox(
            width: panelWidth,
            child: ProductFormPanel(
              key: ValueKey(_isEditing ? _selectedIndex : 'new'),
              existing: _isEditing && _selectedIndex != null
                  ? widget.products[_selectedIndex!]
                  : null,
              onSave: _saveForm,
              onCancel: _closeForm,
            ),
          ),
        ],
      ],
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.hasSelection,
    required this.onRefresh,
    required this.onNewProduct,
    required this.onEditProduct,
    required this.onDeleteProduct,
    required this.onComingSoon,
  });

  final bool hasSelection;
  final VoidCallback onRefresh;
  final VoidCallback onNewProduct;
  final VoidCallback? onEditProduct;
  final VoidCallback? onDeleteProduct;
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
            _ToolbarButton(
              icon: Icons.refresh,
              label: 'Refresh',
              onTap: onRefresh,
            ),
            const _ToolbarDivider(),
            _ToolbarButton(
              icon: Icons.create_new_folder_outlined,
              label: 'New group',
              onTap: null,
            ),
            _ToolbarButton(
              icon: Icons.edit_outlined,
              label: 'Edit group',
              onTap: null,
            ),
            _ToolbarButton(
              icon: Icons.folder_delete_outlined,
              label: 'Delete group',
              onTap: null,
            ),
            const _ToolbarDivider(),
            _ToolbarButton(
              icon: Icons.add,
              label: 'New product',
              onTap: onNewProduct,
            ),
            _ToolbarButton(
              icon: Icons.edit_outlined,
              label: 'Edit product',
              onTap: onEditProduct,
            ),
            _ToolbarButton(
              icon: Icons.delete_outline,
              label: 'Delete product',
              onTap: onDeleteProduct,
            ),
            const _ToolbarDivider(),
            _ToolbarButton(
              icon: Icons.print_outlined,
              label: 'Print',
              onTap: () => onComingSoon('Print'),
            ),
            _ToolbarButton(
              icon: Icons.picture_as_pdf_outlined,
              label: 'Save as PDF',
              onTap: () => onComingSoon('Save as PDF'),
            ),
            _ToolbarButton(
              icon: Icons.local_offer_outlined,
              label: 'Price tags',
              onTap: () => onComingSoon('Price tags'),
            ),
            _ToolbarButton(
              icon: Icons.call_merge,
              label: 'Merge',
              onTap: () => onComingSoon('Merge'),
            ),
            _ToolbarButton(
              icon: Icons.sort,
              label: 'Sorting',
              onTap: () => onComingSoon('Sorting'),
            ),
            _ToolbarButton(
              icon: Icons.show_chart,
              label: 'Mov. avg. price',
              onTap: () => onComingSoon('Mov. avg. price'),
            ),
            _ToolbarButton(
              icon: Icons.file_download_outlined,
              label: 'Import',
              onTap: () => onComingSoon('Import'),
            ),
            const _ToolbarDivider(),
            _ToolbarButton(
              icon: Icons.file_upload_outlined,
              label: 'Export',
              onTap: () => onComingSoon('Export'),
            ),
            const _ToolbarDivider(),
            _ToolbarButton(
              icon: Icons.help_outline,
              label: 'Help',
              onTap: () => onComingSoon('Help'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolbarDivider extends StatelessWidget {
  const _ToolbarDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: VerticalDivider(
        width: 1,
        thickness: 1,
        color: DashboardColors.border,
        indent: 8,
        endIndent: 8,
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

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
            Text(
              label,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color, fontSize: 11),
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
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: DashboardColors.accentBlue,
          borderRadius: BorderRadius.circular(2),
        ),
        child: const Row(
          children: [
            Icon(Icons.folder_outlined, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              'Products',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchModeChip extends StatelessWidget {
  const _SearchModeChip({
    this.icon,
    this.glyph,
    required this.onTap,
    this.highlighted = false,
  }) : assert(icon != null || glyph != null);

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
          : Text(
              glyph!,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
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
    const style = TextStyle(
      color: DashboardColors.textMuted,
      fontSize: 13,
      fontWeight: FontWeight.w600,
    );
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: DashboardColors.border)),
      ),
      child: const Row(
        children: [
          Expanded(flex: 2, child: Text('Code', style: style)),
          Expanded(flex: 4, child: Text('Name', style: style)),
          Expanded(flex: 3, child: Text('Group', style: style)),
          Expanded(flex: 3, child: Text('Barcode', style: style)),
          Expanded(
            flex: 2,
            child: Text('Cost', style: style, textAlign: TextAlign.right),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Sale price (excl.)',
              style: style,
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(flex: 2, child: Text('Taxes', style: style)),
          Expanded(
            flex: 2,
            child: Text('Sale price', style: style, textAlign: TextAlign.right),
          ),
          SizedBox(
            width: 60,
            child: Text('Active', style: style, textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({
    required this.product,
    required this.selected,
    required this.onTap,
    required this.onDoubleTap,
  });

  final Product product;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: selected ? Colors.white : Colors.white.withValues(alpha: 0.9),
      fontSize: 14,
    );
    return InkWell(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        color: selected
            ? DashboardColors.accentBlue.withValues(alpha: 0.25)
            : null,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                product.code,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style,
              ),
            ),
            Expanded(
              flex: 4,
              child: Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style,
              ),
            ),
            const Expanded(
              flex: 3,
              child: Text(
                'Products',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                product.barcode,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                formatCurrency(product.cost),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: style,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                formatCurrency(product.price),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: style,
              ),
            ),
            const Expanded(flex: 2, child: Text('')),
            Expanded(
              flex: 2,
              child: Text(
                formatCurrency(product.price),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: style,
              ),
            ),
            SizedBox(
              width: 60,
              child: Icon(
                product.active ? Icons.check : Icons.close,
                color: product.active
                    ? DashboardColors.accentGreen
                    : DashboardColors.textMuted,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
