import 'package:flutter/material.dart';
import 'package:project_habits/dialogs/habits_dialogs/habits_dialog_controller.dart';
import 'package:project_habits/models/habit.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HabitsList extends StatelessWidget {
  const HabitsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HabitsDialogController>(context);

    return StreamBuilder<Map<int, Habit>>(
      stream: controller.habits.stream,
      initialData: controller.habits.value,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No habits yet"));
        }

        final habitsMap = snapshot.data!;
        final habitsKeys = habitsMap.keys.toList();

        return ListView.builder(
          padding: const EdgeInsets.all(0),
          itemCount: habitsKeys.length,
          itemBuilder: (ctx, i) {
            final habit = habitsMap[habitsKeys[i]]!;

            return Slidable(
              key: ValueKey(habit.id),
              // PERBAIKAN: Slidable 3.x menggunakan endActionPane untuk aksi di sisi kanan
              endActionPane: ActionPane(
                motion: const BehindMotion(),
                extentRatio: 0.25,
                children: [
                  SlidableAction(
                    onPressed: (slidableContext) {
                      // PERBAIKAN: Menggunakan 'context' dari method build utama
                      // agar pencarian instansi controller via Provider tetap valid dan aman
                      controller.showDeleteHabitConfirmation(context, habit.id);
                    },
                    backgroundColor: Theme.of(context).highlightColor,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Delete',
                  ),
                ],
              ),
              child: InkWell( // Menggunakan InkWell agar ada efek riak saat ditekan
                onTap: () => controller.showHabitDetailsDialog(context, habit.id),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Text(
                          habit.emoji,
                          // PERBAIKAN: Berdasarkan aturan 3, jika sebelumnya tertulis headline1 -> diganti ke headlineLarge
                          style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              habit.text,
                              // PERBAIKAN: bodyText2 -> bodyMedium
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  controller.getDaysString(habit),
                                  // PERBAIKAN: subtitle1 -> titleMedium
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  habit.startPeriod != null
                                      ? "Start: ${controller.getStartPeriodString(habit.startPeriod!)}"
                                      : "",
                                  // PERBAIKAN: subtitle1 -> titleMedium
                                  style: Theme.of(context).textTheme.titleMedium,
                                )
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}