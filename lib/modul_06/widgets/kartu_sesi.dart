import 'package:flutter/material.dart';

import '../models/sesi_pengguna.dart';

class KartuSesi extends StatelessWidget {
  final SesiPengguna sesi;

  /// Waktu acuan untuk menghitung sisa masa berlaku.
  final DateTime sekarang;

  final VoidCallback? onKeluar;
  final bool sedangKeluar;

  /// Menampilkan token apa adanya. Default `false`.
  final bool tampilkanToken;

  const KartuSesi({
    super.key,
    required this.sesi,
    required this.sekarang,
    this.onKeluar,
    this.sedangKeluar = false,
    this.tampilkanToken = false,
  });

  /// Menyamarkan token: hanya 6 karakter awal yang terlihat.
  static String samarkanToken(String token) {
    if (token.isEmpty) return '(kosong)';
    if (token.length <= 6) return _titik(token.length);
    return '${token.substring(0, 6)}${_titik(12)}';
  }

  static String _titik(int jumlah) =>
      List<String>.filled(jumlah, '\u2022').join();

  /// `2026-09-21T10:15:00.000` → `21 Sep 2026, 10:15`.
  static String formatWaktu(String iso) {
    const List<String> bulan = <String>[
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final DateTime? waktu = DateTime.tryParse(iso);
    if (waktu == null) return 'tidak diketahui';
    final String jam = waktu.hour.toString().padLeft(2, '0');
    final String menit = waktu.minute.toString().padLeft(2, '0');
    return '${waktu.day} ${bulan[waktu.month - 1]} ${waktu.year}, $jam:$menit';
  }

  /// Duration → `1 jam 5 menit` / `45 detik`.
  static String formatSisa(Duration sisa) {
    if (sisa.inSeconds <= 0) return 'sudah berakhir';
    if (sisa.inMinutes < 1) return '${sisa.inSeconds} detik';
    if (sisa.inHours < 1) return '${sisa.inMinutes} menit';
    final int menit = sisa.inMinutes.remainder(60);
    return menit == 0
        ? '${sisa.inHours} jam'
        : '${sisa.inHours} jam $menit menit';
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme warna = Theme.of(context).colorScheme;
    final Duration sisa = sesi.sisaWaktu(sekarang);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 24,
                  backgroundColor: warna.primaryContainer,
                  foregroundColor: warna.onPrimaryContainer,
                  child: const Icon(Icons.person_rounded),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        sesi.nama,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        sesi.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: warna.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 28),
            _BarisInfo(
              ikon: Icons.badge_outlined,
              label: 'Peran',
              nilai: SesiPengguna.labelPeran(sesi.peran),
            ),
            _BarisInfo(
              ikon: Icons.login_rounded,
              label: 'Masuk pada',
              nilai: formatWaktu(sesi.masukPada),
            ),
            _BarisInfo(
              ikon: Icons.timer_outlined,
              label: 'Sisa masa berlaku',
              nilai: formatSisa(sisa),
            ),
            _BarisInfo(
              ikon: Icons.key_outlined,
              label: 'Token',
              nilai: tampilkanToken ? sesi.token : samarkanToken(sesi.token),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: sedangKeluar ? null : onKeluar,
                icon: sedangKeluar
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.logout_rounded),
                label: Text(sedangKeluar ? 'Keluar…' : 'Keluar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarisInfo extends StatelessWidget {
  const _BarisInfo({
    required this.ikon,
    required this.label,
    required this.nilai,
  });

  final IconData ikon;
  final String label;
  final String nilai;

  @override
  Widget build(BuildContext context) {
    final ColorScheme warna = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          Icon(ikon, size: 18, color: warna.primary),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: warna.onSurfaceVariant),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              nilai,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}