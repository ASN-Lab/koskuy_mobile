import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../services/payment_service.dart';

class PaymentScreen extends StatefulWidget {
  final String type; // 'booking' or 'thrift'
  final int id;
  final String title;

  const PaymentScreen({
    super.key,
    required this.type,
    required this.id,
    required this.title,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  Map<String, dynamic>? _paymentData;
  bool _isLoading = true;
  File? _proofImage;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadPaymentStatus();
  }

  Future<void> _loadPaymentStatus() async {
    setState(() => _isLoading = true);
    try {
      final res = await PaymentService.getPaymentStatus(widget.type, widget.id);
      setState(() {
        _paymentData = res;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _initiatePayment(String method) async {
    setState(() => _isLoading = true);
    try {
      final res = await PaymentService.initiatePayment(widget.type, widget.id, method);
      setState(() {
        _paymentData = res;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _proofImage = File(pickedFile.path));
    }
  }

  Future<void> _uploadProof() async {
    if (_proofImage == null) return;
    setState(() => _isLoading = true);
    try {
      await PaymentService.uploadProof(widget.type, widget.id, _proofImage!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bukti transfer berhasil diunggah!')),
        );
        _loadPaymentStatus();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Pembayaran', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF0F172A),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _paymentData?['data'] == null
              ? _buildMethodSelection()
              : _buildPaymentDetail(),
    );
  }

  Widget _buildMethodSelection() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Pilih metode pembayaran untuk melanjutkan transaksi.', style: TextStyle(color: Color(0xFF64748B))),
          const SizedBox(height: 32),
          _methodCard(
            icon: Icons.account_balance_rounded,
            title: 'Transfer Bank (Manual)',
            subtitle: 'Transfer ke rekening owner/penjual',
            onTap: () => _initiatePayment('transfer'),
          ),
          const SizedBox(height: 16),
          _methodCard(
            icon: Icons.payments_rounded,
            title: 'Bayar di Tempat (COD)',
            subtitle: 'Bayar tunai saat bertemu langsung',
            onTap: () => _initiatePayment('cash'),
          ),
        ],
      ),
    );
  }

  Widget _methodCard({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: const Color(0xFF4F46E5)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetail() {
    final payment = _paymentData!['data'];
    final ownerBank = _paymentData!['owner_bank'];
    final total = _paymentData!['total_transfer'];
    final status = payment['status'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _statusBadge(status),
          const SizedBox(height: 24),
          const Text('Total Pembayaran', style: TextStyle(color: Color(0xFF64748B))),
          Text(
            'Rp ${NumberFormat.decimalPattern('id').format(total)}',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF4F46E5)),
          ),
          if (payment['unique_code'] > 0)
            Text(
              '*Termasuk kode unik: ${payment['unique_code']}',
              style: const TextStyle(fontSize: 12, color: Color(0xFFF59E0B), fontWeight: FontWeight.bold),
            ),
          const SizedBox(height: 32),
          if (payment['method'] == 'transfer') ...[
            const Text('Transfer ke Rekening:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ownerBank['bank_name'] ?? 'Bank tidak tersedia', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                  const SizedBox(height: 4),
                  Text(
                    ownerBank['bank_number'] ?? '-',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                  const SizedBox(height: 4),
                  Text('a.n. ${ownerBank['bank_holder'] ?? '-'}', style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            if (status == 'pending') ...[
              const Text('Unggah Bukti Transfer', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0), style: BorderStyle.solid),
                  ),
                  child: _proofImage != null
                      ? ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(_proofImage!, fit: BoxFit.cover))
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_rounded, size: 48, color: Color(0xFF94A3B8)),
                            SizedBox(height: 8),
                            Text('Klik untuk pilih foto', style: TextStyle(color: Color(0xFF94A3B8))),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _proofImage == null ? null : _uploadProof,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Kirim Bukti Pembayaran', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ] else if (status == 'pending_verification') ...[
               Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(12)),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: Color(0xFFD97706)),
                    SizedBox(width: 12),
                    Expanded(child: Text('Bukti transfer sedang diverifikasi oleh penjual/owner.', style: TextStyle(color: Color(0xFF92400E)))),
                  ],
                ),
              )
            ]
          ] else ...[
            const Text('Metode Pembayaran:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: const Text('Bayar Tunai di Tempat (COD)', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
            const Text('Silakan hubungi penjual melalui chat untuk mengatur waktu dan lokasi pertemuan.', style: TextStyle(color: Color(0xFF64748B))),
          ]
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    String label;

    switch (status) {
      case 'pending':
        color = const Color(0xFF64748B);
        label = 'Menunggu Pembayaran';
        break;
      case 'pending_verification':
        color = const Color(0xFFF59E0B);
        label = 'Menunggu Verifikasi';
        break;
      case 'paid':
        color = const Color(0xFF10B981);
        label = 'Lunas';
        break;
      default:
        color = Colors.red;
        label = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(999), border: Border.all(color: color.withOpacity(0.5))),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
