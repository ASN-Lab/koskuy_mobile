import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/api_config.dart';
import '../models/kos.dart';
import '../services/api_service.dart';

class KosDetailScreen extends StatefulWidget {
  final int kosId;

  const KosDetailScreen({super.key, required this.kosId});

  @override
  State<KosDetailScreen> createState() => _KosDetailScreenState();
}

class _KosDetailScreenState extends State<KosDetailScreen> {
  late Future<Kos> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.getKosDetail(widget.kosId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Kos')),
      body: FutureBuilder<Kos>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 8),
                  Text('${snapshot.error}'),
                ],
              ),
            );
          }

          final kos = snapshot.data!;
          return _buildContent(kos);
        },
      ),
    );
  }

  Widget _buildContent(Kos kos) {
    return ListView(
      children: [
        _buildGallery(kos),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(kos.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Rp ${_formatPrice(kos.pricePerMonth)} / bulan',
                style: const TextStyle(fontSize: 20, color: Colors.indigo, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Chip(label: Text(kos.genderType)),
              const SizedBox(height: 16),
              const Text('Deskripsi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(kos.description, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              const Text('Alamat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(kos.address, style: const TextStyle(color: Colors.grey)),
              if (kos.facilities.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Fasilitas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: kos.facilities.map((f) => Chip(label: Text(f.facilityName))).toList(),
                ),
              ],
              if (kos.latitude != null && kos.longitude != null) ...[
                const SizedBox(height: 16),
                const Text('Lokasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.map),
                  label: const Text('Lihat di Google Maps'),
                  onPressed: () => _launchUrl(
                    'https://www.google.com/maps?q=${kos.latitude},${kos.longitude}',
                  ),
                ),
              ],
              const SizedBox(height: 24),
              if (kos.owner?.phone != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.all(16)),
                    icon: const Icon(Icons.chat),
                    label: const Text('Hubungi Pemilik via WhatsApp'),
                    onPressed: () => _launchWhatsApp(kos.owner!.phone!, kos.title),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGallery(Kos kos) {
    if (kos.images.isEmpty) {
      return Container(
        height: 240,
        color: Colors.grey.shade200,
        child: const Center(child: Text('Tidak ada foto', style: TextStyle(color: Colors.grey))),
      );
    }
    return SizedBox(
      height: 240,
      child: PageView.builder(
        itemCount: kos.images.length,
        itemBuilder: (context, index) {
          final img = kos.images[index];
          final imageUrl = img.url ?? '${ApiConfig.storageUrl}/${img.imagePath}';
          return CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: Colors.grey.shade200),
            errorWidget: (_, __, ___) => Container(color: Colors.grey.shade200, child: const Icon(Icons.broken_image)),
          );
        },
      ),
    );
  }

  Future<void> _launchWhatsApp(String phone, String title) async {
    final message = Uri.encodeComponent('Halo, saya tertarik dengan kos $title');
    await _launchUrl('https://wa.me/$phone?text=$message');
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tidak dapat membuka: $url')));
    }
  }

  String _formatPrice(int price) {
    return price.toString().replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.');
  }
}
