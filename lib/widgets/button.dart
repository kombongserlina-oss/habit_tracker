import 'package:flutter/material.dart';

class Button extends StatefulWidget {
  final String text;
  final VoidCallback onPressed; // Perbaikan: Gunakan VoidCallback untuk fungsi tanpa parameter
  final Color? color;
  final bool enabled;

  Button({
    Key? key, // Perbaikan: Tambahkan Key untuk best practice
    required this.text,
    required this.onPressed,
    this.enabled = true,
    this.color,
  }) : super(key: key);

  @override
  _ButtonState createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  bool isTapDown = false;

  @override
  Widget build(BuildContext context) {
    // PERBAIKAN: accentColor sudah deprecated, gunakan colorScheme.secondary
    final baseColor = widget.color ?? Theme.of(context).colorScheme.secondary;

    return GestureDetector(
      onTap: () {
        if (widget.enabled) {
          widget.onPressed();
        }
      },
      onTapDown: (details) {
        if (widget.enabled) setState(() { isTapDown = true; });
      },
      onTapUp: (details) => setState(() { isTapDown = false; }),
      onTapCancel: () => setState(() { isTapDown = false; }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        decoration: BoxDecoration(
          // Logika warna tetap dipertahankan: lebih gelap saat ditekan atau saat disable
          color: (isTapDown || widget.enabled == false) 
              ? HSVColor.fromColor(baseColor).withValue(0.6).toColor() 
              : baseColor,
          borderRadius: BorderRadius.circular(5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Text(
          widget.text,
          // PERBAIKAN: headline4 sudah deprecated, gunakan headlineMedium
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            // Pastikan warna teks kontras (opsional, sesuaikan dengan tema Anda)
            color: Colors.white, 
          ),
        ),
      ),
    );
  }
}