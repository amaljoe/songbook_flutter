import 'package:flutter/material.dart';
import '../utilities/constants.dart';

/// Wraps a child with a subtle scale + tint press animation.
class TappableItem extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  TappableItem({required this.child, required this.onTap});

  @override
  _TappableItemState createState() => _TappableItemState();
}

class _TappableItemState extends State<TappableItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: Duration(milliseconds: 80),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 80),
          color: _pressed ? kAccentColor.withOpacity(0.07) : Colors.transparent,
          child: widget.child,
        ),
      ),
    );
  }
}
