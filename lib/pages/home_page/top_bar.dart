import 'package:flutter/material.dart';
import 'package:project_habits/dialogs/settings_dialog/settings_dialog.dart';
import 'package:project_habits/pages/home_page/home_page_controller.dart';
import 'package:project_habits/widgets/circular_button.dart';
import 'package:provider/provider.dart';

class TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HomePageController>(context);

    return Padding(
      padding: const EdgeInsets.only(top: 5, left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 🛠️ PERBAIKAN: Membungkus dengan Padding karena CircularButton tidak punya properti padding
          Padding(
            padding: const EdgeInsets.all(10),
            child: CircularButton(
              onPressed: () => controller.showFullYearDialog(context),
              icon: Icons.calendar_today, // Langsung IconData
            ),
          ),
          StreamBuilder<DateTime>(
              stream: controller.selectedMonth.stream,
              initialData: controller.selectedMonth.value,
              builder: (context, snapshot) {
                final selectedDate = snapshot.data!;

                return Text(
                    selectedDate.year.toString(),
                    style: Theme.of(context).textTheme.headlineSmall
                );
              }
          ),
          // 🛠️ PERBAIKAN: Membungkus dengan Padding karena CircularButton tidak punya properti padding
          Padding(
            padding: const EdgeInsets.all(10),
            child: CircularButton(
              onPressed: () => SettingsDialog.show(context),
              icon: Icons.settings, // Langsung IconData
            ),
          ),
        ],
      ),
    );
  }
}
