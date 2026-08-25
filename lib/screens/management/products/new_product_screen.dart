import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../models/product.dart';
import '../../../models/product_colors.dart';
import '../../dashboard/dashboard_colors.dart';

/// The side panel for adding or editing a product, opened next to the
/// product list in Management > Products. Only Name is required; everything
/// else mirrors the reference app's Details / Price & tax / Stock control /
/// Comments / Image & color tabs.
class ProductFormPanel extends StatefulWidget {
  const ProductFormPanel({
    super.key,
    this.existing,
    required this.onSave,
    required this.onCancel,
  });

  final Product? existing;
  final ValueChanged<Product> onSave;
  final VoidCallback onCancel;

  @override
  State<ProductFormPanel> createState() => _ProductFormPanelState();
}

class _ProductFormPanelState extends State<ProductFormPanel> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 5, vsync: this);

  late final _nameController = TextEditingController(text: widget.existing?.name);
  late final _codeController = TextEditingController(text: widget.existing?.code);
  late final _barcodeController = TextEditingController(text: widget.existing?.barcode);
  late final _unitController = TextEditingController(text: widget.existing?.quantityUnit ?? '');
  late final _ageRestrictionController =
      TextEditingController(text: widget.existing?.ageRestriction?.toString() ?? '');
  late final _descriptionController = TextEditingController(text: widget.existing?.description);

  late final _costController =
      TextEditingController(text: widget.existing == null ? '' : widget.existing!.cost.toStringAsFixed(2));
  late final _markupController =
      TextEditingController(text: widget.existing == null ? '' : widget.existing!.markup.toStringAsFixed(2));
  late final _priceController =
      TextEditingController(text: widget.existing == null ? '' : widget.existing!.price.toStringAsFixed(2));

  late final _reorderPointController =
      TextEditingController(text: (widget.existing?.reorderPoint ?? 0).toString());
  late final _preferredQuantityController =
      TextEditingController(text: (widget.existing?.preferredQuantity ?? 0).toString());
  late final _lowStockWarningQuantityController =
      TextEditingController(text: (widget.existing?.lowStockWarningQuantity ?? 0).toString());

  late final _commentController = TextEditingController();
  late List<String> _comments = List.of(widget.existing?.comments ?? const []);
  int? _selectedCommentIndex;

  late bool _active = widget.existing?.active ?? true;
  late bool _defaultQuantity = widget.existing?.defaultQuantity ?? true;
  late bool _isService = widget.existing?.isService ?? false;
  late bool _priceIncludesTax = widget.existing?.priceIncludesTax ?? true;
  late bool _priceChangeAllowed = widget.existing?.priceChangeAllowed ?? false;
  late bool _lowStockWarning = widget.existing?.lowStockWarning ?? false;
  late String _color = widget.existing?.color ?? 'Transparent';
  late String? _imagePath = widget.existing?.imagePath;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _codeController.dispose();
    _barcodeController.dispose();
    _unitController.dispose();
    _ageRestrictionController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    _markupController.dispose();
    _priceController.dispose();
    _reorderPointController.dispose();
    _preferredQuantityController.dispose();
    _lowStockWarningQuantityController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  bool get _nameIsEmpty => _nameController.text.trim().isEmpty;

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature coming soon.')),
    );
  }

  void _generateBarcode() {
    final random = Random();
    final digits = List.generate(13, (_) => random.nextInt(10)).join();
    setState(() => _barcodeController.text = digits);
  }

  Future<void> _browseImage() async {
    final file = await FilePicker.pickFile(
      type: FileType.image,
      dialogTitle: 'Choose a product image',
    );
    if (file?.path != null) setState(() => _imagePath = file!.path);
  }

  void _clearImage() {
    setState(() => _imagePath = null);
  }

  void _addComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _comments = [..._comments, text];
      _commentController.clear();
    });
  }

  void _deleteSelectedComment() {
    final index = _selectedCommentIndex;
    if (index == null) return;
    setState(() {
      _comments = [..._comments]..removeAt(index);
      _selectedCommentIndex = null;
    });
  }

  void _resetStockDefaults() {
    setState(() {
      _reorderPointController.text = '0';
      _preferredQuantityController.text = '0';
      _lowStockWarning = false;
      _lowStockWarningQuantityController.text = '0';
    });
  }

  void _save() {
    if (_nameIsEmpty) return;
    widget.onSave(
      Product(
        name: _nameController.text.trim(),
        price: double.tryParse(_priceController.text.trim()) ?? 0,
        icon: widget.existing?.icon ?? Icons.inventory_2_outlined,
        description: _descriptionController.text.trim(),
        code: _codeController.text.trim(),
        barcode: _barcodeController.text.trim(),
        quantityOnHand: widget.existing?.quantityOnHand ?? 0,
        quantityUnit: _unitController.text.trim().isEmpty ? 'pcs' : _unitController.text.trim(),
        cost: double.tryParse(_costController.text.trim()) ?? 0,
        active: _active,
        color: _color,
        imagePath: _imagePath,
        defaultQuantity: _defaultQuantity,
        isService: _isService,
        ageRestriction: int.tryParse(_ageRestrictionController.text.trim()),
        markup: double.tryParse(_markupController.text.trim()) ?? 0,
        priceIncludesTax: _priceIncludesTax,
        priceChangeAllowed: _priceChangeAllowed,
        reorderPoint: num.tryParse(_reorderPointController.text.trim()) ?? 0,
        preferredQuantity: num.tryParse(_preferredQuantityController.text.trim()) ?? 0,
        lowStockWarning: _lowStockWarning,
        lowStockWarningQuantity: num.tryParse(_lowStockWarningQuantityController.text.trim()) ?? 0,
        comments: _comments,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    return Container(
      color: DashboardColors.toolbarBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    isEditing ? 'Edit product' : 'New product',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w300),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                  onPressed: widget.onCancel,
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: DashboardColors.textMuted,
            indicatorColor: DashboardColors.accentBlue,
            labelStyle: const TextStyle(fontSize: 14),
            tabs: const [
              Tab(text: 'Details'),
              Tab(text: 'Price & tax'),
              Tab(text: 'Stock control'),
              Tab(text: 'Comments'),
              Tab(text: 'Image & color'),
            ],
          ),
          const Divider(color: DashboardColors.border, height: 1),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDetailsTab(),
                _buildPriceTaxTab(),
                _buildStockControlTab(),
                _buildCommentsTab(),
                _buildImageColorTab(),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: DashboardColors.border)),
            ),
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 12,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _nameIsEmpty ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DashboardColors.accentGreen,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: DashboardColors.accentGreen.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Save'),
                ),
                ElevatedButton.icon(
                  onPressed: widget.onCancel,
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

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label('Name'),
          _ProductField(
            key: const Key('product_name_field'),
            controller: _nameController,
            hasError: _nameIsEmpty,
          ),
          const SizedBox(height: 16),
          _Label('Code'),
          _ProductField(controller: _codeController),
          const SizedBox(height: 16),
          _Label('Barcode'),
          _ProductField(controller: _barcodeController),
          const SizedBox(height: 4),
          InkWell(
            onTap: _generateBarcode,
            child: const Text(
              'Generate barcode',
              style: TextStyle(color: DashboardColors.accentBlue, fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),
          _Label('Unit of measurement'),
          _ProductField(controller: _unitController),
          const SizedBox(height: 16),
          _Label('Group'),
          DropdownButtonFormField<String>(
            initialValue: 'Products',
            dropdownColor: DashboardColors.toolbarBackground,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: _fieldDecoration(),
            items: const [DropdownMenuItem(value: 'Products', child: Text('Products'))],
            onChanged: (_) {},
          ),
          const SizedBox(height: 8),
          _SwitchRow(label: 'Active', value: _active, onChanged: (v) => setState(() => _active = v)),
          _SwitchRow(
            label: 'Default quantity',
            value: _defaultQuantity,
            onChanged: (v) => setState(() => _defaultQuantity = v),
          ),
          _SwitchRow(
            label: 'Service (not using stock)',
            value: _isService,
            onChanged: (v) => setState(() => _isService = v),
          ),
          const SizedBox(height: 16),
          _Label('Age restriction'),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              SizedBox(
                width: 100,
                child: _ProductField(
                  controller: _ageRestrictionController,
                  keyboardType: TextInputType.number,
                ),
              ),
              const Text('year(s)', style: TextStyle(color: DashboardColors.textMuted, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),
          _Label('Description'),
          _ProductField(controller: _descriptionController, maxLines: 4),
        ],
      ),
    );
  }

  Widget _buildPriceTaxTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label('Taxes'),
          ElevatedButton(
            onPressed: () => _showComingSoon('Adding tax to a product'),
            style: ElevatedButton.styleFrom(
              backgroundColor: DashboardColors.accentGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
            ),
            child: const Text('Add tax to product'),
          ),
          const SizedBox(height: 16),
          _Label('Cost'),
          _ProductField(controller: _costController, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
          const SizedBox(height: 16),
          _Label('Markup %'),
          _ProductField(controller: _markupController, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
          const SizedBox(height: 16),
          _Label('Sale price'),
          _ProductField(controller: _priceController, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
          const SizedBox(height: 8),
          _SwitchRow(
            label: 'Price includes tax',
            value: _priceIncludesTax,
            onChanged: (v) => setState(() => _priceIncludesTax = v),
          ),
          _SwitchRow(
            label: 'Price change allowed',
            value: _priceChangeAllowed,
            onChanged: (v) => setState(() => _priceChangeAllowed = v),
          ),
        ],
      ),
    );
  }

  Widget _buildStockControlTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _InfoBanner('Set low stock quantity rules that can be used as a stock reorder point.'),
          const SizedBox(height: 16),
          _Label('Supplier'),
          DropdownButtonFormField<String>(
            initialValue: '(none)',
            dropdownColor: DashboardColors.toolbarBackground,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: _fieldDecoration(),
            items: const [DropdownMenuItem(value: '(none)', child: Text('(none)'))],
            onChanged: (_) {},
          ),
          const SizedBox(height: 16),
          _Label('Reorder point'),
          _ProductField(controller: _reorderPointController, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
          const SizedBox(height: 16),
          _Label('Preferred quantity'),
          _ProductField(controller: _preferredQuantityController, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
          const SizedBox(height: 8),
          _SwitchRow(
            label: 'Low stock warning',
            value: _lowStockWarning,
            onChanged: (v) => setState(() => _lowStockWarning = v),
          ),
          const SizedBox(height: 16),
          _Label('Low stock warning quantity'),
          _ProductField(
            controller: _lowStockWarningQuantityController,
            enabled: _lowStockWarning,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _resetStockDefaults,
            child: const Text(
              'Reset to default',
              style: TextStyle(color: DashboardColors.accentBlue, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoBanner.withLink(
            'Comments will be printed on kitchen tickets.',
            onLearnMore: () => _showComingSoon('Learn more'),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ProductField(controller: _commentController, hintText: 'Enter comment...'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _addComment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DashboardColors.toolbarBackground,
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: DashboardColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _selectedCommentIndex == null ? null : _deleteSelectedComment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DashboardColors.toolbarBackground,
                  foregroundColor: Colors.white,
                  disabledForegroundColor: DashboardColors.textMuted,
                  side: const BorderSide(color: DashboardColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                ),
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text('Delete'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _comments.isEmpty
                ? const Center(
                    child: Text(
                      'No comments yet',
                      style: TextStyle(color: DashboardColors.textMuted, fontStyle: FontStyle.italic),
                    ),
                  )
                : ListView.builder(
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      final selected = _selectedCommentIndex == index;
                      return InkWell(
                        onTap: () => setState(() => _selectedCommentIndex = index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          color: selected ? DashboardColors.accentBlue.withValues(alpha: 0.25) : null,
                          child: Text(_comments[index], style: const TextStyle(color: Colors.white, fontSize: 14)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageColorTab() {
    final hasImage = _imagePath != null;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label('Color'),
          DropdownButtonFormField<String>(
            initialValue: _color,
            dropdownColor: DashboardColors.toolbarBackground,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: _fieldDecoration(),
            isExpanded: true,
            menuMaxHeight: 360,
            items: [
              for (final entry in productColors.entries)
                DropdownMenuItem(
                  value: entry.key,
                  child: Row(
                    children: [
                      _ColorSwatch(entry.value),
                      const SizedBox(width: 10),
                      Expanded(child: Text(entry.key, overflow: TextOverflow.ellipsis)),
                      if (entry.key == _color) const Icon(Icons.check, color: DashboardColors.accentBlue, size: 18),
                    ],
                  ),
                ),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _color = value);
            },
          ),
          const SizedBox(height: 24),
          _Label('Image'),
          if (hasImage) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.file(
                File(_imagePath!),
                width: 140,
                height: 140,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 140,
                  height: 140,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: DashboardColors.border),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.broken_image_outlined, color: DashboardColors.textMuted, size: 32),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: _browseImage,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: DashboardColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                ),
                child: const Text('Browse'),
              ),
              OutlinedButton(
                onPressed: hasImage ? _clearImage : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  disabledForegroundColor: DashboardColors.textMuted,
                  side: const BorderSide(color: DashboardColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                ),
                child: const Text('Clear'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

InputDecoration _fieldDecoration({bool hasError = false}) {
  final borderColor = hasError ? DashboardColors.accentRed : DashboardColors.border;
  return InputDecoration(
    filled: true,
    fillColor: DashboardColors.background,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: BorderSide(color: borderColor)),
    enabledBorder:
        OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: BorderSide(color: borderColor)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(2),
      borderSide: BorderSide(color: hasError ? DashboardColors.accentRed : DashboardColors.accentBlue, width: 2),
    ),
  );
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
    );
  }
}

class _ProductField extends StatelessWidget {
  const _ProductField({
    super.key,
    required this.controller,
    this.hasError = false,
    this.keyboardType,
    this.maxLines = 1,
    this.hintText,
    this.enabled = true,
  });

  final TextEditingController controller;
  final bool hasError;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? hintText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      cursorColor: DashboardColors.accentBlue,
      decoration: _fieldDecoration(hasError: hasError).copyWith(
        hintText: hintText,
        hintStyle: const TextStyle(color: DashboardColors.textMuted),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({required this.label, required this.value, required this.onChanged});

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Switch(value: value, activeThumbColor: DashboardColors.accentGreen, onChanged: onChanged),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14))),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner(this.text) : onLearnMore = null;

  const _InfoBanner.withLink(this.text, {required VoidCallback this.onLearnMore});

  final String text;
  final VoidCallback? onLearnMore;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DashboardColors.accentBlue.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: DashboardColors.accentBlue, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Wrap(
              children: [
                Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
                if (onLearnMore != null) ...[
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: onLearnMore,
                    child: const Text(
                      'Learn more',
                      style: TextStyle(color: DashboardColors.accentBlue, fontSize: 13),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch(this.color);

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: DashboardColors.border),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
