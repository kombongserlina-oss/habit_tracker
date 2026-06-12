import 'package:flutter/material.dart';
import 'package:project_habits/dialogs/habit_details_dialog/habit_details_dialog_controller.dart';
import 'package:project_habits/dialogs/habit_details_dialog/period_row.dart';
import 'package:project_habits/widgets/circular_button.dart';
import 'package:project_habits/widgets/emoji_input.dart';
import 'package:project_habits/widgets/text_input.dart';
import 'package:provider/provider.dart';

class HabitDetailsDialog extends StatelessWidget {
  final int habitId;

  HabitDetailsDialog(this.habitId);

  @override
  Widget build(BuildContext context) {
    return Provider(
        create: (ctx) => HabitDetailsDialogController(habitId),
        builder: (ctx, child) => Consumer<HabitDetailsDialogController>(
            builder: (ctx, controller, child) {
              return Dialog(
                insetPadding: const EdgeInsets.all(0),
                backgroundColor: Theme.of(context).colorScheme.surface,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CircularButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icons.close_rounded, // Langsung panggil IconData-nya di sini
                          )
                        ],
                      ),
                      Row(
                        children: [
                          EmojiInput(
                            initialEmoji: controller.habit.emoji,
                            onChange: controller.newEmoji,
                          ),
                          VerticalDivider(color: Colors.transparent),
                          EditableText(
                            initialText: controller.habit.text,
                            onChange: (newValue) => controller.newName(newValue),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.transparent),
                      Text("Period", style: TextStyle(fontWeight: FontWeight.bold)),
                      const Divider(color: Colors.transparent, height: 10),
                      PeriodRow(),
                      const Divider(color: Colors.transparent),
                      RichText(
                          text: TextSpan(
                              text: "Start period: ",
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
                              children: [
                                TextSpan(
                                    text: controller.getStartPeriodString(),
                                    style: Theme.of(context).textTheme.titleSmall
                                )
                              ]
                          )
                      ),
                    ],
                  ),
                ),
              );
            }
        )
    );
  }

  static void show(BuildContext context, int habitId) {
    showGeneralDialog(
        context: context,
        barrierLabel: "habit-details-dialog",
        barrierDismissible: true,
        transitionDuration: const Duration(milliseconds: 300),
        transitionBuilder: (ctx, anim1, anim2, child) {
          final curvedAnimation = CurvedAnimation(
              parent: anim1,
              curve: Curves.ease
          );

          return ScaleTransition(
            scale: curvedAnimation,
            child: child,
          );
        },
        pageBuilder: (cts, anim1, anim2) {
          return HabitDetailsDialog(habitId);
        }
    );
  }
}

class EditableText extends StatefulWidget {
  final String initialText;
  final Function(String newText) onChange;

  EditableText({
    required this.initialText,
    required this.onChange
  });

  @override
  _EditableTextState createState() => _EditableTextState();
}

class _EditableTextState extends State<EditableText> {
  late String text;
  bool editing = false;

  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    text = widget.initialText;
    controller.text = text;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(editing) {
      return Expanded(
        // PERBAIKAN: Menyesuaikan parameter TextInput agar cocok dengan file text_input.dart milikmu
        child: TextInput(
          label: "Name",
          hint: "Edit habit name...",
          onChanged: (newValue) {
            text = newValue;
            widget.onChange(text);
          },
        ),
      );
    } else {
      return Expanded(
        child: GestureDetector(
            onTap: () => setState(() {editing = true;}),
            child: Text(text)
        ),
      );
    }
  }
}
