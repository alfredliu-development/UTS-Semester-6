import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/cart/cart_cubit.dart';
import '../bloc/customer/customer_cubit.dart';
import '../bloc/order/order_cubit.dart';
import '../bloc/product/product_cubit.dart';
import '../data/models/customer_model.dart';
import '../pages/cart/cart_page.dart';
import '../pages/checkout/checkout_page.dart';
import '../pages/customer/customer_detail_page.dart';
import '../pages/customer/customer_list_page.dart';
import '../pages/order/order_history_page.dart';
import '../pages/product/product_list_page.dart';
import '../pages/auth/register_page.dart';

/// Shared CartCubit instance for the current order session.
/// Reset setiap kali user mulai memilih produk baru.
CartCubit? _sessionCartCubit;

CartCubit get sessionCart {
  _sessionCartCubit ??= CartCubit();
  return _sessionCartCubit!;
}

void resetSessionCart() {
  _sessionCartCubit = CartCubit();
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ── Auth ──────────────────────────────────────────────────────────────
      // Login tidak perlu route — _AuthGate sudah menampilkan LoginPage
      // saat AuthState bukan AuthSuccess.
      // Tapi tetap disediakan untuk pushNamed('/login') dari register page.
      case '/register':
        return _fadeRoute(const RegisterPage(), settings);

      // ── Customer ──────────────────────────────────────────────────────────
      case '/customers':
        return _fadeRoute(
          MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => CustomerCubit()),
              BlocProvider(create: (_) => OrderCubit()),
            ],
            child: const CustomerListPage(),
          ),
          settings,
        );

      case '/customer-detail':
        final customerId = settings.arguments as int;
        return _fadeRoute(
          MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => CustomerCubit()),
              BlocProvider(create: (_) => OrderCubit()),
            ],
            child: CustomerDetailPage(customerId: customerId),
          ),
          settings,
        );

      // ── Product & Cart ────────────────────────────────────────────────────
      case '/products':
        final customer = settings.arguments as CustomerModel?;
        resetSessionCart();
        return _fadeRoute(
          MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => ProductCubit()),
              BlocProvider.value(value: sessionCart),
            ],
            child: ProductListPage(selectedCustomer: customer),
          ),
          settings,
        );

      case '/cart':
        final customer = settings.arguments as CustomerModel?;
        return _fadeRoute(
          BlocProvider.value(
            value: sessionCart,
            child: CartPage(selectedCustomer: customer),
          ),
          settings,
        );

      case '/checkout':
        final customer = settings.arguments as CustomerModel?;
        return _fadeRoute(
          MultiBlocProvider(
            providers: [
              BlocProvider.value(value: sessionCart),
              BlocProvider(create: (_) => OrderCubit()),
            ],
            child: CheckoutPage(selectedCustomer: customer),
          ),
          settings,
        );

      // ── Orders ────────────────────────────────────────────────────────────
      case '/orders':
        return _fadeRoute(
          BlocProvider(
            create: (_) => OrderCubit(),
            child: const OrderHistoryPage(),
          ),
          settings,
        );

      // ── Default fallback ──────────────────────────────────────────────────
      // Tidak perlu redirect ke login — _AuthGate yang menentukan.
      default:
        return _fadeRoute(const SizedBox.shrink(), settings);
    }
  }

  static PageRouteBuilder _fadeRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
      transitionDuration: const Duration(milliseconds: 250),
    );
  }
}
