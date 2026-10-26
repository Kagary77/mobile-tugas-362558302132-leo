import 'package:flutter/material.dart';

import '../models/krs_course.dart';

class AddKrsScreen extends StatefulWidget {
  const AddKrsScreen({super.key});

  @override
  State<AddKrsScreen> createState() => _AddKrsScreenState();
}

class _AddKrsScreenState extends State<AddKrsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lecturerController = TextEditingController();
  final TextEditingController _sksController =
      TextEditingController(text: '3');
  final TextEditingController _descriptionController =
      TextEditingController();

  @override
  void dispose() {
    // Wajib: bebaskan setiap controller agar tidak bocor memori.
    _codeController.dispose();
    _nameController.dispose();
    _lecturerController.dispose();
    _sksController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _simpan() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final KrsCourse courseBaru = KrsCourse(
      code: _codeController.text.trim().toUpperCase(),
      name: _nameController.text.trim(),
      lecturer: _lecturerController.text.trim(),
      sks: int.tryParse(_sksController.text.trim()) ?? 3,
      description: _descriptionController.text.trim(),
    );

    // Form tidak menyimpan; ia mengembalikan objek ke layar pemanggil.
    Navigator.pop(context, courseBaru);
  }

  String? _wajibIsi(String? value, String pesan) {
    if ((value?.trim() ?? '').isEmpty) return pesan;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Mata Kuliah')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Kode mata kuliah',
                  hintText: 'contoh: TRPL506',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final String teks = value?.trim() ?? '';
                  if (teks.isEmpty) return 'Kode mata kuliah wajib diisi';
                  if (teks.length < 4) {
                    return 'Kode minimal terdiri dari 4 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Nama mata kuliah',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    _wajibIsi(value, 'Nama mata kuliah wajib diisi'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lecturerController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Dosen pengampu',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    _wajibIsi(value, 'Nama dosen pengampu wajib diisi'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sksController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Bobot SKS',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final int? sks = int.tryParse(value?.trim() ?? '');
                  if (sks == null) return 'SKS harus berupa angka';
                  if (sks < 1 || sks > 6) return 'SKS harus antara 1 dan 6';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi silabus (opsional)',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _simpan,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}