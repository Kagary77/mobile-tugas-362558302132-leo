class KrsCourse {
  const KrsCourse({
    required this.code,
    required this.name,
    required this.lecturer,
    required this.sks,
    this.description = '',
  });

  final String code;
  final String name;
  final String lecturer;
  final int sks;
  final String description;

  // Mengembalikan list `const` (read-only). Salin dengan List.of(...) bila
  // ingin menambah/menghapus isinya.
  static List<KrsCourse> getInitialCourses() {
    return const [
      KrsCourse(
        code: 'TRPL501',
        name: 'Pemrograman Perangkat Bergerak',
        lecturer: 'Sepyan Purnama Kristanto, M.Kom.',
        sks: 3,
        description:
            'Membangun aplikasi mobile lintas platform dengan Flutter: UI '
            'deklaratif, navigasi, networking, penyimpanan lokal, dan sesi.',
      ),
      KrsCourse(
        code: 'TRPL502',
        name: 'Arsitektur Perangkat Lunak',
        lecturer: 'Tim Dosen TRPL',
        sks: 3,
        description:
            'Prinsip desain arsitektur: layered architecture, pola MVVM, '
            'dan pemisahan tanggung jawab antar komponen.',
      ),
      KrsCourse(
        code: 'TRPL503',
        name: 'Manajemen Proyek Agile & DevOps',
        lecturer: 'Tim Dosen TRPL',
        sks: 3,
        description:
            'Metodologi Scrum dan Kanban, perencanaan sprint, serta '
            'otomasi build dan deployment dengan CI/CD.',
      ),
      KrsCourse(
        code: 'TRPL504',
        name: 'Penjaminan Mutu Perangkat Lunak (QA)',
        lecturer: 'Tim Dosen TRPL',
        sks: 2,
        description:
            'Strategi pengujian: unit test, widget test, dan pengukuran '
            'kualitas kode secara berkelanjutan.',
      ),
      KrsCourse(
        code: 'TRPL505',
        name: 'Interoperabilitas Sistem',
        lecturer: 'Tim Dosen TRPL',
        sks: 3,
        description:
            'Pertukaran data antar sistem melalui REST API, format JSON, '
            'dan dokumentasi layanan dengan Swagger.',
      ),
    ];
  }
}