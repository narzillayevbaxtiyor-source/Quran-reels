/// Animated like/favorite button with pulse animation.
///
/// Used across the app for favoriting verses with a satisfying
/// animated heart icon and ripple effect.
library;

import 'package:flutter/material.dart';

/// A heart-shaped favorite button with pulse animation.
///
/// When tapped, the heart icon scales up and back down with
/// a smooth spring animation.
class LikeButton extends StatefulWidget {
  /// Whether the verse is currently liked/favorited.
  final bool isLiked;

  /// Size of the button.
  final double size;

  /// Color when liked.
  final Color activeColor;

  /// Color when not liked.
  final Color inactiveColor;

  /// Called when the button is tapped.
  final VoidCallback? onTap;

  /// Whether to show the label below the icon.
  final String? label;

  const LikeButton({
    super.key,
    this.isLiked = false,
    this.size = 30,
    this.activeColor = Colors.red,
    this.inactiveColor = Colors.white70,
    this.onTap,
    this.label,
  });

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: widget.size + 8,
                  height: widget.size + 8,
                  decoration: BoxDecoration(
                    color: widget.isLiked
                        ? widget.activeColor.withOpacity(0.1)
                        : Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: widget.isLiked
                        ? widget.activeColor
                        : widget.inactiveColor,
                    size: widget.size,
                  ),
                ),
              ),
              if (widget.label != null) ...[
                const SizedBox(height: 4),
                Text(
                  widget.label!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
