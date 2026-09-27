import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../models/kos.dart';

class KosCard extends StatelessWidget {
  final Kos kos;

  const KosCard({super.key, required this.kos});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImage(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kos.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp ${_formatPrice(kos.pricePerMonth)} / bulan',
                  style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    kos.genderType,
                    style: TextStyle(color: Colors.indigo.shade700, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (kos.images.isEmpty) {
      return Container(
        height: 160,
        color: Colors.grey.shade200,
        child: const Center(child: Text('Tidak ada foto', style: TextStyle(color: Colors.grey))),
      );
    }
    final img = kos.images.first;
    final imageUrl = img.url ?? '${ApiConfig.storageUrl}/${img.imagePath}';
    return CachedNetworkImage(
      imageUrl: imageUrl,
      height: 160,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(height: 160, color: Colors.grey.shade200),
      errorWidget: (_, __, ___) => Container(height: 160, color: Colors.grey.shade200, child: const Icon(Icons.broken_image)),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.');
  }
}
