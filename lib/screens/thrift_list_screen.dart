import 'package:flutter/material.dart';
import '../models/thrift.dart';
import '../services/api_service.dart';
import '../widgets/cards/thrift_card.dart';
import 'thrift_detail_screen.dart';

class ThriftListScreen extends StatefulWidget {
  const ThriftListScreen({super.key});

  @override
  State<ThriftListScreen> createState() => _ThriftListScreenState();
}

class _ThriftListScreenState extends State<ThriftListScreen> {
  final _searchController = TextEditingController();
  String? _categoryId;
  List<Category> _categories = [];
  Future<List<ThriftProduct>>? _future;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _future = ApiService.getThriftList();
  }

  void _loadCategories() async {
    try {
      final cats = await ApiService.getCategories();
      setState(() => _categories = cats);
    } catch (_) {}
  }

  void _applyFilter() {
    setState(() {
      _future = ApiService.getThriftList(search: _searchController.text, categoryId: _categoryId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Katalog Thrift')),
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
                      decoration: const InputDecoration(labelText: 'Cari barang...', border: OutlineInputBorder()),
                      onSubmitted: (_) => _applyFilter(),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _categoryId,
                      decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder()),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Semua Kategori')),
                        ..._categories.map((c) => DropdownMenuItem(value: c.id.toString(), child: Text(c.name))),
                      ],
                      onChanged: (v) {
                        setState(() => _categoryId = v);
                        _applyFilter();
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(onPressed: _applyFilter, child: const Text('Filter')),
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
    return FutureBuilder<List<ThriftProduct>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Tidak ada produk yang ditemukan'));
        }

        final list = snapshot.data!;
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.68,
          ),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final product = list[index];
            return InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ThriftDetailScreen(productId: product.id)),
              ),
              child: ThriftCard(product: product),
            );
          },
        );
      },
    );
  }
}
