class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.category,
    required this.date,
    this.readCount = 0,
  });

  final int id;
  final String title;
  final String content;
  final String author;
  final String category;
  final String date; // ISO-8601: 2026-09-01
  final int readCount;

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] as String? ?? 'Tanpa Judul',
      // Endpoint contoh hanya menyediakan `body`.
      content: json['content'] as String? ?? json['body'] as String? ?? '',
      author: json['author'] as String? ?? 'Admin Jurusan',
      category: json['category'] as String? ?? 'Akademik',
      date: json['date'] as String? ?? '2026-09-01',
      readCount: json['readCount'] is int ? json['readCount'] as int : 0,
    );
  }

  // Data simulasi (tanpa kategori Prestasi, untuk membuktikan keadaan kosong).
  static List<Announcement> getSampleAnnouncements() {
    return const [
      Announcement(
        id: 1,
        title: 'Jadwal Ujian Tengah Semester Ganjil 2026/2027',
        content:
            'UTS dilaksanakan pada minggu ke-8. Mahasiswa wajib membawa kartu '
            'ujian dan KTM. Jadwal lengkap tersedia di portal akademik.',
        author: 'Bagian Akademik Poliwangi',
        category: 'Akademik',
        date: '2026-10-05',
        readCount: 128,
      ),
      Announcement(
        id: 2,
        title: 'Pembukaan Beasiswa Prestasi Semester Genap',
        content:
            'Pendaftaran beasiswa dibuka sampai akhir bulan. Persyaratan: IPK '
            'minimal 3.25 dan surat rekomendasi dosen wali.',
        author: 'Bagian Kemahasiswaan',
        category: 'Beasiswa',
        date: '2026-10-08',
        readCount: 245,
      ),
      Announcement(
        id: 3,
        title: 'Seminar Nasional Teknologi Informasi',
        content:
            'Seminar menghadirkan praktisi industri. Peserta mendapatkan '
            'sertifikat dan poin SKPI.',
        author: 'HIMA TRPL',
        category: 'Kegiatan',
        date: '2026-10-12',
        readCount: 98,
      ),
      Announcement(
        id: 4,
        title: 'Perubahan Jadwal Praktikum Pemrograman Mobile',
        content:
            'Praktikum minggu depan dipindahkan ke Lab Komputer 3 pukul 13.00 '
            'WIB. Harap membawa laptop dengan Flutter terpasang.',
        author: 'Bagian Akademik Poliwangi',
        category: 'Akademik',
        date: '2026-10-14',
        readCount: 176,
      ),
      Announcement(
        id: 5,
        title: 'Beasiswa Unggulan Mitra Industri',
        content:
            'Perusahaan mitra membuka beasiswa untuk mahasiswa semester 5 '
            'program studi TRPL.',
        author: 'Bagian Kemahasiswaan',
        category: 'Beasiswa',
        date: '2026-10-16',
        readCount: 112,
      ),
      Announcement(
        id: 6,
        title: 'Lomba Pemrograman Antar Politeknik',
        content:
            'Pendaftaran tim dibuka. Setiap tim terdiri atas tiga mahasiswa '
            'dan satu dosen pendamping.',
        author: 'HIMA TRPL',
        category: 'Kegiatan',
        date: '2026-10-18',
        readCount: 87,
      ),
    ];
  }
}