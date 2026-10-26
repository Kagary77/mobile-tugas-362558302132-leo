import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'services/auth_api.dart';
import 'services/sesi_memori.dart';

class Modul06App extends StatefulWidget {
  /// Dapat disuntikkan oleh pengujian.
  final AuthApi? api;
  final SesiMemori? sesiMemori;

  /// `--dart-define=LAMBAT=true` → API tiruan lambat 2 detik, supaya
  /// keadaan "sedang memproses" dapat diamati.
  static const bool lambatSimulasi = bool.fromEnvironment('LAMBAT');

  const Modul06App({super.key, this.api, this.sesiMemori});

  @override
  State<Modul06App> createState() => _Modul06AppState();
}

class _Modul06AppState extends State<Modul06App> {
  // `late final`: dibuat sekali, lalu tidak berubah. Inilah yang membuat sesi
  // bertahan selama aplikasi hidup. Jangan buat SesiMemori() di dalam build().
  late final SesiMemori _sesiMemori = widget.sesiMemori ?? SesiMemori();

  late final AuthApi _api = widget.api ??
      (Modul06App.lambatSimulasi
          ? const AuthApi(tunda: Duration(seconds: 2))
          : const AuthApi());

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Modul 06 — Login & Session Dasar',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0284C7)),
        useMaterial3: true,
      ),
      home: LoginScreen(api: _api, sesiMemori: _sesiMemori),
    );
  }
}