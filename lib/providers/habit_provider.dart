import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/habit_model.dart';

class HabitProvider with ChangeNotifier {
  final _supabase = Supabase.instance.client;

  List<Habit> _habits = [];
  Map<String, bool> _selectedDateProgress = {};
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();

  // State tambahan untuk menyimpan perhitungan statistik gamifikasi
  int _currentStreak = 0;
  int _longestStreak = 0;
  Map<String, List<String>> _habitCompletionDates = {}; // Mengelompokkan tanggal selesai per habit_id

  // PERBAIKAN: State penampung data grafik mingguan (Senin = indeks 0, Minggu = indeks 6)
  List<double> _weeklyCompletionCounts = [0, 0, 0, 0, 0, 0, 0];

  // Getter data ke lapisan View
  List<Habit> get habits => _habits;
  Map<String, bool> get selectedDateProgress => _selectedDateProgress;
  bool get isLoading => _isLoading;
  DateTime get selectedDate => _selectedDate;
  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;

  // PERBAIKAN: Getter data grafik untuk StatsScreen
  List<double> get weeklyCompletionCounts => _weeklyCompletionCounts;

  // Helper untuk mengubah DateTime menjadi String murni YYYY-MM-DD tanpa gangguan timezone
  String _formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // 1. Mengubah tanggal aktif dari kalender horizontal strip mingguan
  void changeSelectedDate(DateTime date) {
    _selectedDate = date;
    fetchHabitsForDate(date);
  }

  // 2. Ambil data habit & progress real-time terisolasi berdasarkan user_id aktif
  Future<void> fetchHabitsForDate(DateTime date) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return; // Proteksi jika user belum terautentikasi

    _isLoading = true;
    notifyListeners();

    try {
      // Ambil daftar habit milik user ini saja (Sesuai RLS)
      final habitResponse = await _supabase
          .from('habits')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: true);

      _habits = (habitResponse as List).map((h) => Habit.fromJson(h)).toList();

      // Ambil progres centang pada tanggal spesifik yang sedang ditekan di kalender
      final dateStr = _formatDate(date);
      final progressResponse = await _supabase
          .from('daily_progress')
          .select()
          .eq('date', dateStr);

      // Reset & mapping status centang lokal
      _selectedDateProgress = {};
      for (var habit in _habits) {
        _selectedDateProgress[habit.id] = false; // Default: belum selesai
      }
      for (var p in progressResponse) {
        _selectedDateProgress[p['habit_id']] = p['is_completed'] as bool;
      }

      // Hitung ulang statistik streak & grafik mingguan setiap kali data di-refresh
      await calculateStreaks();
    } catch (e) {
      debugPrint("Error fetching data for date: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 3. Tambah habit baru otomatis menyuntikkan user_id dari Supabase Auth
  Future<void> addHabit(String title, String time) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _supabase.from('habits').insert({
        'user_id': user.id, // Menyediakan data pengenal mutlak pemilik baris data
        'title': title,
        'reminder_time': '$time:00', // Format waktu PostgreSQL TIME (HH:mm:ss)
      });
      await fetchHabitsForDate(_selectedDate);
    } catch (e) {
      debugPrint("Error adding habit: $e");
    }
  }

  // 4. Centang / batalkan progres kebiasaan di tanggal tertentu (Optimistic UI)
  Future<void> toggleHabit(String habitId, bool isDone) async {
    final dateStr = _formatDate(_selectedDate);
    final oldStatus = _selectedDateProgress[habitId] ?? false;

    try {
      // Kepuasan instan (Dopamin): Ubah UI lokal terlebih dahulu tanpa menunggu jaringan cloud
      _selectedDateProgress[habitId] = isDone;
      notifyListeners();

      // Eksekusi ke cloud database Supabase menggunakan UPSERT
      await _supabase.from('daily_progress').upsert({
        'habit_id': habitId,
        'date': dateStr,
        'is_completed': isDone,
      }, onConflict: 'habit_id, date');

      // Rekalkulasi statistik pasca-perubahan data berhasil
      await calculateStreaks();
    } catch (e) {
      debugPrint("Error toggling habit: $e");
      // Rollback data lokal ke kondisi semula jika koneksi internet terputus/gagal
      _selectedDateProgress[habitId] = oldStatus;
      notifyListeners();
    }
  }

  // 5. Logika Psikologi Gamifikasi: Menghitung Streak Beruntun Secara Akurat
  Future<void> calculateStreaks() async {
    final user = _supabase.auth.currentUser;
    if (user == null || _habits.isEmpty) {
      _currentStreak = 0;
      _longestStreak = 0;
      _weeklyCompletionCounts = [0, 0, 0, 0, 0, 0, 0];
      notifyListeners();
      return;
    }

    try {
      // Ambil seluruh riwayat sukses yang pernah dicentang oleh user ini
      final response = await _supabase
          .from('daily_progress')
          .select('date, is_completed')
          .eq('is_completed', true);

      if (response == null || (response as List).isEmpty) {
        _currentStreak = 0;
        _longestStreak = 0;
        _weeklyCompletionCounts = [0, 0, 0, 0, 0, 0, 0];
        notifyListeners();
        return;
      }

      final List<dynamic> progressList = response as List;

      // ================= PERBAIKAN: HITUNG DATA GRAFIK MINGGUAN DARI DATABASE =================
      final DateTime now = DateTime.now();
      // Cari tanggal hari Senin di minggu ini
      final DateTime mondayThisWeek = now.subtract(Duration(days: now.weekday - 1));

      // Buat list 7 hari string (YYYY-MM-DD) mulai dari Senin sampai Minggu berjalan
      List<String> thisWeekDaysStr = List.generate(7, (index) {
        return _formatDate(mondayThisWeek.add(Duration(days: index)));
      });

      // Reset hitungan mingguan lokal
      List<double> updatedWeeklyCounts = [0, 0, 0, 0, 0, 0, 0];

      // Hitung berapa kali habit selesai pada rentang tanggal minggu ini
      for (var progress in progressList) {
        String pDate = progress['date'] as String;
        int dayIndex = thisWeekDaysStr.indexOf(pDate);
        if (dayIndex != -1) {
          updatedWeeklyCounts[dayIndex] += 1; // Tambahkan jumlah habit yang selesai di hari tersebut
        }
      }
      _weeklyCompletionCounts = updatedWeeklyCounts;
      // ========================================================================================

      // Kumpulkan dan bersihkan duplikasi tanggal unik di mana MINIMAL ada satu habit diselesaikan
      final List<String> rawDates = progressList
          .map((item) => item['date'] as String)
          .toList();

      final Set<String> uniqueDatesSet = Set.from(rawDates);
      List<DateTime> sortedDates = uniqueDatesSet
          .map((d) => DateTime.parse(d))
          .toList();

      // Urutkan tanggal dari yang paling lampau hingga paling baru
      sortedDates.sort((a, b) => a.compareTo(b));

      if (sortedDates.isEmpty) return;

      int maxStreak = 0;
      int currentRunningStreak = 0;

      // Hitung Longest Streak historis lewat perulangan gap hari
      for (int i = 0; i < sortedDates.length; i++) {
        if (i == 0) {
          currentRunningStreak = 1;
        } else {
          final difference = sortedDates[i].difference(sortedDates[i - 1]).inDays;
          if (difference == 1) {
            currentRunningStreak++; // Berurutan bertambah 1 hari penuh
          } else if (difference > 1) {
            if (currentRunningStreak > maxStreak) {
              maxStreak = currentRunningStreak;
            }
            currentRunningStreak = 1; // Patah streak, hitung ulang dari 1
          }
        }
      }

      if (currentRunningStreak > maxStreak) {
        maxStreak = currentRunningStreak;
      }

      _longestStreak = maxStreak;

      // Hitung Current Streak (Mundur dari hari ini / kemarin)
      final todayStr = _formatDate(DateTime.now());
      final yesterdayStr = _formatDate(DateTime.now().subtract(const Duration(days: 1)));

      bool hasActivityToday = uniqueDatesSet.contains(todayStr);
      bool hasActivityYesterday = uniqueDatesSet.contains(yesterdayStr);

      if (!hasActivityToday && !hasActivityYesterday) {
        _currentStreak = 0; // Streak resmi hangus kembali ke 0 karena kemarin & hari ini absen
      } else {
        // Cari posisi akhir runtunan rantai tanggal
        int currentStreakCount = 0;
        DateTime checkDate = hasActivityToday ? DateTime.now() : DateTime.now().subtract(const Duration(days: 1));

        while (uniqueDatesSet.contains(_formatDate(checkDate))) {
          currentStreakCount++;
          checkDate = checkDate.subtract(const Duration(days: 1)); // Mundur satu hari terus menerus
        }
        _currentStreak = currentStreakCount;
      }

    } catch (e) {
      debugPrint("Gagal hacker kalkulasi streak data: $e");
    } finally {
      notifyListeners();
    }
  }

  // 6. Logout system clear data lokal cache
  void clearDataOnLogout() {
    _habits = [];
    _selectedDateProgress = {};
    _currentStreak = 0;
    _longestStreak = 0;
    _weeklyCompletionCounts = [0, 0, 0, 0, 0, 0, 0];
    notifyListeners();
  }
}