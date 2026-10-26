import 'package:flutter/material.dart';

const Color _warnaUtama = Color(0xFF0284C7); // ganti untuk Tantangan 1
const Color _warnaTeks = Color(0xFF0F172A);

class PoliwangiProfileApp extends StatelessWidget {
  const PoliwangiProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Profil Mahasiswa TRPL',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _warnaUtama),
        useMaterial3: true,
      ),
      home: const ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    this.nama = 'Leonard Al Afgany',
    this.nim = '362558302132',
    this.githubUsername = 'https://github.com/Kagary77',
    this.fokusKeahlian = 'Fullstack',
  });

  final String nama;
  final String nim;
  final String? githubUsername;
  final String? fokusKeahlian;

  @override
  Widget build(BuildContext context) {
    final List<_ProfileInfoRow> daftarInfo = <_ProfileInfoRow>[
      const _ProfileInfoRow(
        icon: Icons.business_rounded,
        label: 'Jurusan',
        value: 'Bisnis dan Informatika',
      ),
      const _ProfileInfoRow(
        icon: Icons.code_rounded,
        label: 'Program Studi',
        value: 'D4 Teknologi Rekayasa Prengkat Lunak',
      ),
      const _ProfileInfoRow(
        icon: Icons.location_on_rounded,
        label: 'Kampus',
        value: 'Politeknik Negeri Banyuwangi',
      ),
      const _ProfileInfoRow(
        icon: Icons.calendar_today_rounded,
        label: 'Semester / TA',
        value: 'Semester 3 (2026/2027)',
      ),
      // Tantangan 2: null-aware `??` agar UI tidak crash bila data kosong.
      _ProfileInfoRow(
        icon: Icons.link_rounded,
        label: 'Repositori GitHub',
        value: githubUsername ?? '(belum diatur)',
      ),
      _ProfileInfoRow(
        icon: Icons.star_rounded,
        label: 'Fokus Keahlian',
        value: fokusKeahlian ?? '(belum diatur)',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Profil Mahasiswa',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _warnaUtama,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
        // ScrollView: aman di landscape / layar kecil.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Avatar
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    shape: BoxShape.circle,
                    border: Border.all(color: _warnaUtama, width: 3),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    size: 52,
                    color: _warnaUtama,
                  ),
                ),
                const SizedBox(height: 16),

                // Nama
                Text(
                  nama,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _warnaTeks,
                  ),
                ),
                const SizedBox(height: 6),

                // Badge NIM
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'NIM: $nim',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1D4ED8),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Kartu informasi
                Card(
                  elevation: 2,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        for (int i = 0; i < daftarInfo.length; i++) ...[
                          if (i > 0)
                            const Divider(
                              height: 24,
                              color: Color(0xFFF1F5F9),
                            ),
                          daftarInfo[i],
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Tombol verifikasi + SnackBar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Status: Mahasiswa Aktif TRPL — Angkatan 2024',
                            ),
                            backgroundColor: _warnaUtama,
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 3),
                          ),
                        );
                    },
                    icon: const Icon(Icons.verified_user_rounded),
                    label: const Text('Verifikasi Status Mahasiswa'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _warnaUtama,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget reusable untuk tiap baris informasi profil.
class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F9FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: _warnaUtama),
        ),
        const SizedBox(width: 14),
        // Expanded: teks panjang wrap ke bawah, tidak overflow.
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _warnaTeks,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
