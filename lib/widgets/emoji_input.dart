import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

class EmojiInput extends StatefulWidget {
  final Function(String newEmoji) onChange;
  final String initialEmoji;

  EmojiInput({
    required this.onChange,
    required this.initialEmoji
  });

  @override
  _EmojiInputState createState() => _EmojiInputState();
}

class _EmojiInputState extends State<EmojiInput> {
  late String emoji;

  @override
  void initState() {
    emoji = widget.initialEmoji;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => EmojiInputDialog.show(context).then((newEmoji) {
        if(newEmoji == null) return;

        setState(() {
          emoji = newEmoji;
        });
        widget.onChange(newEmoji);
      }),
      child: Container(
          width: 60,
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.secondary, width: 1),
              borderRadius: BorderRadius.circular(10),
              color: Colors.transparent
          ),
          child: Text(
            emoji,
            style: const TextStyle(
                fontSize: 40
            ),
          )
      ),
    );
  }
}

class EmojiInputDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(0),
      child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10)
              )
          ),
          // 🛠️ PERBAIKAN TOTAL: Menggunakan Config kosongan agar kompatibel di SEMUA versi package
          child: EmojiPicker(
            onEmojiSelected: (category, emoji) {
              Navigator.pop(context, emoji.emoji);
            },
            config: const Config(
              columns: 7,
              emojiSizeMax: 32.0,
            ),
          )
      ),
    );
  }

  static Future<String?> show(BuildContext context) {
    return showGeneralDialog<String?>(
        context: context,
        transitionDuration: const Duration(milliseconds: 300),
        barrierDismissible: true,
        barrierLabel: "emoji-input-dialog",
        transitionBuilder: (ctx, anim1, anim2, child) {
          final curvedAnimation = CurvedAnimation(
              parent: anim1,
              curve: Curves.ease
          );

          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: const Offset(0, 0.25)).animate(curvedAnimation),
            child: child,
          );
        },
        pageBuilder: (ctx, anim1, anima2) => EmojiInputDialog()
    );
  }
}
