import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/cards/kos_card.dart';
import '../widgets/cards/thrift_card.dart';
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
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.home_rounded, color: Colors.indigo, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text('KosKuy', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A), fontSize: 20)),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: Color(0xFF0F172A)),
                  onPressed: () => Navigator.pushNamed(context, '/notifications'),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.indigo.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.verified_rounded, color: Colors.white, size: 16),
                              SizedBox(width: 6),
                              Text('Platform No.1 Mahasiswa', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Kos impian,\nthrift pilihan.',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Cari kos dan barang bekas berkualitas tanpa perantara.',
                            style: TextStyle(color: Colors.white.withOpacity(0.87), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildSection(
                title: 'Kos Terbaru',
                subtitle: 'Pilihan kamar nyaman siap huni',
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
            ),
            SliverToBoxAdapter(
              child: _buildSection(
                title: 'Produk Thrift Pilihan',
                subtitle: 'Barang bekas berkualitas dari sesama mahasiswa',
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
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildSection<T>({
    required String title,
    required String subtitle,
    required Future<List<T>> future,
    required Widget Function(T) cardBuilder,
    required void Function(T) onTap,
    required VoidCallback onSeeAll,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: onSeeAll,
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: const Text('Lihat semua'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<T>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: Color(0xFF4F46E5))));
              } else if (snapshot.hasError) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.signal_wifi_off_rounded, color: Color(0xFF94A3B8), size: 40),
                      const SizedBox(height: 8),
                      const Text('Gagal memuat data', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      const Text('Periksa koneksi internetmu lalu coba lagi.', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _refresh,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: const Center(
                    child: Column(children: [
                      Icon(Icons.inbox_rounded, color: Color(0xFFCBD5E1), size: 40),
                      SizedBox(height: 8),
                      Text('Belum ada data', style: TextStyle(color: Color(0xFF94A3B8))),
                    ]),
                  ),
                );
              }

              final items = snapshot.data!.take(6).toList();
              return SizedBox(
                height: 280,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return SizedBox(width: 220, child: InkWell(onTap: () => onTap(item), child: cardBuilder(item)));
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
