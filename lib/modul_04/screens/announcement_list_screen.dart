import 'package:flutter/material.dart';

import '../models/announcement.dart';
import '../services/announcement_api.dart';
import '../widgets/announcement_card.dart';
import 'announcement_detail_screen.dart';

class AnnouncementListScreen extends StatefulWidget {
  const AnnouncementListScreen({super.key, this.api});

  /// Dapat disuntikkan dari luar (widget test atau demo offline).
  final AnnouncementApi? api;

  @override
  State<AnnouncementListScreen> createState() =>
      _AnnouncementListScreenState();
}

class _AnnouncementListScreenState extends State<AnnouncementListScreen> {
  static const List<String> _kategori = <String>[
    'Semua',
    'Akademik',
    'Beasiswa',
    'Kegiatan',
    'Prestasi',
  ];

  late final AnnouncementApi _api = widget.api ?? AnnouncementApi();

  // Future disimpan di State, BUKAN dibuat di dalam build().
  late Future<List<Announcement>> _futurePengumuman;

  String _kategoriTerpilih = 'Semua';

  @override
  void initState() {
    super.initState();
    _futurePengumuman = _api.ambilPengumuman(); // sekali saja
  }

  @override
  void dispose() {
    _api.tutup();
    super.dispose();
  }

  Future<void> _muatUlang() async {
    final Future<List<Announcement>> futureBaru = _api.ambilPengumuman();
    setState(() {
      _futurePengumuman = futureBaru; // satu-satunya tempat penggantian
    });

    try {
      await futureBaru;
    } catch (_) {
      // Error sudah ditangani FutureBuilder lewat `snapshot.hasError`.
      // Blok ini mencegah "unhandled exception" dan menghentikan
      // putaran RefreshIndicator.
    }
  }

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
                // Keadaan 1: MEMUAT
                if (snapshot.connectionState != ConnectionState.done) {
                  return _buildMemuat();
                }
                // Keadaan 2: GAGAL
                if (snapshot.hasError) {
                  return _buildGagal(snapshot.error!);
                }
                // Keadaan 3 & 4: KOSONG / BERHASIL
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

  Widget _buildBarisFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: <Widget>[
          for (final String kategori in _kategori)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(kategori),
                selected: _kategoriTerpilih == kategori,
                onSelected: (_) => _pilihKategori(kategori),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMemuat() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Memuat pengumuman dari server...'),
        ],
      ),
    );
  }

  Widget _buildGagal(Object error) {
    final String pesan = error.toString().replaceFirst('Exception: ', '');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.cloud_off_outlined, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Gagal Memuat Pengumuman',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(pesan, textAlign: TextAlign.center),
            const SizedBox(height: 20),
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

  Widget _buildKosong() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.inbox_outlined, size: 64),
            const SizedBox(height: 16),
            Text(
              'Belum ada pengumuman pada kategori "$_kategoriTerpilih".',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 8),
            const Text(
              'Coba pilih kategori lain.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaftar(List<Announcement> tampil) {
    return RefreshIndicator(
      onRefresh: _muatUlang,
      child: ListView.builder(
        // Agar tarik-untuk-segarkan bekerja walau daftar pendek.
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: tampil.length,
        itemBuilder: (context, index) {
          final Announcement item = tampil[index];
          return AnnouncementCard(
            announcement: item,
            onTap: () => _bukaDetail(item),
          );
        },
      ),
    );
  }
}