import 'package:flutter/material.dart';
import 'package:product_catalog/data/models/product.dart';
import 'package:product_catalog/data/repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository _repository = ProductRepository();

  int _skip = 0;
  final int _limit = 10;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  List<Product> _products = [];
  Product? _selectedProduct;
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get products => _products;
  Product? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProducts({bool isRefresh = false}) async {
  if (isRefresh) {
    _skip = 0;
    _hasMore = true;
    _products = [];
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
  }

  try {
    final newProducts = await _repository.fetchProducts(
      limit: _limit,
      skip: _skip,
    );

    if (newProducts.length < _limit) {
      _hasMore = false;
    }

    _products.addAll(newProducts);
    _skip += _limit;
  } catch (e) {
    _errorMessage = e.toString();
  } finally {
    _isLoading = false;
    _isLoadingMore = false;
    notifyListeners();
  }
}

Future<void> loadMoreProducts() async {
    if (_isLoadingMore || !_hasMore || _isLoading) return;

    _isLoadingMore = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));
  }

  Future<void> fetchProductById(int id) async {
    _isLoading = true;
    _errorMessage = null;
    _selectedProduct = null;
    notifyListeners();

    try {
      _selectedProduct = await _repository.fetchProductById(id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchProducts(String query) async {
    if (query.trim().isEmpty) {
      fetchProducts();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _repository.searchProducts(query);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}