import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../models/kos.dart';

class KosCard extends StatelessWidget {
  final Kos kos;

  const KosCard({super.key, required this.kos});

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
          _buildImage(),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kos.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  'Rp ${_formatPrice(kos.pricePerMonth)}',
                  style: const TextStyle(
                    color: Color(0xFF4F46E5),
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const Text(
                  '/bulan',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    kos.genderType.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF4F46E5),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
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
        height: 150,
        color: const Color(0xFFF1F5F9),
        child: const Center(
          child: Icon(Icons.home_rounded, color: Color(0xFFCBD5E1), size: 36),
        ),
      );
    }
    final img = kos.images.first;
    final imageUrl = img.url ?? '${ApiConfig.storageUrl}/${img.imagePath}';
    return CachedNetworkImage(
      imageUrl: imageUrl,
      height: 150,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(height: 150, color: const Color(0xFFF1F5F9)),
      errorWidget: (_, __, ___) => Container(
        height: 150,
        color: const Color(0xFFF1F5F9),
        child: const Icon(Icons.broken_image, color: Color(0xFF94A3B8)),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.');
  }
}