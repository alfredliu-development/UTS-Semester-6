import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth_cubit.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/dashboard/dashboard_cubit.dart';
import '../../bloc/dashboard/dashboard_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/sales_model.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().loadSummary();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final sales = authState is AuthSuccess ? authState.sales : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () => context.read<DashboardCubit>().loadSummary(),
        child: CustomScrollView(
          slivers: [
            _buildAppBar(sales),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildDateInfo(),
                  const SizedBox(height: 20),
                  _buildSummaryCards(),
                  const SizedBox(height: 28),
                  const Text('Menu Utama', style: AppTextStyles.heading3),
                  const SizedBox(height: 16),
                  _buildShortcuts(),
                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(SalesModel? sales) {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryDark, AppColors.primaryLight],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Selamat datang,',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    Text(
                      sales?.fullName ?? 'Sales',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Sales',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                onPressed: _confirmLogout,
                tooltip: 'Logout',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateInfo() {
    return Row(
      children: [
        const Icon(
          Icons.calendar_today_rounded,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 6),
        Text(
          DateFormatter.formatFullDate(DateTime.now()),
          style: AppTextStyles.body2,
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is DashboardLoaded) {
          return Column(
            children: [
              _SummaryCard(
                icon: Icons.receipt_long_rounded,
                label: 'Total Order Hari Ini',
                value: '${state.totalOrdersToday} Order',
                color: AppColors.primary,
              ),
              const SizedBox(height: 12),
              _SummaryCard(
                icon: Icons.store_rounded,
                label: 'Pelanggan Dikunjungi',
                value: '${state.totalCustomersVisited} Toko',
                color: AppColors.success,
              ),
              const SizedBox(height: 12),
              _SummaryCard(
                icon: Icons.payments_rounded,
                label: 'Total Nominal Penjualan',
                value: CurrencyFormatter.formatShort(state.totalSalesAmount),
                color: AppColors.warning,
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildShortcuts() {
    final shortcuts = [
      _ShortcutItem(
        icon: Icons.inventory_2_rounded,
        label: 'Produk',
        color: AppColors.primary,
        route: '/products',
      ),
      _ShortcutItem(
        icon: Icons.people_rounded,
        label: 'Pelanggan',
        color: AppColors.success,
        route: '/customers',
      ),
      _ShortcutItem(
        icon: Icons.receipt_long_rounded,
        label: 'Order',
        color: AppColors.warning,
        route: '/orders',
      ),
    ];

    return Row(
      children: shortcuts
          .map(
            (s) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildShortcutCard(s),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildShortcutCard(_ShortcutItem item) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, item.route),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: item.color, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              item.label,
              style: AppTextStyles.body2.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthCubit>().logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.body2),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.heading3.copyWith(color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortcutItem {
  final IconData icon;
  final String label;
  final Color color;
  final String route;

  _ShortcutItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });
}
