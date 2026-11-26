import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../models/thrift.dart';

class ThriftCard extends StatelessWidget {
  final ThriftProduct product;

  const ThriftCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.06),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              _buildImage(),
              if (product.isSold)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: const Text(
                      'TERJUAL',
                      style: TextStyle(
                        color: Color(0xFFBE123C),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: product.isSold ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  'Rp ${_formatPrice(product.price)}',
                  style: TextStyle(
                    color: product.isSold ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    decoration: product.isSold ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.conditionStatus,
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
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
        color: const Color(0xFFF1F5F9),
        child: const Center(
          child: Icon(Icons.shopping_bag_rounded, color: Color(0xFFCBD5E1), size: 36),
        ),
      );
    }
    final img = product.images.first;
    final imageUrl = img.url ?? '${ApiConfig.storageUrl}/${img.imagePath}';
    return CachedNetworkImage(
      imageUrl: imageUrl,
      height: 140,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(height: 140, color: const Color(0xFFF1F5F9)),
      errorWidget: (_, __, ___) => Container(
        height: 140,
        color: const Color(0xFFF1F5F9),
        child: const Icon(Icons.broken_image, color: Color(0xFF94A3B8)),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.');
  }
}