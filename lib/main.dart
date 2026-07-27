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
      // _RootPage adalah widget pertama yang ditampilkan.
      // Ia mengamati AuthState dan menampilkan halaman yang sesuai.
      home: const _RootPage(),
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

/// _RootPage — halaman root yang menentukan tampilan berdasarkan AuthState.
///
/// Cara kerja:
///   AuthInitial / AuthLoading  → SplashScreen
///   AuthSuccess / AuthRegisterSuccess → DashboardPage (dibungkus DashboardCubit)
///   Lainnya (belum login)      → LoginPage
///
/// Karena ini StatelessWidget yang dibungkus BlocBuilder, setiap kali
/// AuthCubit emit state baru, widget ini rebuild otomatis dan tampil
/// halaman yang benar — tanpa perlu Navigator.push sama sekali.
class _RootPage extends StatelessWidget {
  const _RootPage();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        // ── Splash loading ────────────────────────────────────────────────
        if (state is AuthInitial || state is AuthLoading) {
          return const _SplashScreen();
        }

        // ── Login berhasil → langsung ke Dashboard ────────────────────────
        if (state is AuthSuccess || state is AuthRegisterSuccess) {
          return BlocProvider(
            create: (_) => DashboardCubit()..loadSummary(),
            child: const DashboardPage(),
          );
        }

        // ── Belum login / logout → LoginPage ─────────────────────────────
        return const LoginPage();
      },
    );
  }
}

/// Splash screen saat app pertama kali buka dan cek session.
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
