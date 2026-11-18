import 'package:flutter/material.dart';
import '../services/kos_service.dart';

class AddKosPage extends StatefulWidget {
  const AddKosPage({super.key});

  @override
  State<AddKosPage> createState() => _AddKosPageState();
}

class _AddKosPageState extends State<AddKosPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameC = TextEditingController();
  final _addressC = TextEditingController();
  final _priceC = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameC.dispose();
    _addressC.dispose();
    _priceC.dispose();
    super.dispose();
  }

  Future<void> _saveKos() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await KosService().add(
        name: _nameC.text.trim(),
        address: _addressC.text.trim(),
        price: int.parse(_priceC.text.trim()),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true); // Kembali ke Home dan tandai berhasil
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kos berhasil ditambahkan')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambah kos: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Kos Baru')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameC,
                decoration: const InputDecoration(labelText: 'Nama Kos'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressC,
                decoration: const InputDecoration(labelText: 'Alamat Kos'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Alamat wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceC,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Harga per Bulan (Rp)'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Harga wajib diisi';
                  if (int.tryParse(v) == null) return 'Format angka tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _loading ? null : _saveKos,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Simpan Kos'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}