import 'package:flutter/material.dart';
import 'package:project_habits/pages/home_page/home_page_controller.dart';
import 'package:project_habits/utils/consts.dart';
import 'package:provider/provider.dart';

class DayBox extends StatelessWidget {
  const DayBox({Key? key}) : super(key: key); // Best practice: Tambahkan Key

  @override
  Widget build(BuildContext context) {
    // Listen: true secara default dari Provider.of
    final controller = Provider.of<HomePageController>(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        // primaryColor masih bisa digunakan, tapi disarankan menggunakan colorScheme.primary
        color: Theme.of(context).colorScheme.primary,
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: StreamBuilder<int>(
        stream: controller.selectedDayindex.stream,
        initialData: controller.selectedDayindex.value,
        builder: (ctx, snapshot) {
          final dayIndex = snapshot.data ?? 0;
          final selectedDay = DateTime(
            controller.selectedMonth.value.year,
            controller.selectedMonth.value.month,
            dayIndex + 1,
          );

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            switchInCurve: Curves.elasticOut,
            switchOutCurve: Curves.easeInExpo,
            transitionBuilder: (child, animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 2),
                  end: const Offset(0, 0),
                ).animate(animation),
                child: child,
              );
            },
            child: RichText(
              key: ValueKey<DateTime>(selectedDay),
              textAlign: TextAlign.center,
              text: TextSpan(
                // Menggunakan padLeft untuk estetika angka (01, 02, dst)
                text: selectedDay.day.toString().padLeft(2, "0") + "\n",
                // PERBAIKAN: headline1 -> displayLarge
                style: Theme.of(context).textTheme.displayLarge,
                children: [
                  TextSpan(
                    text: DAY_NAMES[selectedDay.weekday - 1].substring(0, 3).toUpperCase(),
                    // PERBAIKAN: headline4 -> headlineMedium
                    style: Theme.of(context).textTheme.headlineMedium,
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}