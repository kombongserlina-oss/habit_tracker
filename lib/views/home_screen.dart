import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/habit_provider.dart';
import '../core/theme_provider.dart';
import '../core/notification_service.dart'; // Import service notifikasi baru
import '../widgets/habit_tile.dart';
import 'add_habit_screen.dart';
import 'stats_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _loadDataAndScheduleReminders();
  }

  // Fungsi sinkronisasi data sekaligus memperbarui antrean pengingat lokal perangkat
  Future<void> _loadDataAndScheduleReminders() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        final habitProv = context.read<HabitProvider>();
        // 1. Ambil data terupdate dari Supabase
        await habitProv.fetchHabitsForDate(habitProv.selectedDate);

        // 2. Bersihkan alarm lama dengan proteksi try-catch agar aman jika plugin belum siap
        try {
          await NotificationService.cancelAllNotifications();
        } catch (e) {
          debugPrint("Gagal membersihkan notifikasi berkala: $e");
        }

        // 3. Daftarkan semua pengingat habit aktif milik user ini ke perangkat lokal
        for (int i = 0; i < habitProv.habits.length; i++) {
          final habit = habitProv.habits[i];
          try {
            await NotificationService.scheduleDailyNotification(
              id: habit.id.hashCode, // Mengonversi UUID string menjadi integer ID unik
              title: habit.title,
              timeString: habit.reminderTime,
            );
          } catch (e) {
            debugPrint("Gagal mendaftarkan pengingat untuk ${habit.title}: $e");
          }
        }
      }
    });
  }

  Future<void> _handleLogout() async {
    try {
      // Amankan navigator root sebelum jeda await async agar tidak tersesat di memori
      final navigatorState = Navigator.of(context, rootNavigator: true);

      // 1. Bersihkan data lokal pada provider terlebih dahulu
      context.read<HabitProvider>().clearDataOnLogout();

      // 2. Amankan pembersihan notifikasi agar jika terjadi error inisialisasi tidak membatalkan logout
      try {
        await NotificationService.cancelAllNotifications();
      } catch (notificationError) {
        debugPrint("Abaikan error notifikasi saat logout: $notificationError");
      }

      // 3. Lakukan proses keluar dari server Supabase
      try {
        await Supabase.instance.client.auth.signOut();
      } catch (supabaseError) {
        debugPrint("Abaikan error Supabase auth: $supabaseError");
      }

      // 4. Alihkan paksa rute halaman kembali bersih ke gerbang Login
      navigatorState.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    } catch (e) {
      debugPrint("Gagal total proses logout: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitProv = Provider.of<HabitProvider>(context);
    final themeProv = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
            "HabitLoop",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          // POSISI DIUBAH: Tombol ubah tema dipindahkan ke sebelah kiri
          IconButton(
            icon: Icon(themeProv.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Ubah Tema',
            onPressed: () => themeProv.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Keluar Akun',
            onPressed: () {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Keluar Aplikasi?'),
                  content: const Text('Kamu perlu memasukkan email kembali untuk sinkronisasi progres berikutnya.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext); // Tutup dialognya menggunakan dialogContext secara eksplisit
                        _handleLogout(); // Jalankan fungsi logout pembersih total rute
                      },
                      child: const Text('Keluar', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          // ================= WIDGET KALENDER ADAPTIF (BULANAN / MINGGUAN) =================
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 0,
            color: isDark ? Colors.grey[900] : Colors.grey[100],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              // 🟢 PERBAIKAN 1: Dibungkus dengan SingleChildScrollView agar konten kalender aman dari error overflow di HP kecil
              child: SingleChildScrollView(
                child: TableCalendar(
                  firstDay: DateTime.utc(2025, 1, 1),
                  lastDay: DateTime.utc(2035, 12, 31),
                  focusedDay: habitProv.selectedDate,
                  calendarFormat: _calendarFormat,
                  startingDayOfWeek: StartingDayOfWeek.monday, // Kalender dimulai dari hari Senin
                  weekendDays: const [DateTime.sunday], // Hanya hari Minggu yang dianggap weekend (merah)

                  // 🟢 PERBAIKAN 2: Mengunci ukuran tinggi baris tanggal agar lebih proporsional di layar sempit
                  rowHeight: 45,
                  daysOfWeekHeight: 22,

                  availableCalendarFormats: const {
                    CalendarFormat.month: '1 Bulan',
                    CalendarFormat.week: '1 Minggu',
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  selectedDayPredicate: (day) {
                    return isSameDay(habitProv.selectedDate, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) async {
                    habitProv.changeSelectedDate(selectedDay);
                    // Otomatis tarik data baru dan set ulang notifikasi saat tanggal kalender diklik
                    await habitProv.fetchHabitsForDate(selectedDay);
                  },
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    defaultTextStyle: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    weekendTextStyle: const TextStyle(color: Colors.redAccent),
                    selectedDecoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    todayDecoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: true,
                    formatButtonShowsNext: false,
                    formatButtonDecoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    formatButtonTextStyle: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87
                    ),
                    leftChevronIcon: Icon(Icons.chevron_left, color: theme.colorScheme.primary),
                    rightChevronIcon: Icon(Icons.chevron_right, color: theme.colorScheme.primary),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12),
                    weekendStyle: const TextStyle(color: Colors.redAccent, fontSize: 12),
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Rutinitas Harian",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "${habitProv.selectedDate.day}/${habitProv.selectedDate.month}/${habitProv.selectedDate.year}",
                  style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // ================= DAFTAR HABIT PADA TANGGAL TERPILIH =================
          Expanded(
            child: habitProv.isLoading
                ? const Center(child: CircularProgressIndicator())
                : habitProv.habits.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_turned_in_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    "Belum ada kebiasaan terjadwal.",
                    style: TextStyle(color: Colors.grey[500], fontSize: 16),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadDataAndScheduleReminders, // Tarik ulang data dan reset alarm saat diswipe kebawah
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: habitProv.habits.length,
                itemBuilder: (context, index) {
                  final habit = habitProv.habits[index];
                  final isDone = habitProv.selectedDateProgress[habit.id] ?? false;

                  return HabitTile(
                    title: habit.title,
                    reminderTime: habit.reminderTime,
                    isCompleted: isDone,
                    onChanged: (val) {
                      if (val != null) {
                        habitProv.toggleHabit(habit.id, val);
                      }
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 2,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        child: const Icon(Icons.add),
        onPressed: () async {
          // Menunggu kembalinya user dari halaman tambah habit
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddHabitScreen()),
          );
          // Perbarui notifikasi lokal jika ada penambahan jadwal habit baru
          _loadDataAndScheduleReminders();
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Kalender"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Statistik"),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, anim1, anim2) => const StatsScreen(),
                transitionDuration: Duration.zero,
              ),
            );
          }
        },
      ),
    );
  }
}