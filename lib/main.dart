import 'package:flutter/material.dart';
import 'package:project_habits/pages/home_page/home_page.dart';
import 'package:project_habits/services/data_service.dart';
import 'package:get_it/get_it.dart';
import 'package:project_habits/services/theme_service.dart';
import 'package:project_habits/widgets/life_cycle_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dataService = DataService();
  await dataService.init();
  GetIt.I.registerSingleton(dataService);

  final themeService = ThemeService();
  await themeService.init();
  GetIt.I.registerSingleton(themeService);

  // 🛠️ PERBAIKAN 1: Hapus tanda seru (!) agar kompatibel dengan Flutter SDK modern
  WidgetsBinding.instance.addObserver(
      LifeCycleHandler(
          resumeCallBack: () async => themeService.updateThemeStatus(themeService.themeStatus)
      )
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeService = GetIt.I.get<ThemeService>();

    return StreamBuilder<ThemeData>(
        stream: themeService.theme.stream,
        initialData: themeService.theme.value,
        builder: (context, snapshot) {
          // 🛠️ PERBAIKAN 2: Jika data tema belum siap dari Stream, jangan kasih layar putih kosong, tapi kasih loading spinner
          if (!snapshot.hasData) {
            return const MaterialApp(
              home: Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          // 🛠️ PERBAIKAN 3: Struktur dibalik. MaterialApp harus di paling luar, baru AnimatedTheme membungkus HomePage.
          // Ini adalah standar Flutter agar perpindahan tema teranimasi dengan baik tanpa merusak Scaffold.
          return MaterialApp(
            theme: snapshot.data,
            debugShowCheckedModeBanner: false,
            home: AnimatedTheme(
              duration: const Duration(milliseconds: 500),
              data: snapshot.data!,
              child: HomePage(),
            ),
          );
        }
    );
  }
}
