import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/cart/cart_cubit.dart';
import '../../bloc/cart/cart_state.dart';
import '../../bloc/order/order_cubit.dart';
import '../../bloc/order/order_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/customer_model.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class CheckoutPage extends StatefulWidget {
  final CustomerModel? selectedCustomer;

  const CheckoutPage({super.key, this.selectedCustomer});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _notesController = TextEditingController();
  CustomerModel? _customer;

  @override
  void initState() {
    super.initState();
    _customer = widget.selectedCustomer;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout Order', style: AppTextStyles.heading3),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocListener<OrderCubit, OrderState>(
        listener: _handleOrderState,
        child: BlocBuilder<CartCubit, CartState>(
          builder: (context, cartState) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildCustomerSection(),
                        const SizedBox(height: 16),
                        _buildProductSection(cartState),
                        const SizedBox(height: 16),
                        _buildNotesSection(),
                        const SizedBox(height: 16),
                        _buildTotalSection(cartState),
                      ],
                    ),
                  ),
                ),
                _buildBottomBar(cartState),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCustomerSection() {
    return _SectionCard(
      title: 'Data Pelanggan',
      icon: Icons.store_rounded,
      child: _customer != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_customer!.name, style: AppTextStyles.heading3),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _customer!.address,
                        style: AppTextStyles.body2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.phone_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(_customer!.phone, style: AppTextStyles.body2),
                  ],
                ),
              ],
            )
          : GestureDetector(
              onTap: () async {
                final result = await Navigator.pushNamed(context, '/customers');
                if (result is CustomerModel) {
                  setState(() => _customer = result);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    style: BorderStyle.solid,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'Pilih Pelanggan',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProductSection(CartState cartState) {
    return _SectionCard(
      title: 'Daftar Produk',
      icon: Icons.inventory_2_rounded,
      child: Column(
        children: cartState.items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name,
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${item.quantity} ${item.product.unit} × ${CurrencyFormatter.format(item.product.price)}',
                        style: AppTextStyles.body2,
                      ),
                    ],
                  ),
                ),
                Text(
                  CurrencyFormatter.format(item.subtotal),
                  style: AppTextStyles.price,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNotesSection() {
    return _SectionCard(
      title: 'Catatan Order',
      icon: Icons.notes_rounded,
      child: AppTextField(
        controller: _notesController,
        label: 'Catatan (opsional)',
        hint: 'Tambahkan catatan untuk order ini...',
        maxLines: 3,
      ),
    );
  }

  Widget _buildTotalSection(CartState cartState) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Pembayaran',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              SizedBox(height: 2),
              Text(
                'Sudah termasuk semua item',
                style: TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
          Text(
            CurrencyFormatter.format(cartState.totalAmount),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(CartState cartState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BlocBuilder<OrderCubit, OrderState>(
        builder: (context, orderState) {
          return AppButton(
            label: 'Simpan Order',
            icon: Icons.save_rounded,
            width: double.infinity,
            isLoading: orderState is OrderLoading,
            onPressed: () => _handleSaveOrder(cartState),
          );
        },
      ),
    );
  }

  void _handleSaveOrder(CartState cartState) {
    if (_customer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih pelanggan terlebih dahulu'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (cartState.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keranjang masih kosong'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    context.read<OrderCubit>().saveOrder(
      customer: _customer!,
      cartItems: cartState.items,
      totalAmount: cartState.totalAmount,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
  }

  void _handleOrderState(BuildContext context, OrderState state) {
    if (state is OrderSaveSuccess) {
      context.read<CartCubit>().clearCart();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Order berhasil disimpan'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      Navigator.pushNamedAndRemoveUntil(context, '/orders', (route) => false);
    } else if (state is OrderError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.heading3),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
