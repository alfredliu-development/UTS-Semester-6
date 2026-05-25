import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/cart/cart_cubit.dart';
import '../bloc/customer/customer_cubit.dart';
import '../bloc/dashboard/dashboard_cubit.dart';
import '../bloc/order/order_cubit.dart';
import '../bloc/product/product_cubit.dart';
import '../data/models/customer_model.dart';
import '../pages/auth/login_page.dart';
import '../pages/auth/register_page.dart';
import '../pages/cart/cart_page.dart';
import '../pages/checkout/checkout_page.dart';
import '../pages/customer/customer_detail_page.dart';
import '../pages/customer/customer_list_page.dart';
import '../pages/dashboard/dashboard_page.dart';
import '../pages/order/order_history_page.dart';
import '../pages/product/product_list_page.dart';

/// Shared CartCubit instance for the current order session.
/// Reset when a new order session starts.
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
      case '/login':
        return _fadeRoute(const LoginPage(), settings);

      case '/register':
        return _fadeRoute(const RegisterPage(), settings);

      case '/dashboard':
        return _fadeRoute(
          BlocProvider(
            create: (_) => DashboardCubit(),
            child: const DashboardPage(),
          ),
          settings,
        );

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

      case '/products':
        final customer = settings.arguments as CustomerModel?;
        // Start a fresh cart session when entering product selection
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

      case '/orders':
        return _fadeRoute(
          BlocProvider(
            create: (_) => OrderCubit(),
            child: const OrderHistoryPage(),
          ),
          settings,
        );

      default:
        return _fadeRoute(const LoginPage(), settings);
    }
  }

  static PageRouteBuilder _fadeRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }
}
