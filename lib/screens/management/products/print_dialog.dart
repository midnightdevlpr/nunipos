import 'package:flutter/material.dart';

enum _PageRange { all, current, pages }

const _accent = Color(0xFF0067C0);
const _border = Color(0xFFBFBFBF);
const _bodyStyle = TextStyle(color: Colors.black87, fontSize: 13);
const _labelStyle = TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w600);

/// The OS-style "Print" dialog shared by the Management area's list/report
/// screens (Products, Stock, ...). There is no real printer/PDF backend wired
/// up yet, so choosing options is fully interactive but the Print button
/// itself reports that sending the job is still coming soon.
Future<void> showPrintDialog(BuildContext context) {
  return showDialog<void>(context: context, builder: (_) => const _PrintDialog());
}

class _PrintDialog extends StatefulWidget {
  const _PrintDialog();

  @override
  State<_PrintDialog> createState() => _PrintDialogState();
}

class _PrintDialogState extends State<_PrintDialog> {
  static const _printers = ['Microsoft Print to PDF', 'Microsoft XPS Document Writer'];

  String _printer = _printers.first;
  bool _printToFile = false;
  _PageRange _pageRange = _PageRange.all;
  final _pagesController = TextEditingController();
  late final _copiesController = TextEditingController(text: '1');
  int _copies = 1;
  bool _collate = true;

  @override
  void dispose() {
    _pagesController.dispose();
    _copiesController.dispose();
    super.dispose();
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$feature coming soon.')));
  }

  void _setCopies(int value) {
    final clamped = value.clamp(1, 99);
    setState(() {
      _copies = clamped;
      _copiesController.text = '$clamped';
    });
  }

  void _print() {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Printing to $_printer coming soon.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Print',
                    style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black54, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(color: Color(0xFFDDDDDD), height: 1),
              const SizedBox(height: 16),
              const Text('Printer', style: _labelStyle),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.print_outlined, color: Colors.black54, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _printer,
                      isExpanded: true,
                      style: _bodyStyle,
                      decoration: const InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(borderSide: BorderSide(color: _border)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      items: [
                        for (final printer in _printers) DropdownMenuItem(value: printer, child: Text(printer)),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => _printer = value);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () => _showComingSoon('Printer settings'),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.black87, side: const BorderSide(color: _border)),
                    child: const Text('Settings...'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: _printToFile,
                    onChanged: (value) => setState(() => _printToFile = value ?? false),
                  ),
                  const Text('Print to file', style: _bodyStyle),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Page range', style: _labelStyle),
                        const SizedBox(height: 8),
                        _PageRangeOption(
                          label: 'All',
                          selected: _pageRange == _PageRange.all,
                          onTap: () => setState(() => _pageRange = _PageRange.all),
                        ),
                        _PageRangeOption(
                          label: 'Current page',
                          selected: _pageRange == _PageRange.current,
                          onTap: () => setState(() => _pageRange = _PageRange.current),
                        ),
                        Row(
                          children: [
                            _PageRangeOption(
                              label: 'Pages:',
                              selected: _pageRange == _PageRange.pages,
                              onTap: () => setState(() => _pageRange = _PageRange.pages),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _pagesController,
                                enabled: _pageRange == _PageRange.pages,
                                onTap: () => setState(() => _pageRange = _PageRange.pages),
                                style: _bodyStyle,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: OutlineInputBorder(borderSide: BorderSide(color: _border)),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Enter page numbers and/or page ranges, separated by commas. '
                          'For example, 1,3,5-12',
                          style: TextStyle(color: Colors.black54, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Copies', style: _labelStyle),
                        const SizedBox(height: 8),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            const Text('Count:', style: _bodyStyle),
                            SizedBox(
                              width: 56,
                              height: 32,
                              child: TextField(
                                controller: _copiesController,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                style: _bodyStyle,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: OutlineInputBorder(borderSide: BorderSide(color: _border)),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                                ),
                                onChanged: (text) => _setCopies(int.tryParse(text) ?? _copies),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _SpinnerButton(icon: Icons.arrow_drop_up, onTap: () => _setCopies(_copies + 1)),
                                _SpinnerButton(icon: Icons.arrow_drop_down, onTap: () => _setCopies(_copies - 1)),
                              ],
                            ),
                            _CollateIcon(
                              icon: Icons.dynamic_feed,
                              selected: _collate,
                              onTap: () => setState(() => _collate = true),
                            ),
                            _CollateIcon(
                              icon: Icons.filter_none,
                              selected: !_collate,
                              onTap: () => setState(() => _collate = false),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: _collate,
                              onChanged: (value) => setState(() => _collate = value ?? true),
                            ),
                            const Text('Collate', style: _bodyStyle),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  TextButton(
                    onPressed: () => _showComingSoon('More options'),
                    child: const Text('More options'),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _print,
                    style: ElevatedButton.styleFrom(backgroundColor: _accent, foregroundColor: Colors.white),
                    child: const Text('Print'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.black87, side: const BorderSide(color: _border)),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageRangeOption extends StatelessWidget {
  const _PageRangeOption({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 18,
              color: selected ? _accent : Colors.black54,
            ),
            const SizedBox(width: 6),
            Text(label, style: _bodyStyle),
          ],
        ),
      ),
    );
  }
}

class _SpinnerButton extends StatelessWidget {
  const _SpinnerButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Icon(icon, size: 16, color: Colors.black54),
    );
  }
}

class _CollateIcon extends StatelessWidget {
  const _CollateIcon({required this.icon, required this.selected, required this.onTap});

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 20, color: selected ? _accent : Colors.black45),
      onPressed: onTap,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      visualDensity: VisualDensity.compact,
    );
  }
}
