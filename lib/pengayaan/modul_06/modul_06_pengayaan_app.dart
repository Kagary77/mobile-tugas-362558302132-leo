import 'package:flutter/material.dart';

import '../../modul_06/models/sesi_pengguna.dart';
import '../../modul_06/modul_06_app.dart';
import '../../modul_06/services/auth_api.dart';
import '../../modul_06/services/sesi_memori.dart';
import 'controllers/sesi_controller.dart';
import 'repositories/aman_sesi_repository.dart';
import 'repositories/memori_sesi_repository.dart';
import 'repositories/prefs_sesi_repository.dart';
import 'repositories/sesi_repository.dart';
import 'screens/beranda_pengayaan_screen.dart';
import 'screens/login_pengayaan_screen.dart';
import 'storage/penyimpanan_aman_platform.dart';
import 'widgets/gerbang_sesi.dart';

class Modul06PengayaanApp extends StatefulWidget {
  /// Dapat disuntikkan oleh pengujian.
  final AuthApi? api;

  const Modul06PengayaanApp({super.key, this.api});

  @override
  State<Modul06PengayaanApp> createState() => _Modul06PengayaanAppState();
}

class _Modul06PengayaanAppState extends State<Modul06PengayaanApp> {
  late final AuthApi _api = widget.api ??
      (Modul06App.lambatSimulasi
          ? const AuthApi(tunda: Duration(seconds: 2))
          : const AuthApi());

  late final List<SesiRepository> _pilihan = <SesiRepository>[
    MemoriSesiRepository(SesiMemori()),
    PrefsSesiRepository(),
    AmanSesiRepository(penyimpanan: PenyimpananAmanPlatform()),
  ];

  int _aktif = 2; // 0 = Memori, 1 = Prefs, 2 = Aman

  late final SesiController _kendali =
      SesiController(repository: _pilihan[_aktif], api: _api);

  @override
  void initState() {
    super.initState();
    _kendali.pulihkan();
  }

  @override
  void dispose() {
    _kendali.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Modul 06 — Fase B',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0284C7)),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Modul 06 — Fase B: Secure storage'),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              _bangunPenukar(),
              const Divider(height: 1),
              Expanded(
                child: GerbangSesi(
                  controller: _kendali,
                  form: (BuildContext context) =>
                      LoginPengayaanScreen(controller: _kendali),
                  beranda: (BuildContext context, SesiPengguna sesi) =>
                      BerandaPengayaanScreen(controller: _kendali, sesi: sesi),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bangunPenukar() {
    return ListenableBuilder(
      listenable: _kendali,
      builder: (BuildContext context, Widget? _) {
        final bool sibuk = _kendali.status == StatusSesi.memproses;
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SegmentedButton<int>(
                showSelectedIcon: false,
                segments: <ButtonSegment<int>>[
                  for (int i = 0; i < _pilihan.length; i++)
                    ButtonSegment<int>(
                      value: i,
                      label: Text(_pilihan[i].nama),
                    ),
                ],
                selected: <int>{_aktif},
                onSelectionChanged: sibuk
                    ? null
                    : (Set<int> terpilih) {
                        setState(() => _aktif = terpilih.first);
                        _kendali.gantiPenyimpanan(_pilihan[_aktif]);
                      },
              ),
              const SizedBox(height: 8),
              Text(
                _pilihan[_aktif].keterangan,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}
