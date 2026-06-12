import 'package:flutter/material.dart';

// Ganti namanya jadi TextInput agar pas dengan dialogmu
class TextInput extends StatelessWidget {
  final ValueChanged<String>? onChanged; // Tambah ini
  final String label;
  final String hint; // Ubah hintText jadi hint agar klop
  final bool isPassword;
  final TextInputType keyboardType;

  const TextInput({
    Key? key,
    this.onChanged, // Tambah ini
    required this.label,
    required this.hint,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final focusColor = Theme.of(context).colorScheme.secondary;
    final fillColor = Theme.of(context).colorScheme.surface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8.0),
        TextField(
          onChanged: onChanged, // Pasang di sini
          obscureText: isPassword,
          keyboardType: keyboardType,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
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
