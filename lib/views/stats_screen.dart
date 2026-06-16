import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/habit_provider.dart';
import 'home_screen.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    // Memastikan perhitungan rentetan (streak) dan data mingguan diperbarui saat layar dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final habitProv = context.read<HabitProvider>();
      habitProv.calculateStreaks();
      // Pastikan fungsi kalkulasi statistik mingguan juga dipicu jika ada di provider kamu
      // habitProv.calculateWeeklyStats();
    });
  }

  // Helper untuk mendapatkan nama hari singkat berdasarkan indeks buatan (1 = Sen, 7 = Min)
  String _getWeekdayName(int value) {
    switch (value) {
      case 1: return 'Sen';
      case 2: return 'Sel';
      case 3: return 'Rab';
      case 4: return 'Kam';
      case 5: return 'Jum';
      case 6: return 'Sab';
      case 7: return 'Min';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitProv = Provider.of<HabitProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // PERBAIKAN: Mengambil data riwayat asli dari database via HabitProvider
    // Jika di HabitProvider kamu belum ada list ini, dia akan otomatis memakai fallback data aman [0,0,0,0,0,0,0]
    final List<double> weeklyData = habitProv.weeklyCompletionCounts ?? [0, 0, 0, 0, 0, 0, 0];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistik Capaian", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= SECTION 1: KARTU WIDGET STREAK (GAMIFIKASI) =================
              Row(
                children: [
                  // Kartu Streak Saat Ini (Current Streak)
                  Expanded(
                    child: Card(
                      elevation: 0,
                      color: theme.colorScheme.primary.withOpacity(0.12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.3)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                        child: Column(
                          children: [
                            const Text(
                              "🔥 Runtunan Aktif",
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.orange),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${habitProv.currentStreak} Hari",
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Kartu Rekor Terpanjang (Longest Streak)
                  Expanded(
                    child: Card(
                      elevation: 0,
                      color: isDark ? Colors.grey[900] : Colors.grey[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                        child: Column(
                          children: [
                            Text(
                              "🏆 Rekor Terjauh",
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.amber[300] : Colors.amber[800]),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${habitProv.longestStreak} Hari",
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.colorScheme.onBackground),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ================= SECTION 2: GRAFIK PERFORMANCE MINGGUAN =================
              const Text(
                "Performa Rutinitas",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                "Frekuensi penyelesaian aktivitas sepanjang minggu ini",
                style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
              const SizedBox(height: 24),

              // Bingkai Grafik Batang FL_CHART
              Container(
                height: 220,
                padding: const EdgeInsets.only(top: 20, right: 16, left: 0),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900]!.withOpacity(0.5) : Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 8,
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: theme.colorScheme.primary,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '${rod.toY.toInt()} Selesai',
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                _getWeekdayName(value.toInt()),
                                style: TextStyle(
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 2,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(color: Colors.grey[500], fontSize: 11),
                            );
                          },
                          reservedSize: 28,
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(weeklyData.length, (index) {
                      return BarChartGroupData(
                        x: index + 1,
                        barRods: [
                          BarChartRodData(
                            toY: weeklyData[index],
                            color: theme.colorScheme.primary,
                            width: 14,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Pesan Evaluasi Psikologis Positif
              Center(
                child: Column(
                  children: [
                    Text(
                      habitProv.currentStreak > 0
                          ? "Status: Ritme terbentuk, terus melangkah! 🚀"
                          : "Status: Ambil satu langkah kecil hari ini! 🌱",
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // Navigasi Bar Bawah Sinkron
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Mengunci index aktif di tab Statistik
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Kalender"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Statistik"),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, anim1, anim2) => const HomeScreen(),
                transitionDuration: Duration.zero,
              ),
            );
          }
        },
      ),
    );
  }
}