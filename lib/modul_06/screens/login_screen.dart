import 'package:flutter/material.dart';

import '../models/sesi_pengguna.dart';
import '../services/auth_api.dart';
import '../services/sesi_memori.dart';
import '../widgets/field_kata_sandi.dart';
import '../widgets/kartu_sesi.dart';

/// Mesin keadaan autentikasi. `keluar` (belum login) BUKAN `gagal` (ditolak).
enum StatusAuth { memeriksa, keluar, memproses, masuk, gagal }

class LoginScreen extends StatefulWidget {
  final AuthApi api;
  final SesiMemori sesiMemori;

  /// Jam disuntikkan agar sisa masa berlaku dapat diuji tanpa jam dinding.
  final DateTime Function() jam;

  const LoginScreen({
    super.key,
    required this.api,
    required this.sesiMemori,
    this.jam = DateTime.now,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _sandi = TextEditingController();

  StatusAuth _status = StatusAuth.memeriksa;
  String? _pesanGagal;
  SesiPengguna? _sesi;
  bool _sedangKeluar = false;

  @override
  void initState() {
    super.initState();
    _pulihkanSesi();
  }

  @override
  void dispose() {
    // Controller juga menyimpan isi kolom; buang agar tidak bertahan.
    _email.dispose();
    _sandi.dispose();
    super.dispose();
  }

  // ── Logika ─────────────────────────────────────────────────────────────
  /// Di Fase A ini selalu berakhir di `keluar`, dan itu yang diharapkan.
  Future<void> _pulihkanSesi() async {
    final SesiPengguna? tersimpan = widget.sesiMemori.baca();
    if (!mounted) return;

    if (tersimpan == null) {
      setState(() => _status = StatusAuth.keluar);
      return;
    }

    if (tersimpan.sudahKedaluwarsa(widget.jam())) {
      await widget.sesiMemori.hapus();
      if (!mounted) return;
      setState(() {
        _status = StatusAuth.gagal;
        _pesanGagal = 'Sesi sebelumnya sudah berakhir. Silakan masuk lagi.';
      });
      return;
    }

    setState(() {
      _sesi = tersimpan;
      _status = StatusAuth.masuk;
    });
  }

  Future<void> _kirim() async {
    if (_status == StatusAuth.memproses) return; // Cegah kirim ganda.
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _status = StatusAuth.memproses;
      _pesanGagal = null;
    });

    try {
      final SesiPengguna hasil = await widget.api.masuk(
        email: _email.text,
        sandi: _sandi.text,
      );
      await widget.sesiMemori.simpan(hasil);
      if (!mounted) return;
      setState(() {
        _sesi = hasil;
        _status = StatusAuth.masuk;
        _sandi.clear(); // Sandi tidak perlu tertinggal di memori.
      });
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _status = StatusAuth.gagal;
        _pesanGagal = e.pesan;
      });
    } catch (e) {
      // Kesalahan tak terduga TIDAK dibocorkan ke layar.
      if (!mounted) return;
      setState(() {
        _status = StatusAuth.gagal;
        _pesanGagal = 'Terjadi kesalahan tak terduga. Coba lagi.';
      });
      debugPrint('Login gagal tak terduga: $e');
    }
  }

  Future<void> _keluar() async {
    setState(() => _sedangKeluar = true);
    await widget.sesiMemori.hapus();
    if (!mounted) return;
    setState(() {
      _sesi = null;
      _status = StatusAuth.keluar; // Bukan StatusAuth.gagal.
      _pesanGagal = null;
      _sedangKeluar = false;
      _email.clear();
      _sandi.clear();
    });
  }

  // Validasi klien hanya penyaring kenyamanan, bukan pengaman.
  static String? _validasiEmail(String? nilai) {
    final String teks = (nilai ?? '').trim();
    if (teks.isEmpty) return 'Email wajib diisi.';
    if (!teks.contains('@') || !teks.contains('.')) {
      return 'Format email belum benar.';
    }
    return null;
  }

  // ── Tampilan ───────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modul 06 — Login & Session Dasar'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SafeArea(child: _bangunIsi()),
    );
  }

  /// Satu-satunya tempat yang memutuskan layar mana yang tampil.
  Widget _bangunIsi() {
    switch (_status) {
      case StatusAuth.memeriksa:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Memeriksa sesi tersimpan…'),
            ],
          ),
        );
      case StatusAuth.masuk:
        final SesiPengguna? sesi = _sesi;
        if (sesi == null) {
          // Tidak seharusnya terjadi; kembali ke form lebih baik
          // daripada layar kosong.
          return _bangunForm();
        }
        return _bangunBeranda(sesi);
      case StatusAuth.keluar:
      case StatusAuth.memproses:
      case StatusAuth.gagal:
        return _bangunForm();
    }
  }

  Widget _bangunForm() {
    final bool sibuk = _status == StatusAuth.memproses;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: ListView(
          padding: const EdgeInsets.all(20),
          shrinkWrap: true,
          children: <Widget>[
            const SizedBox(height: 8),
            const Text(
              'Masuk ke Portal Akademik',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Pesan kegagalan TIDAK tampil pada keadaan keluar.
            if (_pesanGagal != null) ...<Widget>[
              _KotakPesan(pesan: _pesanGagal!),
              const SizedBox(height: 16),
            ],

            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _email,
                    enabled: !sibuk,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    textInputAction: TextInputAction.next,
                    autofillHints: const <String>[AutofillHints.email],
                    validator: _validasiEmail,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.alternate_email_rounded),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FieldKataSandi(
                    controller: _sandi,
                    enabled: !sibuk,
                    validator: (String? nilai) {
                      if (nilai == null || nilai.isEmpty) {
                        return 'Kata sandi wajib diisi.';
                      }
                      if (nilai.length < 8) {
                        return 'Kata sandi minimal 8 karakter.';
                      }
                      return null;
                    },
                    onSubmitted: _kirim,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                // Dua lapis penjaga: penjaga di _kirim + tombol yang mati.
                onPressed: sibuk ? null : _kirim,
                icon: sibuk
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.login_rounded),
                label: Text(sibuk ? 'Memproses…' : 'Masuk'),
              ),
            ),
            const SizedBox(height: 12),
            _KotakInfoDemo(
              onIsiOtomatis: sibuk
                  ? null
                  : () => setState(() {
                        _email.text = AuthApi.emailDemo;
                        _sandi.text = AuthApi.sandiDemo;
                      }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bangunBeranda(SesiPengguna sesi) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        const Text(
          'Beranda',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        KartuSesi(
          sesi: sesi,
          sekarang: widget.jam(),
          onKeluar: _keluar,
          sedangKeluar: _sedangKeluar,
        ),
        const SizedBox(height: 20),
        const _KotakPeringatanMemori(),
      ],
    );
  }
}

// ── Kotak pendukung ──────────────────────────────────────────────────────
class _KotakPesan extends StatelessWidget {
  const _KotakPesan({required this.pesan});

  final String pesan;

  @override
  Widget build(BuildContext context) {
    final ColorScheme warna = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: warna.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.error_outline_rounded, color: warna.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              pesan,
              style: TextStyle(color: warna.onErrorContainer, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _KotakInfoDemo extends StatelessWidget {
  const _KotakInfoDemo({required this.onIsiOtomatis});

  final VoidCallback? onIsiOtomatis;

  @override
  Widget build(BuildContext context) {
    final ColorScheme warna = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: warna.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Akun demo (data dummy)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 6),
          const Text(
            'Berhasil: ${AuthApi.emailDemo} / ${AuthApi.sandiDemo}',
            style: TextStyle(fontSize: 12),
          ),
          const Text(
            'Terkunci: ${AuthApi.emailTerkunci} (sandi apa saja ≥ 8 karakter)',
            style: TextStyle(fontSize: 12),
          ),
          const Text(
            'Server gangguan: ${AuthApi.emailServerGangguan}',
            style: TextStyle(fontSize: 12),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onIsiOtomatis,
              icon: const Icon(Icons.auto_fix_high_outlined, size: 18),
              label: const Text('Isi otomatis'),
            ),
          ),
        ],
      ),
    );
  }
}

class _KotakPeringatanMemori extends StatelessWidget {
  const _KotakPeringatanMemori();

  @override
  Widget build(BuildContext context) {
    final ColorScheme warna = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: warna.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.info_outline_rounded, color: warna.onTertiaryContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Sesi ini hanya ada di memori proses. Tutup aplikasi dari daftar '
              'aplikasi terakhir, lalu buka lagi — sesi akan hilang. Itu hasil '
              'yang diharapkan di Fase A.',
              style: TextStyle(color: warna.onTertiaryContainer, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}