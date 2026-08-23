import 'package:flutter/material.dart';

import '../screens/dashboard/dashboard_colors.dart';

/// An on-screen keyboard that types into [controller], for touch-only POS
/// terminals with no physical keyboard. Starts on the symbols/numbers page;
/// "ABC" switches to a lowercase letter page and back.
class VirtualKeyboard extends StatefulWidget {
  const VirtualKeyboard({super.key, required this.controller, this.onEnter});

  final TextEditingController controller;
  final VoidCallback? onEnter;

  @override
  State<VirtualKeyboard> createState() => _VirtualKeyboardState();
}

class _VirtualKeyboardState extends State<VirtualKeyboard> {
  bool _alphaMode = false;
  bool _upperCase = false;
  bool _visible = true;

  void _insert(String text) {
    final value = widget.controller.value;
    final start = value.selection.start >= 0 ? value.selection.start : value.text.length;
    final end = value.selection.end >= 0 ? value.selection.end : value.text.length;
    final newText = value.text.replaceRange(start, end, text);
    widget.controller.value = value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: start + text.length),
    );
  }

  void _backspace() {
    final value = widget.controller.value;
    final start = value.selection.start >= 0 ? value.selection.start : value.text.length;
    final end = value.selection.end >= 0 ? value.selection.end : value.text.length;
    if (start == end) {
      if (start == 0) return;
      final newText = value.text.replaceRange(start - 1, start, '');
      widget.controller.value = value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: start - 1),
      );
    } else {
      _insert('');
    }
  }

  void _moveCursor(int delta) {
    final value = widget.controller.value;
    final current = value.selection.start >= 0 ? value.selection.start : value.text.length;
    final next = (current + delta).clamp(0, value.text.length);
    widget.controller.selection = TextSelection.collapsed(offset: next);
  }

  void _moveCursorToStart() =>
      widget.controller.selection = const TextSelection.collapsed(offset: 0);
  void _moveCursorToEnd() =>
      widget.controller.selection = TextSelection.collapsed(offset: widget.controller.text.length);

  void _toggleShift() => setState(() => _upperCase = !_upperCase);
  void _toggleAlphaMode() => setState(() => _alphaMode = !_alphaMode);

  @override
  Widget build(BuildContext context) {
    if (!_visible) {
      return Align(
        alignment: Alignment.centerRight,
        child: IconButton(
          icon: const Icon(Icons.keyboard_alt_outlined, color: Colors.white),
          onPressed: () => setState(() => _visible = true),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _alphaMode ? _alphaRows() : _symbolRows(),
    );
  }

  List<Widget> _symbolRows() {
    return [
      Row(children: [
        for (final n in ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'])
          _key(label: n, onTap: () => _insert(n)),
        _key(icon: Icons.backspace_outlined, flex: 2, onTap: _backspace),
      ]),
      Row(children: [
        for (final s in ['!', '@', '#', '/', '^', '&', '*', '(', ')', '"'])
          _key(label: s, onTap: () => _insert(s)),
        _key(label: 'enter', flex: 2, onTap: widget.onEnter ?? () {}),
      ]),
      Row(children: [
        _key(icon: Icons.arrow_upward, onTap: _toggleShift),
        for (final s in ['-', '_', '[', ']', '|', '<', '>', '+', '=', '~'])
          _key(label: s, onTap: () => _insert(s)),
        _key(icon: Icons.arrow_upward, onTap: _toggleShift),
      ]),
      Row(children: [
        _key(icon: Icons.arrow_downward, onTap: () => setState(() => _visible = false)),
        _key(label: 'ABC', onTap: _toggleAlphaMode),
        _key(label: '.', onTap: () => _insert('.')),
        _key(label: '', flex: 5, onTap: () => _insert(' ')),
        _key(label: 'prev', onTap: _moveCursorToStart),
        _key(label: 'next', onTap: _moveCursorToEnd),
        _key(icon: Icons.chevron_left, onTap: () => _moveCursor(-1)),
        _key(icon: Icons.chevron_right, onTap: () => _moveCursor(1)),
      ]),
    ];
  }

  List<Widget> _alphaRows() {
    String letter(String lower) => _upperCase ? lower.toUpperCase() : lower;

    return [
      Row(children: [
        for (final c in 'qwertyuiop'.split('')) _key(label: letter(c), onTap: () => _insert(letter(c))),
        _key(icon: Icons.backspace_outlined, flex: 2, onTap: _backspace),
      ]),
      Row(children: [
        for (final c in 'asdfghjkl'.split('')) _key(label: letter(c), onTap: () => _insert(letter(c))),
        _key(label: 'enter', flex: 3, onTap: widget.onEnter ?? () {}),
      ]),
      Row(children: [
        _key(icon: Icons.arrow_upward, onTap: _toggleShift),
        for (final c in 'zxcvbnm'.split('')) _key(label: letter(c), onTap: () => _insert(letter(c))),
        _key(icon: Icons.arrow_upward, onTap: _toggleShift),
      ]),
      Row(children: [
        _key(label: '123', onTap: _toggleAlphaMode),
        _key(label: ',', onTap: () => _insert(',')),
        _key(label: '', flex: 6, onTap: () => _insert(' ')),
        _key(label: '.', onTap: () => _insert('.')),
        _key(label: 'prev', onTap: _moveCursorToStart),
        _key(label: 'next', onTap: _moveCursorToEnd),
      ]),
    ];
  }

  Widget _key({String? label, IconData? icon, int flex = 1, required VoidCallback onTap}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: DashboardColors.border),
              borderRadius: BorderRadius.circular(2),
            ),
            child: icon != null
                ? Icon(icon, color: Colors.white)
                : Text(label ?? '', style: const TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ),
      ),
    );
  }
}
