import 'package:flutter/material.dart';

import '../models/krs_course.dart';
import '../widgets/krs_course_tile.dart';
import 'add_krs_screen.dart';
import 'course_detail_screen.dart';

const int batasSksSemester = 24;
const int ambangPeringatanSks = 21;

class KrsListScreen extends StatefulWidget {
  const KrsListScreen({super.key});

  @override
  State<KrsListScreen> createState() => _KrsListScreenState();
}

class _KrsListScreenState extends State<KrsListScreen> {
  /// `List<KrsCourse>.of(...)`: list `const` tidak dapat diubah. Tanpa
  /// penyalinan ini add() dan removeWhere() melempar UnsupportedError.
  final List<KrsCourse> _courses =
      List<KrsCourse>.of(KrsCourse.getInitialCourses());

  int get _totalSks =>
      _courses.fold(0, (jumlah, course) => jumlah + course.sks);

  // Tidak ada nilai yang dikembalikan.
  void _bukaDetail(KrsCourse course) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => CourseDetailScreen(course: course),
      ),
    );
  }

  // Menerima hasil lewat Navigator.pop.
  Future<void> _bukaFormTambah() async {
    final KrsCourse? courseBaru = await Navigator.push<KrsCourse>(
      context,
      MaterialPageRoute<KrsCourse>(builder: (_) => const AddKrsScreen()),
    );

    // Tombol kembali ditekan tanpa menyimpan.
    if (!mounted || courseBaru == null) return;

    final bool duplikat = _courses.any(
      (course) => course.code.toUpperCase() == courseBaru.code.toUpperCase(),
    );
    if (duplikat) {
      _tampilkanPesan('Kode ${courseBaru.code} sudah ada di rencana studi.');
      return;
    }

    final int totalBaru = _totalSks + courseBaru.sks;
    if (totalBaru > batasSksSemester) {
      _tampilkanPesan(
        'Total SKS akan menjadi $totalBaru, melebihi batas '
        '$batasSksSemester SKS.',
      );
      return;
    }

    setState(() => _courses.add(courseBaru));
    _tampilkanPesan('${courseBaru.name} ditambahkan ke rencana studi.');
  }

  Future<void> _konfirmasiHapus(KrsCourse course) async {
    // Ambil warna SEBELUM await agar tidak memakai context setelah jeda.
    final Color errorColor = Theme.of(context).colorScheme.error;

    final bool? dikonfirmasi = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus mata kuliah?'),
        content: Text(
          'Yakin ingin membatalkan pengambilan "${course.name}" '
          '(${course.sks} SKS)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: errorColor),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (!mounted || dikonfirmasi != true) return;

    setState(() => _courses.removeWhere((item) => item.code == course.code));
    _tampilkanPesan('${course.name} dihapus dari rencana studi.');
  }

  void _tampilkanPesan(String teks) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(teks), behavior: SnackBarBehavior.floating),
      );
  }

  Widget _buildRingkasan() {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool hampirPenuh = _totalSks >= ambangPeringatanSks;
    final Color warna = hampirPenuh ? colors.error : colors.primary;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.school_outlined, color: warna),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Total SKS: $_totalSks / $batasSksSemester',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: warna,
                    ),
                  ),
                ),
                Text(
                  '${_courses.length} mata kuliah',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: (_totalSks / batasSksSemester).clamp(0.0, 1.0).toDouble(),
              color: warna,
              minHeight: 6,
              borderRadius: BorderRadius.circular(4),
            ),
            if (hampirPenuh)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Mendekati batas maksimal $batasSksSemester SKS per semester.',
                  style: TextStyle(fontSize: 12, color: colors.error),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildKosong() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 64),
            SizedBox(height: 16),
            Text(
              'Belum ada mata kuliah di rencana studi.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Tekan tombol Tambah untuk mengisi KRS.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rencana Studi (KRS)')),
      body: Column(
        children: [
          _buildRingkasan(),
          Expanded(
            child: _courses.isEmpty
                ? _buildKosong()
                : ListView.builder(
                    // Ruang bawah agar baris terakhir tidak tertutup FAB.
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
                    itemCount: _courses.length,
                    itemBuilder: (context, index) {
                      final KrsCourse course = _courses[index];
                      return KrsCourseTile(
                        course: course,
                        onTap: () => _bukaDetail(course),
                        onDelete: () => _konfirmasiHapus(course),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _bukaFormTambah,
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }
}