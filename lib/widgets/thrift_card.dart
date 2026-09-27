import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../models/thrift.dart';

class ThriftCard extends StatelessWidget {
  final ThriftProduct product;

  const ThriftCard({super.key, required this.product});

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
                  product.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp ${_formatPrice(product.price)}',
                  style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  product.conditionStatus,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (product.images.isEmpty) {
      return Container(
        height: 140,
        color: Colors.grey.shade200,
        child: const Center(child: Text('Tidak ada foto', style: TextStyle(color: Colors.grey))),
      );
    }
    final img = product.images.first;
    final imageUrl = img.url ?? '${ApiConfig.storageUrl}/${img.imagePath}';
    return CachedNetworkImage(
      imageUrl: imageUrl,
      height: 140,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(height: 140, color: Colors.grey.shade200),
      errorWidget: (_, __, ___) => Container(height: 140, color: Colors.grey.shade200, child: const Icon(Icons.broken_image)),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.');
  }
}
