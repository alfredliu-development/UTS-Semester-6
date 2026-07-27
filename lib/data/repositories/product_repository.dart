import '../api/api_service.dart';
import '../models/product_model.dart';

class ProductRepository {
  final ApiService _api = ApiService.instance;

  Future<List<ProductModel>> getAll() async {
    try {
      final response = await _api.get('/products');
      final List data = response.data as List;
      return data
          .map((e) => ProductModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      return [];
    }
  }

  Future<List<ProductModel>> search(String query) async {
    try {
      final response = await _api.get(
        '/products/search',
        queryParameters: {'q': query},
      );
      final List data = response.data as List;
      return data
          .map((e) => ProductModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      return [];
    }
  }

  Future<List<ProductModel>> getByCategory(String category) async {
    try {
      final response = await _api.get(
        '/products',
        queryParameters: {'category': category},
      );
      final List data = response.data as List;
      return data
          .map((e) => ProductModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      return [];
    }
  }

  Future<ProductModel?> getById(int id) async {
    try {
      final response = await _api.get('/products/$id');
      if (response.data == null) return null;
      return ProductModel.fromMap(response.data as Map<String, dynamic>);
    } on ApiException {
      return null;
    }
  }

  Future<List<String>> getCategories() async {
    try {
      final response = await _api.get('/products/categories');
      final List data = response.data as List;
      return data.map((e) => e.toString()).toList();
    } on ApiException {
      return [];
    }
  }
}
