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
      home: const _SplashRouter(),
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

// ─── Splash / Auth Router ─────────────────────────────────────────────────────
/// Widget ini menjadi "home" pertama aplikasi.
/// Ia mendengarkan state AuthCubit dan:
///   - Saat loading/initial → tampil splash screen
///   - Saat AuthSuccess / AuthRegisterSuccess → navigasi ke dashboard
///   - Saat lainnya (belum login) → tampil halaman login
class _SplashRouter extends StatelessWidget {
  const _SplashRouter();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess || state is AuthRegisterSuccess) {
          // Ganti seluruh navigation stack dengan dashboard
          Navigator.of(context).pushAndRemoveUntil(
            PageRouteBuilder(
              pageBuilder: (ctx, _, __) => BlocProvider(
                create: (_) => DashboardCubit()..loadSummary(),
                child: const DashboardPage(),
              ),
              transitionsBuilder: (ctx, animation, _, child) =>
                  FadeTransition(opacity: animation, child: child),
              transitionDuration: const Duration(milliseconds: 300),
            ),
            (route) => false, // hapus semua route sebelumnya
          );
        } else if (state is AuthLoggedOut) {
          // Kembali ke login, hapus semua route
          Navigator.of(context).pushAndRemoveUntil(
            PageRouteBuilder(
              pageBuilder: (ctx, _, __) => const LoginPage(),
              transitionsBuilder: (ctx, animation, _, child) =>
                  FadeTransition(opacity: animation, child: child),
              transitionDuration: const Duration(milliseconds: 300),
            ),
            (route) => false,
          );
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          // Tampil berdasarkan state saat pertama build
          if (state is AuthSuccess || state is AuthRegisterSuccess) {
            return BlocProvider(
              create: (_) => DashboardCubit()..loadSummary(),
              child: const DashboardPage(),
            );
          }
          if (state is AuthInitial || state is AuthLoading) {
            return const _SplashScreen();
          }
          return const LoginPage();
        },
      ),
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
