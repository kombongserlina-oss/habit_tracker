import 'package:flutter/material.dart';

class MyCheckbox extends StatefulWidget {
  final bool initValue;
  final Function(bool newValue) onChange;

  // PERBAIKAN: Gunakan Key standar, jangan paksa GlobalKey() di sini agar performa lebih baik
  MyCheckbox({
    Key? key, 
    this.initValue = false,
    required this.onChange,
  }) : super(key: key);

  @override
  _MyCheckboxState createState() => _MyCheckboxState();
}

class _MyCheckboxState extends State<MyCheckbox> {
  late bool value;

  @override
  void initState() {
    value = widget.initValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: value,
      // PERBAIKAN: accentColor -> colorScheme.secondary
      activeColor: Theme.of(context).colorScheme.secondary,
      // primaryColorLight masih valid, tapi pastikan sudah didefinisikan di base_theme.dart
      checkColor: Theme.of(context).primaryColorLight,
      
      onChanged: (newValue) {
        setState(() {
          value = newValue ?? false;  
        });
        widget.onChange(value);
      },
      // Tambahan: Menghaluskan bentuk checkbox agar terlihat lebih modern (Material 3 style)
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}