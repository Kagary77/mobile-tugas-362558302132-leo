class Task {
  final String id;
  final String title;
  final String course;
  final bool done;
  final String createdAt; // ISO-8601, mis. 2026-09-21
  final int prioritas; // 1 = Tinggi, 2 = Sedang, 3 = Rendah

  const Task({
    required this.id,
    required this.title,
    required this.course,
    required this.createdAt,
    this.done = false,
    this.prioritas = 2,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String? ?? 'tanpa-id',
      title: json['title'] as String? ?? 'Tanpa Judul',
      course: json['course'] as String? ?? 'Umum',
      done: json['done'] is bool ? json['done'] as bool : false,
      createdAt: json['createdAt'] as String? ?? '1970-01-01',
      // Data lama tidak punya kunci 'prioritas'; nilai cadangan 2.
      prioritas: json['prioritas'] is int ? json['prioritas'] as int : 2,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'course': course,
      'done': done,
      'createdAt': createdAt,
      'prioritas': prioritas,
    };
  }

  Task copyWith({
    String? title,
    String? course,
    bool? done,
    int? prioritas,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      course: course ?? this.course,
      done: done ?? this.done,
      createdAt: createdAt,
      prioritas: prioritas ?? this.prioritas,
    );
  }

  static String labelPrioritas(int prioritas) {
    switch (prioritas) {
      case 1:
        return 'Tinggi';
      case 3:
        return 'Rendah';
      default:
        return 'Sedang';
    }
  }

  /// Tanggal dikembalikan menjadi DateTime hanya saat ditampilkan.
  static DateTime? bacaTanggal(Task tugas) => DateTime.tryParse(tugas.createdAt);

  // List `const` = read-only; salin dengan List<Task>.of(...) sebelum diubah.
  static List<Task> getSampleTasks() {
    return const <Task>[
      Task(
        id: 'contoh-1',
        title: 'Menyelesaikan laporan praktikum Modul 04',
        course: 'Pemrograman Perangkat Bergerak',
        createdAt: '2026-09-15',
        prioritas: 1,
      ),
      Task(
        id: 'contoh-2',
        title: 'Membaca materi arsitektur berlapis',
        course: 'Arsitektur Perangkat Lunak',
        createdAt: '2026-09-16',
      ),
      Task(
        id: 'contoh-3',
        title: 'Menyiapkan data uji untuk skenario QA',
        course: 'Penjaminan Mutu Perangkat Lunak',
        createdAt: '2026-09-17',
        prioritas: 3,
      ),
    ];
  }
}