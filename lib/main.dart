import 'package:flutter/material.dart';

import 'modul_01/profile_screen.dart';
import 'modul_02/modul_02_app.dart';
import 'modul_03/modul_03_app.dart';
import 'modul_04/modul_04_app.dart';
import 'modul_05/modul_05_app.dart';
import 'modul_06/modul_06_app.dart';

/// Pilih modul yang dijalankan: ubah angka bawaan ini, atau jalankan
/// `flutter run --dart-define=MODUL=3`.
/// 1–6 = Modul 01–06, 21 = KopiKita (tugas rumah Modul 02).
const int modulAktif = int.fromEnvironment('MODUL', defaultValue: 1);

void main() => runApp(_pilihModul(modulAktif));

Widget _pilihModul(int nomor) {
  switch (nomor) {
    case 2:
      return const Modul02App();
    case 3:
      return const Modul03App();
    case 4:
      return const Modul04App();
    case 5:
      return const Modul05App();
    case 6:
      return const Modul06App();
    default:
      return const PoliwangiProfileApp();
  }
}