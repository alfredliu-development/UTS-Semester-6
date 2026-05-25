import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/cart/cart_cubit.dart';
import '../../bloc/cart/cart_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/customer_model.dart';
import '../../widgets/app_button.dart';
import '../../widgets/empty_state.dart';

class CartPage extends StatelessWidget {
  final CustomerModel? selectedCustomer;

  const CartPage({super.key, this.selectedCustomer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Keranjang Order', style: AppTextStyles.heading3),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              if (state.isEmpty) return const SizedBox.shrink();
              return TextButton.icon(
                onPressed: () => _confirmClearCart(context),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.white70,
                  size: 18,
                ),
                label: const Text(
                  'Kosongkan',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state.isEmpty) {
            return EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Keranjang kosong',
              subtitle: 'Tambahkan produk terlebih dahulu',
              action: AppButton(
                label: 'Pilih Produk',
                icon: Icons.add_rounded,
                onPressed: () => Navigator.pop(context),
              ),
            );
          }

          return Column(
            children: [
              Expanded(child: _buildCartList(context, state)),
              _buildSummaryBar(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartList(BuildContext context, CartState state) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return _CartItemCard(item: state.items[index]);
      },
    );
  }

  Widget _buildSummaryBar(BuildContext context, CartState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Order', style: AppTextStyles.heading3),
              Text(
                CurrencyFormatter.format(state.totalAmount),
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AppButton(
            label: 'Checkout',
            icon: Icons.arrow_forward_rounded,
            width: double.infinity,
            onPressed: () => Navigator.pushNamed(
              context,
              '/checkout',
              arguments: selectedCustomer,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearCart(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Kosongkan Keranjang'),
        content: const Text('Semua produk akan dihapus dari keranjang.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<CartCubit>().clearCart();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Kosongkan'),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItemModel item;

  const _CartItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name, style: AppTextStyles.heading3),
                const SizedBox(height: 3),
                Text(
                  CurrencyFormatter.format(item.product.price),
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _QuantityRow(item: item),
              const SizedBox(height: 4),
              Text(
                CurrencyFormatter.format(item.subtotal),
                style: AppTextStyles.price,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityRow extends StatelessWidget {
  final CartItemModel item;

  const _QuantityRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () =>
              context.read<CartCubit>().decreaseQuantity(item.product.id!),
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Icon(
              Icons.remove_rounded,
              color: AppColors.error,
              size: 16,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('${item.quantity}', style: AppTextStyles.heading3),
        ),
        GestureDetector(
          onTap: () =>
              context.read<CartCubit>().increaseQuantity(item.product.id!),
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Icon(
              Icons.add_rounded,
              color: AppColors.primary,
              size: 16,
            ),
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () =>
              context.read<CartCubit>().removeProduct(item.product.id!),
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }
}
