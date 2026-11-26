import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/api_config.dart';
import '../models/kos.dart';
import '../screens/booking_screen.dart';
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
                const SizedBox(height: 20),
                const Text('Lokasi & Akses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.location_on_rounded, color: Color(0xFF4F46E5)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              kos.address,
                              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${kos.latitude}, ${kos.longitude}',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFF4F46E5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.map_rounded, color: Color(0xFF4F46E5)),
                    label: const Text('Buka di Google Maps', style: TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold)),
                    onPressed: () => _launchUrl(
                      'https://www.google.com/maps/search/?api=1&query=${kos.latitude},${kos.longitude}',
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Booking Sekarang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    // Quick booking logic
                    await ApiService.bookKos(kos.id, DateTime.now().toString().split(' ')[0], '');
                    if (context.mounted) {
                      Navigator.pushNamed(context, '/payment', arguments: {
                        'type': 'booking',
                        'id': kos.id, // NOTE: Needs actual booking ID from API response
                        'title': kos.title,
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              if (kos.owner != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.chat_bubble_rounded, color: Colors.white),
                    label: const Text('Chat Pemilik', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    onPressed: () => Navigator.pushNamed(context, '/chat', arguments: {
                      'recipientId': kos.owner!.id,
                      'recipientName': kos.owner!.name,
                    }),
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
