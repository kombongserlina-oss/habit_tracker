import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'core/constants.dart';
import 'core/theme_provider.dart';
import 'providers/habit_provider.dart';
import 'views/home_screen.dart';
import 'views/login_screen.dart';     // Impor halaman login baru

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase menggunakan variabel dari constants.dart
  await Supabase.initialize(
    url: SupabaseConstants.url,
    anonKey: SupabaseConstants.anonKey,
  );

  runApp(
    // Daftarkan semua Provider (State Management) di sini agar bisa diakses di semua halaman
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => HabitProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Habit Tracker',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.currentTheme,
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      // Sistem proteksi rute: Cek apakah session aktif sudah tersimpan di lokal memori perangkat
      home: Supabase.instance.client.auth.currentSession == null
          ? const LoginScreen() // Jika belum login, tampilkan layar login/register
          : const HomeScreen(), // Jika sudah login, langsung bypass masuk ke beranda utama
    );
  }
}