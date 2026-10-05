import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/kos_card.dart';
import '../widgets/thrift_card.dart';
import '../screens/kos_detail_screen.dart';
import '../screens/kos_list_screen.dart';
import '../screens/thrift_detail_screen.dart';
import '../screens/thrift_list_screen.dart';
import '../models/kos.dart';
import '../models/thrift.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Kos>> _kosFuture;
  late Future<List<ThriftProduct>> _thriftFuture;

  @override
  void initState() {
    super.initState();
    _kosFuture = ApiService.getKosList();
    _thriftFuture = ApiService.getThriftList();
  }

  void _refresh() {
    setState(() {
      _kosFuture = ApiService.getKosList();
      _thriftFuture = ApiService.getThriftList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KosKuy')),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Colors.indigo, Colors.purple]),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat Datang di KosKuy',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Temukan kos impian dan barang bekas berkualitas untuk mahasiswa.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            _buildSection(
              title: 'Kos Terbaru',
              future: _kosFuture,
              cardBuilder: (kos) => KosCard(kos: kos),
              onTap: (kos) => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => KosDetailScreen(kosId: kos.id)),
              ),
              onSeeAll: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const KosListScreen()),
              ),
            ),
            _buildSection(
              title: 'Produk Thrift Terbaru',
              future: _thriftFuture,
              cardBuilder: (product) => ThriftCard(product: product),
              onTap: (product) => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ThriftDetailScreen(productId: product.id)),
              ),
              onSeeAll: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ThriftListScreen()),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection<T>({
    required String title,
    required Future<List<T>> future,
    required Widget Function(T) cardBuilder,
    required void Function(T) onTap,
    required VoidCallback onSeeAll,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextButton(onPressed: onSeeAll, child: const Text('Lihat Semua')),
            ],
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<T>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
              } else if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 40),
                        const SizedBox(height: 8),
                        Text('${snapshot.error}'),
                        const SizedBox(height: 8),
                        ElevatedButton(onPressed: _refresh, child: const Text('Coba Lagi')),
                      ],
                    ),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('Belum ada data')),
                );
              }

              final items = snapshot.data!.take(6).toList();
              return SizedBox(
                height: 260,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return SizedBox(width: 200, child: InkWell(onTap: () => onTap(item), child: cardBuilder(item)));
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
