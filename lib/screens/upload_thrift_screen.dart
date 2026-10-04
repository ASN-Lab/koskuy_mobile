import 'package:flutter/material.dart';
import 'package:koskuy_mobile/services/api_service_auth.dart';

class UploadThriftScreen extends StatefulWidget {
  const UploadThriftScreen({super.key});

  @override
  State<UploadThriftScreen> createState() => _UploadThriftScreenState();
}

class _UploadThriftScreenState extends State<UploadThriftScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _conditionController = TextEditingController();
  final _categoryController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_titleController.text.isEmpty || _priceController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      // TODO: Implement upload with multipart file
      // Untuk MVP sederhana: simpan ke localStorage terlebih dahulu
      final product = {
        'title': _titleController.text,
        'description': _descController.text,
        'price': int.tryParse(_priceController.text) ?? 0,
        'condition': _conditionController.text,
        'category': _categoryController.text,
      };
      // Save to local storage (placeholder)
      print('Product to upload: $product');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produk berhasil diupload')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Barang Thrift')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Judul Barang', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _descController, maxLines: 3, decoration: const InputDecoration(labelText: 'Deskripsi', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _priceController, decoration: const InputDecoration(labelText: 'Harga (Rp)', prefixText: 'Rp ', border: OutlineInputBorder()), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextField(controller: _conditionController, decoration: const InputDecoration(labelText: 'Kondisi (Contoh: 90% Layak Pakai)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _categoryController, decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder())),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _isLoading ? null : _submit, child: const Text('Upload')),
          ],
        ),
      ),
    );
  }
}
