import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth_cubit.dart';
import '../../bloc/auth/auth_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _credentialsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  /// Pre-fill form dengan credentials yang tersimpan (dari register / login sebelumnya)
  Future<void> _loadSavedCredentials() async {
    final (username, password) = await context
        .read<AuthCubit>()
        .getSavedCredentials();

    if (!mounted) return;
    if (username.isNotEmpty) {
      _usernameController.text = username;
      _passwordController.text = password;
      setState(() => _credentialsLoaded = true);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<AuthCubit, AuthState>(
        listener: _handleAuthState,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                _buildHeader(),
                const SizedBox(height: 40),
                _buildForm(),
                const SizedBox(height: 16),
                _buildRegisterLink(),
                const SizedBox(height: 12),
                _buildHint(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.asset(
              'assets/image/my_logo.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.storefront_rounded,
                size: 48,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text('Sales Take Order', style: AppTextStyles.heading1),
        const SizedBox(height: 6),
        const Text('Masuk untuk melanjutkan', style: AppTextStyles.body2),
      ],
    );
  }

  // ─── Form ─────────────────────────────────────────────────────────────────

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Login', style: AppTextStyles.heading2),
                if (_credentialsLoaded)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 12,
                          color: AppColors.success,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Tersimpan',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            const Text('Role: Sales', style: AppTextStyles.body2),
            const SizedBox(height: 24),

            AppTextField(
              controller: _usernameController,
              label: 'Username',
              hint: 'Masukkan username',
              prefixIcon: Icons.person_outline_rounded,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Username tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            AppTextField(
              controller: _passwordController,
              label: 'Password',
              hint: 'Masukkan password',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textSecondary,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Password tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 28),

            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                return AppButton(
                  label: 'Masuk',
                  icon: Icons.login_rounded,
                  isLoading: state is AuthLoading,
                  width: double.infinity,
                  onPressed: _handleLogin,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ─── Register link ────────────────────────────────────────────────────────

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Belum punya akun?', style: AppTextStyles.body2),
        TextButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/register'),
          child: const Text(
            'Daftar sekarang',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Hint ─────────────────────────────────────────────────────────────────

  Widget _buildHint() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: AppColors.primary.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Demo: username sales01 / password sales123',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Handlers ─────────────────────────────────────────────────────────────

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().login(
      _usernameController.text,
      _passwordController.text,
    );
  }

  void _handleAuthState(BuildContext context, AuthState state) {
    if (state is AuthSuccess) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else if (state is AuthFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}
