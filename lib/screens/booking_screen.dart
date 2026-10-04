import 'package:flutter/material.dart';
import '../services/api_service.dart';

class BookingScreen extends StatefulWidget {
  final int kosId;

  const BookingScreen({super.key, required this.kosId});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _dateController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitBooking() async {
    if (_dateController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await ApiService.bookKos(widget.kosId, _dateController.text, _notesController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking berhasil dikirim')));
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
      appBar: AppBar(title: const Text('Booking Kos')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(labelText: 'Tanggal (YYYY-MM-DD)', border: OutlineInputBorder()),
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2026, 12, 31));
                if (date != null) _dateController.text = date.toString().split(' ')[0];
              },
            ),
            const SizedBox(height: 16),
            TextField(controller: _notesController, decoration: const InputDecoration(labelText: 'Catatan', border: OutlineInputBorder()), maxLines: 3),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _isLoading ? null : _submitBooking, child: const Text('Konfirmasi Booking')),
          ],
        ),
      ),
    );
  }
}
