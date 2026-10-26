import '../models/sesi_pengguna.dart';

/// Sesi hidup di memori proses: hilang saat aplikasi benar-benar ditutup.
/// Semua metode tetap `Future` agar pemanggil tidak terbiasa dengan
/// penyimpanan yang serba instan.
class SesiMemori {
  SesiPengguna? _sesi;

  int jumlahPenulisan = 0; // Dipakai pengujian.

  SesiPengguna? baca() => _sesi;

  bool get adaSesi => _sesi != null;

  Future<void> simpan(SesiPengguna sesi) async {
    _sesi = sesi;
    jumlahPenulisan++;
  }

  Future<void> hapus() async {
    _sesi = null;
  }
}