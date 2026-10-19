import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../modul_06/models/sesi_pengguna.dart';
import 'sesi_repository.dart';

class PrefsSesiRepository implements SesiRepository {
  static const String kunciSesi = 'modul_06_sesi_pengguna';

  final Future<SharedPreferences>? _prefsSuntikan;

  PrefsSesiRepository({Future<SharedPreferences>? prefs})
      : _prefsSuntikan = prefs;

  Future<SharedPreferences> get _prefs =>
      _prefsSuntikan ?? SharedPreferences.getInstance();

  @override
  String get nama => 'Prefs';

  @override
  String get keterangan =>
      'SharedPreferences: bertahan, tetapi token terbaca apa adanya.';

  @override
  bool get bertahanSetelahRestart => true;

  @override
  Future<SesiPengguna?> baca() async {
    final SharedPreferences prefs = await _prefs;
    final String? mentah = prefs.getString(kunciSesi);
    if (mentah == null) return null;

    try {
      final Object? hasil = jsonDecode(mentah);
      if (hasil is! Map<String, dynamic>) {
        throw const FormatException('Bentuk sesi tidak dikenal');
      }
      return SesiPengguna.fromJson(hasil);
    } on FormatException {
      await prefs.remove(kunciSesi); // Data rusak dibuang.
      return null;
    }
  }

  @override
  Future<void> simpan(SesiPengguna sesi) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString('modul_06_sesi_pengguna', jsonEncode(sesi.toJson()));
  }

  @override
  Future<void> hapus() async {
    final SharedPreferences prefs = await _prefs;
    await prefs.remove(kunciSesi);
  }

  @override
  Future<bool> adaSesi() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.containsKey(kunciSesi);
  }

  @override
  Future<String?> intipMentah() async {
    final SharedPreferences prefs = await _prefs;
    // Demonstrasi ini memperlihatkan bahwa adapter preferensi dapat
    // mengembalikan nilai token melalui API biasa.
    return prefs.getString(kunciSesi);
  }
}