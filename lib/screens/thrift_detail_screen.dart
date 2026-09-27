import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/api_config.dart';
import '../models/thrift.dart';
import '../services/api_service.dart';

class ThriftDetailScreen extends StatefulWidget {
  final int productId;

  const ThriftDetailScreen({super.key, required this.productId});

  @override
  State<ThriftDetailScreen> createState() => _ThriftDetailScreenState();
}

class _ThriftDetailScreenState extends State<ThriftDetailScreen> {
  late Future<ThriftProduct> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.getThriftDetail(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Produk')),
      body: FutureBuilder<ThriftProduct>(
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

          final product = snapshot.data!;
          return _buildContent(product);
        },
      ),
    );
  }

  Widget _buildContent(ThriftProduct product) {
    return ListView(
      children: [
        _buildGallery(product),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Rp ${_formatPrice(product.price)}',
                style: const TextStyle(fontSize: 20, color: Colors.indigo, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Kondisi: ${product.conditionStatus}', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              const Text('Deskripsi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(product.description, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              const Text('Info Penjual', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(product.seller?.name ?? '-', style: const TextStyle(color: Colors.grey)),
              if (product.category != null) ...[
                const SizedBox(height: 16),
                const Text('Kategori', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Chip(label: Text(product.category!.name)),
              ],
              const SizedBox(height: 24),
              if (product.seller?.phone != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.all(16)),
                    icon: const Icon(Icons.chat),
                    label: const Text('Chat Penjual via WhatsApp'),
                    onPressed: () => _launchWhatsApp(product.seller!.phone!, product.title),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGallery(ThriftProduct product) {
    if (product.images.isEmpty) {
      return Container(
        height: 240,
        color: Colors.grey.shade200,
        child: const Center(child: Text('Tidak ada foto', style: TextStyle(color: Colors.grey))),
      );
    }
    return SizedBox(
      height: 240,
      child: PageView.builder(
        itemCount: product.images.length,
        itemBuilder: (context, index) {
          final img = product.images[index];
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
    final message = Uri.encodeComponent('Halo, saya tertarik dengan barang $title');
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
