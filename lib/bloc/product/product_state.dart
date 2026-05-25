import '../../data/models/product_model.dart';

abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<ProductModel> products;
  final String searchQuery;
  final String selectedCategory;

  ProductLoaded({
    required this.products,
    this.searchQuery = '',
    this.selectedCategory = 'Semua',
  });
}

class ProductError extends ProductState {
  final String message;
  ProductError(this.message);
}
