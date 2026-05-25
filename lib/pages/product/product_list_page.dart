import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/cart/cart_cubit.dart';
import '../../bloc/cart/cart_state.dart';
import '../../bloc/product/product_cubit.dart';
import '../../bloc/product/product_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/customer_model.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';
import '../../widgets/empty_state.dart';

class ProductListPage extends StatefulWidget {
  final CustomerModel? selectedCustomer;

  const ProductListPage({super.key, this.selectedCustomer});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final _searchController = TextEditingController();
  List<String> _categories = ['Semua'];

  @override
  void initState() {
    super.initState();
    context.read<ProductCubit>().loadProducts();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await ProductRepository().getCategories();
    if (mounted) {
      setState(() => _categories = ['Semua', ...cats]);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Daftar Produk', style: AppTextStyles.heading3),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [_buildCartButton()],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(child: _buildProductList()),
        ],
      ),
    );
  }

  Widget _buildCartButton() {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_rounded),
              onPressed: () => Navigator.pushNamed(
                context,
                '/cart',
                arguments: widget.selectedCustomer,
              ),
            ),
            if (state.totalItems > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${state.totalItems}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) =>
                context.read<ProductCubit>().searchProducts(value),
            decoration: InputDecoration(
              hintText: 'Cari produk...',
              hintStyle: const TextStyle(color: Colors.white60, fontSize: 14),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Colors.white70,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear_rounded,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        context.read<ProductCubit>().loadProducts();
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white.withOpacity(0.15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 10),
          BlocBuilder<ProductCubit, ProductState>(
            builder: (context, state) {
              final selected = state is ProductLoaded
                  ? state.selectedCategory
                  : 'Semua';

              return SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = cat == selected;

                    return GestureDetector(
                      onTap: () =>
                          context.read<ProductCubit>().filterByCategory(cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.primary
                                : Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProductError) {
          return Center(child: Text(state.message));
        }

        if (state is ProductLoaded) {
          if (state.products.isEmpty) {
            return const EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'Produk tidak ditemukan',
              subtitle: 'Coba kata kunci atau kategori lain',
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<ProductCubit>().loadProducts(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.products.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return _ProductCard(
                  product: state.products[index],
                  selectedCustomer: widget.selectedCustomer,
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final CustomerModel? selectedCustomer;

  const _ProductCard({required this.product, this.selectedCustomer});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cartState) {
        final qty = context.read<CartCubit>().getProductQuantity(product.id!);
        final inCart = qty > 0;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: inCart
                ? Border.all(color: AppColors.primary.withOpacity(0.4))
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.inventory_2_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: AppTextStyles.heading3),
                    const SizedBox(height: 3),
                    Text(
                      product.category,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          CurrencyFormatter.format(product.price),
                          style: AppTextStyles.price,
                        ),
                        const SizedBox(width: 8),
                        Text('/ ${product.unit}', style: AppTextStyles.caption),
                        const Spacer(),
                        _StockBadge(stock: product.stock),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              inCart
                  ? _QuantityControl(product: product, quantity: qty)
                  : _AddButton(product: product),
            ],
          ),
        );
      },
    );
  }
}

class _StockBadge extends StatelessWidget {
  final int stock;

  const _StockBadge({required this.stock});

  @override
  Widget build(BuildContext context) {
    final isLow = stock < 20;
    final color = isLow ? AppColors.warning : AppColors.success;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Stok: $stock',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final ProductModel product;

  const _AddButton({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<CartCubit>().addProduct(product),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  final ProductModel product;
  final int quantity;

  const _QuantityControl({required this.product, required this.quantity});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => context.read<CartCubit>().decreaseQuantity(product.id!),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.remove_rounded,
              color: AppColors.error,
              size: 18,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('$quantity', style: AppTextStyles.heading3),
        ),
        GestureDetector(
          onTap: () => context.read<CartCubit>().increaseQuantity(product.id!),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.add_rounded,
              color: AppColors.primary,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }
}
