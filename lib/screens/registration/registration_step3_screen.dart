import 'package:flutter/material.dart';

import 'registration_step4_screen.dart';
import 'registration_wizard.dart';

enum PriceDisplayMode { afterTax, beforeTax }

/// Step 3 of the registration wizard: whether receipt prices include tax.
class RegistrationStep3Screen extends StatefulWidget {
  const RegistrationStep3Screen({super.key, required this.draft});

  final RegistrationDraft draft;

  @override
  State<RegistrationStep3Screen> createState() => _RegistrationStep3ScreenState();
}

class _RegistrationStep3ScreenState extends State<RegistrationStep3Screen> {
  PriceDisplayMode _selected = PriceDisplayMode.afterTax;

  @override
  Widget build(BuildContext context) {
    return RegistrationWizardScaffold(
      currentStep: 2,
      onBack: () => Navigator.of(context).pop(),
      onNext: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RegistrationStep4Screen(draft: widget.draft, priceDisplayMode: _selected),
          ),
        );
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Price display',
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w300),
            ),
            const SizedBox(height: 6),
            Text(
              'Choose whether prices are displayed and printed before or after tax',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13),
            ),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.start,
              spacing: 60,
              runSpacing: 24,
              children: [
                _PriceDisplayOption(
                  afterTax: true,
                  selected: _selected == PriceDisplayMode.afterTax,
                  title: 'After tax',
                  description: 'Prices will be displayed and printed in receipt with tax included',
                  onTap: () => setState(() => _selected = PriceDisplayMode.afterTax),
                ),
                _PriceDisplayOption(
                  afterTax: false,
                  selected: _selected == PriceDisplayMode.beforeTax,
                  title: 'Before tax',
                  description: 'Prices will be displayed and printed in receipt without tax included',
                  onTap: () => setState(() => _selected = PriceDisplayMode.beforeTax),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Discounts will be applied before of after tax based on this selection. '
              'You can change discount rules in settings anytime.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _PriceDisplayOption extends StatelessWidget {
  const _PriceDisplayOption({
    required this.afterTax,
    required this.selected,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final bool afterTax;
  final bool selected;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: SizedBox(
          width: 250,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  _ReceiptPreview(afterTax: afterTax),
                  if (selected)
                    Positioned(
                      top: -20,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF3DAA4E),
                          boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 4)],
                        ),
                        child: const Icon(Icons.check, color: Colors.white, size: 22),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiptPreview extends StatelessWidget {
  const _ReceiptPreview({required this.afterTax});

  final bool afterTax;

  @override
  Widget build(BuildContext context) {
    final unitPrice = afterTax ? '110.00' : '100.00';
    final lineTotal = afterTax ? '110.00' : '100.00';

    return PhysicalShape(
      clipper: const _ReceiptEdgeClipper(),
      color: Colors.white,
      elevation: 6,
      shadowColor: Colors.black54,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'My Company',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const _ReceiptLine.plain('Receipt No.: 000001', bold: true),
            const _ReceiptLine.plain('23.12.2018. 09:53:35'),
            const _ReceiptLine.plain('User: John Doe'),
            const _ReceiptLine.plain('Order No.: 21'),
            const SizedBox(height: 5),
            const _DashedDivider(),
            const SizedBox(height: 5),
            const _ReceiptLine.plain('My Product', bold: true),
            _ReceiptLine(label: '1x $unitPrice', value: lineTotal),
            const SizedBox(height: 6),
            const _ReceiptLine.plain('Items count: 1'),
            const SizedBox(height: 5),
            const _ReceiptLine(label: 'Subtotal:', value: '100.00'),
            const _ReceiptLine(label: 'Tax 10%:', value: '10.00'),
            const SizedBox(height: 4),
            const _DashedDivider(),
            const SizedBox(height: 4),
            const _ReceiptLine(label: 'TOTAL:', value: '110.00', bold: true, large: true),
            const SizedBox(height: 4),
            const _DashedDivider(),
            const SizedBox(height: 4),
            const _ReceiptLine(label: 'Cash:', value: '110.00'),
            const _ReceiptLine(label: 'Paid amount:', value: '110.00'),
            const _ReceiptLine(label: 'Change:', value: '0.00'),
          ],
        ),
      ),
    );
  }
}

class _ReceiptLine extends StatelessWidget {
  const _ReceiptLine({required this.label, required this.value, this.bold = false, this.large = false});

  const _ReceiptLine.plain(this.label, {this.bold = false})
      : value = null,
        large = false;

  final String label;
  final String? value;
  final bool bold;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: Colors.black,
      fontSize: large ? 13 : 11,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    );

    if (value == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: Text(label, style: style),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value!, style: style),
        ],
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      child: CustomPaint(painter: _DashedLinePainter(), size: const Size.fromHeight(1)),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black45
      ..strokeWidth = 1;
    const dashWidth = 4.0;
    const dashSpace = 3.0;
    var startX = 0.0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Clips a rectangle into a "torn receipt paper" shape with zigzag top/bottom edges.
class _ReceiptEdgeClipper extends CustomClipper<Path> {
  const _ReceiptEdgeClipper();

  static const _toothWidth = 12.0;
  static const _toothHeight = 6.0;

  @override
  Path getClip(Size size) {
    final path = Path()..moveTo(0, _toothHeight);

    var x = 0.0;
    var up = true;
    while (x < size.width) {
      final nextX = (x + _toothWidth).clamp(0.0, size.width);
      path.lineTo(nextX, up ? 0 : _toothHeight);
      up = !up;
      x = nextX;
    }

    path.lineTo(size.width, size.height - _toothHeight);

    x = size.width;
    up = true;
    while (x > 0) {
      final nextX = (x - _toothWidth).clamp(0.0, size.width);
      path.lineTo(nextX, up ? size.height : size.height - _toothHeight);
      up = !up;
      x = nextX;
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
