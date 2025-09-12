import 'package:bluebubbles/widgets/expressive_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExpressiveSettingsTile extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isLarge;

  const ExpressiveSettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isLarge = false,
  });

  @override
  State<ExpressiveSettingsTile> createState() => _ExpressiveSettingsTileState();
}

class _ExpressiveSettingsTileState extends State<ExpressiveSettingsTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return ExpressiveCard(
      onTap: widget.onTap,
      onHighlightChanged: (value) {
        setState(() {
          _isPressed = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.icon,
                color: widget.color,
                size: 24,
              ),
            ),
            const Spacer(),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              style: context.textTheme.titleMedium!.copyWith(
                fontWeight: _isPressed ? FontWeight.w900 : FontWeight.bold,
                color: context.textTheme.titleMedium?.color,
              ),
              child: Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (widget.subtitle != null)
              Text(
                widget.subtitle!,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}
