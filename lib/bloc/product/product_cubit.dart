import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/product_repository.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductRepository _repository;

  ProductCubit({ProductRepository? repository})
    : _repository = repository ?? ProductRepository(),
      super(ProductInitial());

  Future<void> loadProducts() async {
    emit(ProductLoading());

    try {
      final products = await _repository.getAll();
      emit(ProductLoaded(products: products));
    } catch (e) {
      emit(ProductError('Gagal memuat data produk'));
    }
  }

  Future<void> searchProducts(String query) async {
    try {
      final currentState = state;
      final currentCategory = currentState is ProductLoaded
          ? currentState.selectedCategory
          : 'Semua';

      final products = query.trim().isEmpty
          ? await _repository.getAll()
          : await _repository.search(query.trim());

      emit(
        ProductLoaded(
          products: products,
          searchQuery: query,
          selectedCategory: currentCategory,
        ),
      );
    } catch (e) {
      emit(ProductError('Gagal mencari produk'));
    }
  }

  Future<void> filterByCategory(String category) async {
    try {
      final currentState = state;
      final currentQuery = currentState is ProductLoaded
          ? currentState.searchQuery
          : '';

      final products = category == 'Semua'
          ? await _repository.getAll()
          : await _repository.getByCategory(category);

      emit(
        ProductLoaded(
          products: products,
          searchQuery: currentQuery,
          selectedCategory: category,
        ),
      );
    } catch (e) {
      emit(ProductError('Gagal memfilter produk'));
    }
  }
}
