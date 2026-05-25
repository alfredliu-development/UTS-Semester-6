import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/customer/customer_cubit.dart';
import '../../bloc/customer/customer_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/customer_model.dart';
import '../../widgets/empty_state.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CustomerCubit>().loadCustomers();
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
        title: const Text('Daftar Pelanggan', style: AppTextStyles.heading3),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildCustomerList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: TextField(
        controller: _searchController,
        onChanged: (value) =>
            context.read<CustomerCubit>().searchCustomers(value),
        decoration: InputDecoration(
          hintText: 'Cari nama, alamat, atau nomor HP...',
          hintStyle: const TextStyle(color: Colors.white60, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.white70),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, color: Colors.white70),
                  onPressed: () {
                    _searchController.clear();
                    context.read<CustomerCubit>().loadCustomers();
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
    );
  }

  Widget _buildCustomerList() {
    return BlocBuilder<CustomerCubit, CustomerState>(
      builder: (context, state) {
        if (state is CustomerLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is CustomerError) {
          return Center(child: Text(state.message));
        }

        if (state is CustomerLoaded) {
          if (state.customers.isEmpty) {
            return EmptyState(
              icon: Icons.people_outline_rounded,
              title: 'Pelanggan tidak ditemukan',
              subtitle: state.searchQuery.isNotEmpty
                  ? 'Coba kata kunci lain'
                  : 'Belum ada data pelanggan',
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<CustomerCubit>().loadCustomers(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.customers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return _CustomerCard(customer: state.customers[index]);
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final CustomerModel customer;

  const _CustomerCard({required this.customer});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/customer-detail',
        arguments: customer.id,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
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
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.store_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(customer.name, style: AppTextStyles.heading3),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          customer.address,
                          style: AppTextStyles.body2,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 13,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 3),
                      Text(customer.phone, style: AppTextStyles.body2),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _VisitBadge(isVisited: customer.isVisited),
          ],
        ),
      ),
    );
  }
}

class _VisitBadge extends StatelessWidget {
  final bool isVisited;

  const _VisitBadge({required this.isVisited});

  @override
  Widget build(BuildContext context) {
    final color = isVisited ? AppColors.success : AppColors.textSecondary;
    final label = isVisited ? 'Dikunjungi' : 'Belum';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            isVisited
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 16,
            color: color,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
