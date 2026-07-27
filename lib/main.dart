import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/app_router.dart';
import 'bloc/auth/auth_cubit.dart';
import 'bloc/auth/auth_state.dart';
import 'bloc/dashboard/dashboard_cubit.dart';
import 'core/constants/app_colors.dart';
import 'pages/auth/login_page.dart';
import 'pages/dashboard/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    BlocProvider(
      create: (_) => AuthCubit()..checkSession(),
      child: const SalesOrderApp(),
    ),
  );
}

class SalesOrderApp extends StatelessWidget {
  const SalesOrderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sales Take Order',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      // Tidak pakai home — semua dihandle oleh _AuthGate
      builder: (context, child) => _AuthGate(child: child),
      // Route awal
      initialRoute: '/',
      onGenerateRoute: AppRouter.generateRoute,
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        color: AppColors.surface,
      ),
    );
  }
}

/// _AuthGate — wrapper transparan yang merender child dari MaterialApp,
/// tapi mengganti `child` dengan widget yang sesuai berdasarkan AuthState.
/// Dengan cara ini AuthCubit tetap di atas MaterialApp dan bisa diakses
/// dari mana saja termasuk DashboardPage.
class _AuthGate extends StatelessWidget {
  final Widget? child;
  const _AuthGate({this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        // ── Splash / Loading ──────────────────────────────────────────────
        if (state is AuthInitial || state is AuthLoading) {
          return const _SplashScreen();
        }

        // ── Sudah login → Dashboard ───────────────────────────────────────
        if (state is AuthSuccess || state is AuthRegisterSuccess) {
          return BlocProvider(
            create: (_) => DashboardCubit()..loadSummary(),
            child: const DashboardPage(),
          );
        }

        // ── Belum login → Login page ──────────────────────────────────────
        return const LoginPage();
      },
    );
  }
}

// ─── Splash Screen ────────────────────────────────────────────────────────────
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront_rounded, size: 72, color: Colors.white),
            SizedBox(height: 20),
            Text(
              'Sales Take Order',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(color: Colors.white70),
          ],
        ),
      ),
    );
  }
}
