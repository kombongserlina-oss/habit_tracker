import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isSecondary;

  const CustomTextButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isSecondary = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Aturan 1 & 4: Perbaikan titik dua ganda dan migrasi accentColor -> colorScheme.secondary
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    // Aturan 2: Migrasi backgroundColor -> colorScheme.surface
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        // Menentukan warna teks tombol (foregroundColor) berdasarkan parameter
        foregroundColor: isSecondary ? secondaryColor : Colors.blue,
        backgroundColor: surfaceColor, // Menggunakan warna permukaan baru
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: Text(
        text,
        // Aturan 3: Migrasi TextTheme lama (button -> labelLarge)
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
