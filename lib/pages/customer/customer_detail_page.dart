import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/customer/customer_cubit.dart';
import '../../bloc/customer/customer_state.dart';
import '../../bloc/order/order_cubit.dart';
import '../../bloc/order/order_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/customer_model.dart';
import '../../data/models/order_model.dart';
import '../../widgets/app_button.dart';
import '../../widgets/status_badge.dart';

class CustomerDetailPage extends StatefulWidget {
  final int customerId;

  const CustomerDetailPage({super.key, required this.customerId});

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<CustomerCubit>().loadCustomerDetail(widget.customerId);
    context.read<OrderCubit>().loadOrdersByCustomer(widget.customerId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Pelanggan', style: AppTextStyles.heading3),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<CustomerCubit, CustomerState>(
        builder: (context, state) {
          if (state is CustomerLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CustomerError) {
            return Center(child: Text(state.message));
          }

          if (state is CustomerDetailLoaded) {
            return _buildContent(state.customer);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(CustomerModel customer) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCustomerCard(customer),
          const SizedBox(height: 20),
          _buildOrderHistory(),
          const SizedBox(height: 24),
          AppButton(
            label: 'Buat Order',
            icon: Icons.add_shopping_cart_rounded,
            width: double.infinity,
            onPressed: () =>
                Navigator.pushNamed(context, '/products', arguments: customer),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(CustomerModel customer) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.store_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customer.name, style: AppTextStyles.heading2),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: customer.isVisited
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.textSecondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        customer.isVisited
                            ? 'Sudah Dikunjungi'
                            : 'Belum Dikunjungi',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: customer.isVisited
                              ? AppColors.success
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.location_on_rounded,
            label: 'Alamat',
            value: customer.address,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.phone_rounded,
            label: 'Nomor HP',
            value: customer.phone,
          ),
          if (customer.notes != null && customer.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.notes_rounded,
              label: 'Catatan',
              value: customer.notes!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Riwayat Order', style: AppTextStyles.heading3),
        const SizedBox(height: 12),
        BlocBuilder<OrderCubit, OrderState>(
          builder: (context, state) {
            if (state is OrderLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is OrderListLoaded) {
              if (state.orders.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'Belum ada riwayat order',
                      style: AppTextStyles.body2,
                    ),
                  ),
                );
              }

              return Column(
                children: state.orders
                    .take(5)
                    .map((order) => _OrderHistoryItem(order: order))
                    .toList(),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption),
              const SizedBox(height: 2),
              Text(value, style: AppTextStyles.body1),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrderHistoryItem extends StatelessWidget {
  final OrderModel order;

  const _OrderHistoryItem({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${order.id}',
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  DateFormatter.formatDate(order.createdAt),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(order.totalAmount),
                style: AppTextStyles.price,
              ),
              const SizedBox(height: 4),
              StatusBadge(status: order.status),
            ],
          ),
        ],
      ),
    );
  }
}
