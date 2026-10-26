import 'package:flutter/material.dart';

import 'models/course.dart';
import 'widgets/course_card.dart';
import 'widgets/header_banner.dart';

/// Tema tetap dimiliki `MaterialApp` (modul_02_app.dart). Layar ini hanya
/// menyimpan state lokal: kategori filter yang dipilih.
class AcademicDashboardScreen extends StatefulWidget {
  const AcademicDashboardScreen({
    super.key,
    this.themeMode = ThemeMode.light,
    this.onToggleTheme,
  });

  final ThemeMode themeMode;
  final VoidCallback? onToggleTheme;

  @override
  State<AcademicDashboardScreen> createState() =>
      _AcademicDashboardScreenState();
}

class _AcademicDashboardScreenState extends State<AcademicDashboardScreen> {
  static const List<String> _kategori = ['Semua', 'Teori', 'Praktikum'];

  // Daftar tetap selama aplikasi hidup, jadi cukup data statis.
  static final List<Course> _courses = Course.getSampleCourses();

  String _selectedCategory = 'Semua';

  bool get _isDarkMode => widget.themeMode == ThemeMode.dark;

  // fold(): menjumlahkan bobot SKS seluruh mata kuliah.
  int get _totalSks => _courses.fold(0, (sum, c) => sum + c.sks);

  List<Course> get _tampil => _selectedCategory == 'Semua'
      ? _courses
      : _courses.where((c) => c.category == _selectedCategory).toList();

  Widget _buildFilter() {
    return Wrap(
      spacing: 8.0,
      children: _kategori.map((category) {
        return ChoiceChip(
          label: Text(category),
          selected: _selectedCategory == category,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _selectedCategory = category;
              });
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildKosong() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(child: Text('Tidak ada mata kuliah pada kategori ini.')),
    );
  }

  HeaderBanner _buildBanner() {
    return HeaderBanner(
      jumlahMatkul: _courses.length,
      totalSks: _totalSks,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tampil = _tampil;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard Akademik TRPL',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0284C7),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              _isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
            tooltip: _isDarkMode ? 'Mode Terang' : 'Mode Gelap',
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      // LayoutBuilder membaca lebar area untuk memilih tata letak.
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Tablet / landscape: 2 kolom
          if (constraints.maxWidth >= 600) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView(child: _buildBanner()),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFilter(),
                        const SizedBox(height: 12),
                        Expanded(
                          child: tampil.isEmpty
                              ? _buildKosong()
                              : GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithMaxCrossAxisExtent(
                                    // Lebar kartu maksimal 340 dp; jumlah
                                    // kolom menyesuaikan ruang yang ada.
                                    maxCrossAxisExtent: 340,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    // Tinggi eksplisit agar isi kartu muat.
                                    mainAxisExtent: 240,
                                  ),
                                  itemCount: tampil.length,
                                  itemBuilder: (context, index) {
                                    return CourseCard(course: tampil[index]);
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          // Smartphone: 1 kolom
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildBanner(),
              const SizedBox(height: 16),
              Text(
                'Mata Kuliah Semester 5 (${tampil.length} Ditampilkan)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildFilter(),
              const SizedBox(height: 12),
              if (tampil.isEmpty)
                _buildKosong()
              else
                ...tampil.map((course) => CourseCard(course: course)),
            ],
          );
        },
      ),
    );
  }
}