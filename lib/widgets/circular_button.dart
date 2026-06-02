import 'package:flutter/material.dart';

class CircularButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? label;

  const CircularButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Aturan 2 & 4: Perbaikan titik dua ganda dan migrasi backgroundColor -> colorScheme.surface
    final backgroundColor = Theme.of(context).colorScheme.surface;

    // Aturan 1: Migrasi accentColor -> colorScheme.secondary
    final iconColor = Theme.of(context).colorScheme.secondary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 28.0,
              ),
            ),
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 8.0),
          Text(
            label!,
            // Aturan 3: Migrasi TextTheme lama (bodyText2 -> bodyMedium)
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
