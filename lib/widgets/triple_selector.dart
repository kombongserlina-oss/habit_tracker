import 'package:flutter/material.dart';

class TripleSelector extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const TripleSelector({
    Key? key,
    required this.options,
    required this.selectedIndex,
    required this.onSelect,
  })  : assert(options.length == 3, 'Options must contain exactly 3 items'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    // Aturan 2 & 4: Perbaikan titik dua ganda dan migrasi backgroundColor -> colorScheme.surface
    final containerBackground = Theme.of(context).colorScheme.surface;

    // Aturan 1: Migrasi accentColor -> colorScheme.secondary
    final activeIndicatorColor = Theme.of(context).colorScheme.secondary;

    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: containerBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: List.generate(3, (index) {
          final isSelected = index == selectedIndex;

          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                decoration: BoxDecoration(
                  color: isSelected ? activeIndicatorColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Center(
                  child: Text(
                    options[index],
                    // Aturan 3: Migrasi TextTheme lama
                    // Jika aktif pakai titleSmall (subtitle2), jika tidak pakai bodyMedium (bodyText2)
                    style: isSelected
                        ? Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    )
                        : Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
