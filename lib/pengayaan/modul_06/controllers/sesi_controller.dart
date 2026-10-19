import 'package:flutter/foundation.dart';

import '../../../modul_06/models/sesi_pengguna.dart';
import '../../../modul_06/services/auth_api.dart';
import '../repositories/sesi_repository.dart';

enum StatusSesi { memeriksa, keluar, memproses, masuk, gagal, kedaluwarsa }

/// Penanda "parameter sesi tidak diberikan", supaya `sesi: null`
/// (sengaja mengosongkan) dapat dibedakan dari "jangan diubah".
const Object _tetap = Object();

class SesiController extends ChangeNotifier {
  SesiRepository repository;
  final AuthApi api;
  final DateTime Function() jam;

  SesiController({
    required this.repository,
    required this.api,
    this.jam = DateTime.now,
  });

  StatusSesi _status = StatusSesi.memeriksa;
  SesiPengguna? _sesi;
  String? _pesan;
  bool _dibuang = false;

  StatusSesi get status => _status;
  SesiPengguna? get sesi => _sesi;
  String? get pesan => _pesan;

  Future<void> pulihkan() async {
    _ubah(StatusSesi.memeriksa, bersihkanPesan: true);

    final SesiPengguna? tersimpan = await repository.baca();
    if (tersimpan == null) {
      _ubah(StatusSesi.keluar, sesi: null);
      return;
    }

    if (tersimpan.sudahKedaluwarsa(jam())) {
      await repository.hapus();   // Sesi mati dibuang, bukan dibiarkan.
      _sesi = null;
      _ubah(StatusSesi.kedaluwarsa,
          pesan: 'Sesi Anda sudah berakhir. Silakan masuk kembali.');
      return;
    }

    _ubah(StatusSesi.masuk, sesi: tersimpan);
  }

  Future<void> perbaruiSesi({Duration masaBerlaku = const Duration(hours: 2)}) async {
    final SesiPengguna? sekarang = _sesi;
    if (sekarang == null) return;

    if (sekarang.sudahKedaluwarsa(jam())) {
      await repository.hapus();
      _sesi = null;
      _ubah(StatusSesi.kedaluwarsa,
          pesan: 'Sesi sudah berakhir dan tidak dapat diperbarui.');
      return;
    }

    final SesiPengguna baru =
        await api.perbaruiSesi(sekarang, masaBerlaku: masaBerlaku);
    await repository.simpan(baru);
    _ubah(StatusSesi.masuk, sesi: baru);
  }

  Future<void> masuk({required String email, required String sandi}) async {
    if (_status == StatusSesi.memproses) return; // Cegah kirim ganda.
    _ubah(StatusSesi.memproses, bersihkanPesan: true);

    try {
      final SesiPengguna hasil = await api.masuk(email: email, sandi: sandi);
      await repository.simpan(hasil);
      _ubah(StatusSesi.masuk, sesi: hasil);
    } on AuthException catch (e) {
      _ubah(StatusSesi.gagal, pesan: e.pesan);
    } catch (e) {
      // Kesalahan tak terduga TIDAK dibocorkan ke layar.
      debugPrint('Login gagal tak terduga: $e');
      _ubah(StatusSesi.gagal,
          pesan: 'Terjadi kesalahan tak terduga. Coba lagi.');
    }
  }

  Future<void> keluar() async {
    await repository.hapus();
    _ubah(StatusSesi.keluar, sesi: null, bersihkanPesan: true);
  }

  /// Berpindah penyimpanan. Sesi lama TIDAK dipindahkan: login ulang
  /// di penyimpanan baru adalah perilaku yang benar.
  Future<void> gantiPenyimpanan(SesiRepository baru) async {
    repository = baru;
    _sesi = null;
    await pulihkan();
  }

  void _ubah(
    StatusSesi status, {
    Object? sesi = _tetap,
    String? pesan,
    bool bersihkanPesan = false,
  }) {
    if (_dibuang) return; // Setara dengan `if (!mounted) return;`.
    _status = status;
    if (!identical(sesi, _tetap)) _sesi = sesi as SesiPengguna?;
    _pesan = pesan ?? (bersihkanPesan ? null : _pesan);
    notifyListeners();
  }

  @override
  void dispose() {
    _dibuang = true;
    super.dispose();
  }
}