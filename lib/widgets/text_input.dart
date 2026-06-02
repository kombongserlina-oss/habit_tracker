import 'package:flutter/material.dart';

class CustomTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final bool isPassword;
  final TextInputType keyboardType;

  const CustomTextInput({
    Key? key,
    required this.controller,
    required this.label,
    required this.hintText,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Aturan 1 & 4: Migrasi accentColor -> colorScheme.secondary & pastikan titik tunggal
    final focusColor = Theme.of(context).colorScheme.secondary;

    // Aturan 2: Migrasi backgroundColor -> colorScheme.surface
    final fillColor = Theme.of(context).colorScheme.surface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          // Aturan 3: Migrasi TextTheme lama (subtitle1 -> titleMedium)
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8.0),
        TextField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          // Aturan 3: Migrasi gaya teks input (bodyText2 -> bodyMedium)
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: hintText,
            // Aturan 3: Migrasi gaya teks hint (bodyText2 -> bodyMedium)
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade400,
            ),
            filled: true,
            fillColor: fillColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 14.0,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: focusColor,
                width: 2.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}