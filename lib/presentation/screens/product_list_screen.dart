import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Debouncer _debouncer = Debouncer(milliseconds: 500);
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(
      () => Provider.of<ProductProvider>(context, listen: false).fetchProducts(),
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      Provider.of<ProductProvider>(context, listen: false).loadMoreProducts();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Catalog'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          Provider.of<ProductProvider>(context, listen: false)
                              .fetchProducts();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (query) {
                _debouncer.run(() {
                  Provider.of<ProductProvider>(context, listen: false)
                      .searchProducts(query);
                });
              },
            ),
          ),
          // Product List View
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${provider.errorMessage}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.fetchProducts(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.products.isEmpty) {
                  return const Center(child: Text('No products found.'));
                }

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: provider.hasMore
                     ? provider.products.length + 1
                     : provider.products.length,
                  itemBuilder: (context, index) {
                      if (index == provider.products.length) {
                          return const Padding(
                             padding: EdgeInsets.symmetric(vertical: 16.0),
                             child: Center(
                               child: CircularProgressIndicator(),
                            ),
                          );
                       }

                      final product = provider.products[index];
                      return ListTile(
                        leading: Image.network(
                          product.thumbnail,
                          width: 50,
                           height: 50,
                           fit: BoxFit.cover,
                           errorBuilder: (_, __, ___) => const Icon(Icons.image),
                         ),
                         title: Text(product.title),
                         subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                         trailing: Row(
                           mainAxisSize: MainAxisSize.min,
                           children: [
                             const Icon(Icons.star, color: Colors.amber, size: 18),
                             const SizedBox(width: 4),
                             Text(product.rating.toString()),
                           ],
                         ),
                         onTap: () {
                           Navigator.push(
                               context,
                               MaterialPageRoute(
                               builder: (context) =>
                                  ProductDetailScreen(productId: product.id),
                               ),
                           );
                         },
                       );
                     },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({this.milliseconds = 500});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}