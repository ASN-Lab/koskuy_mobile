import 'package:flutter/material.dart';
import '../models/kos.dart';
import '../services/api_service.dart';
import '../widgets/cards/kos_card.dart';
import 'kos_detail_screen.dart';

class KosListScreen extends StatefulWidget {
  const KosListScreen({super.key});

  @override
  State<KosListScreen> createState() => _KosListScreenState();
}

class _KosListScreenState extends State<KosListScreen> {
  final _searchController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  String? _genderType;
  Future<List<Kos>>? _future;

  void _applyFilter() {
    setState(() {
      _future = ApiService.getKosList(
        search: _searchController.text,
        genderType: _genderType,
        minPrice: _minPriceController.text,
        maxPrice: _maxPriceController.text,
      );
    });
  }

  void _resetFilter() {
    _searchController.clear();
    _minPriceController.clear();
    _maxPriceController.clear();
    setState(() => _genderType = null);
    _applyFilter();
  }

  @override
  void initState() {
    super.initState();
    _future = ApiService.getKosList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cari Kos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(labelText: 'Nama kos...', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _genderType,
                      decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Semua Gender')),
                        DropdownMenuItem(value: 'putra', child: Text('Putra')),
                        DropdownMenuItem(value: 'putri', child: Text('Putri')),
                        DropdownMenuItem(value: 'campur', child: Text('Campur')),
                      ],
                      onChanged: (v) => setState(() => _genderType = v),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _minPriceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Harga min', border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _maxPriceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Harga max', border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: ElevatedButton(onPressed: _applyFilter, child: const Text('Filter'))),
                        const SizedBox(width: 12),
                        OutlinedButton(onPressed: _resetFilter, child: const Text('Reset')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildList() {
    return FutureBuilder<List<Kos>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Tidak ada kos yang ditemukan'));
        }

        final list = snapshot.data!;
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.72,
          ),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final kos = list[index];
            return InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => KosDetailScreen(kosId: kos.id)),
              ),
              child: KosCard(kos: kos),
            );
          },
        );
      },
    );
  }
}
