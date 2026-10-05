import 'package:flutter/material.dart';

// Sesuaikan path import dengan struktur proyekmu.
import '../models/announcement.dart';
import '../services/announcement_api.dart';
import '../widgets/announcement_card.dart';
import 'announcement_detail_screen.dart';

class AnnouncementListScreen extends StatefulWidget {
  const AnnouncementListScreen({super.key, this.api});

  /// Dapat disuntikkan dari luar (widget test atau demo offline).
  final AnnouncementApi? api;

  @override
  State<AnnouncementListScreen> createState() => _AnnouncementListScreenState();
}

class _AnnouncementListScreenState extends State<AnnouncementListScreen> {
  static const List<String> _kategori = <String>[
    'Semua',
    ...AnnouncementApi.daftarKategori,
  ];

  late final AnnouncementApi _api = widget.api ?? AnnouncementApi();

  late Future<List<Announcement>> _futurePengumuman;

  String _kategoriTerpilih = 'Semua';

  @override
  void initState() {
    super.initState();
    _futurePengumuman = _api.ambilPengumuman();
  }

  @override
  void dispose() {
    _api.tutup();
    super.dispose();
  }

  // ── Aksi ──────────────────────────────────────────────────────────

  /// Penggantian Future: buat Future baru, lalu tukar lewat setState
  /// supaya FutureBuilder membangun ulang dari keadaan LOADING.
  Future<void> _muatUlang() async {
    final Future<List<Announcement>> futureBaru = _api.ambilPengumuman();
    setState(() {
      _futurePengumuman = futureBaru;
    });

    try {
      await futureBaru;
    } catch (_) {
      // Error sudah ditangani FutureBuilder lewat `snapshot.hasError`.
      // Blok catch ini hanya mencegah "unhandled exception" dan memastikan
      // RefreshIndicator berhenti berputar.
    }
  }

  /// Penyaringan kategori: hanya mengubah state, data tidak diambil ulang.
  void _pilihKategori(String kategori) {
    if (kategori == _kategoriTerpilih) return;
    setState(() => _kategoriTerpilih = kategori);
  }

  void _bukaDetail(Announcement announcement) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => AnnouncementDetailScreen(announcement: announcement),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portal Pengumuman TRPL'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Segarkan Data',
            onPressed: _muatUlang,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          _buildBarisFilter(),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder<List<Announcement>>(
              future: _futurePengumuman,
              builder: (context, snapshot) {
                // ── Keadaan 1: LOADING ────────────────────────────
                if (snapshot.connectionState != ConnectionState.done) {
                  return _buildMemuat();
                }
                // ── Keadaan 2: ERROR ──────────────────────────────
                if (snapshot.hasError) {
                  return _buildGagal(snapshot.error!);
                }
                // ── Keadaan 3 & 4: KOSONG / BERHASIL ──────────────
                final List<Announcement> semua =
                    snapshot.data ?? const <Announcement>[];

                final List<Announcement> tampil = _kategoriTerpilih == 'Semua'
                    ? semua
                    : semua
                        .where(
                          (Announcement item) =>
                              item.category.toLowerCase() ==
                              _kategoriTerpilih.toLowerCase(),
                        )
                        .toList(growable: false);

                if (tampil.isEmpty) return _buildKosong();
                return _buildDaftar(tampil);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Bagian UI ─────────────────────────────────────────────────────

  Widget _buildBarisFilter() {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        itemCount: _kategori.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final String kategori = _kategori[index];
          return ChoiceChip(
            label: Text(kategori),
            selected: kategori == _kategoriTerpilih,
            onSelected: (_) => _pilihKategori(kategori),
          );
        },
      ),
    );
  }

  /// Keadaan 1: LOADING
  Widget _buildMemuat() {
    return const Center(child: CircularProgressIndicator());
  }

  /// Keadaan 2: ERROR (dengan tombol coba lagi)
  Widget _buildGagal(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Gagal memuat pengumuman',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              error.toString().replaceFirst('Exception: ', ''),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _muatUlang,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  /// Keadaan 3: KOSONG (pakai ListView agar tarik-untuk-segarkan tetap bisa)
  Widget _buildKosong() {
    return RefreshIndicator(
      onRefresh: _muatUlang,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: <Widget>[
          const SizedBox(height: 120),
          const Icon(Icons.inbox_outlined, size: 48),
          const SizedBox(height: 12),
          Text(
            _kategoriTerpilih == 'Semua'
                ? 'Belum ada pengumuman'
                : 'Tidak ada pengumuman kategori $_kategoriTerpilih',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Keadaan 4: BERHASIL
  Widget _buildDaftar(List<Announcement> daftar) {
    return RefreshIndicator(
      onRefresh: _muatUlang,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: daftar.length,
        itemBuilder: (context, index) {
          final Announcement item = daftar[index];
          return AnnouncementCard(
            announcement: item,
            onTap: () => _bukaDetail(item),
          );
        },
      ),
    );
  }
}
