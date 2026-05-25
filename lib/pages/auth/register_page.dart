import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth_cubit.dart';
import '../../bloc/auth/auth_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                const SizedBox(height: 40),
                _buildHeader(),
                const SizedBox(height: 32),
                _buildForm(),
                const SizedBox(height: 20),
                _buildLoginLink(),
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
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.storefront_rounded,
            size: 42,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 18),
        const Text('Sales Take Order', style: AppTextStyles.heading1),
        const SizedBox(height: 6),
        const Text('Buat akun baru untuk mulai', style: AppTextStyles.body2),
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
            const Text('Daftar Akun', style: AppTextStyles.heading2),
            const SizedBox(height: 4),
            const Text(
              'Isi data diri Anda dengan benar',
              style: AppTextStyles.body2,
            ),
            const SizedBox(height: 24),

            // Full name
            AppTextField(
              controller: _fullNameController,
              label: 'Nama Lengkap',
              hint: 'Masukkan nama lengkap',
              prefixIcon: Icons.badge_outlined,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Nama lengkap tidak boleh kosong';
                }
                if (v.trim().length < 3) {
                  return 'Nama minimal 3 karakter';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Username
            AppTextField(
              controller: _usernameController,
              label: 'Username',
              hint: 'Masukkan username',
              prefixIcon: Icons.person_outline_rounded,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Username tidak boleh kosong';
                }
                if (v.trim().length < 4) {
                  return 'Username minimal 4 karakter';
                }
                if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(v.trim())) {
                  return 'Username hanya boleh huruf, angka, dan underscore';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Email
            AppTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'Masukkan alamat email',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Email tidak boleh kosong';
                }
                if (!RegExp(
                  r'^[\w\-.]+@[\w\-]+\.[a-zA-Z]{2,}$',
                ).hasMatch(v.trim())) {
                  return 'Format email tidak valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Password
            AppTextField(
              controller: _passwordController,
              label: 'Password',
              hint: 'Minimal 6 karakter',
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
                if (v == null || v.isEmpty) {
                  return 'Password tidak boleh kosong';
                }
                if (v.length < 6) {
                  return 'Password minimal 6 karakter';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Confirm password
            AppTextField(
              controller: _confirmPasswordController,
              label: 'Konfirmasi Password',
              hint: 'Ulangi password',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: _obscureConfirm,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textSecondary,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Konfirmasi password tidak boleh kosong';
                }
                if (v != _passwordController.text) {
                  return 'Password tidak cocok';
                }
                return null;
              },
            ),
            const SizedBox(height: 28),

            // Submit button
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                return AppButton(
                  label: 'Daftar Sekarang',
                  icon: Icons.how_to_reg_rounded,
                  isLoading: state is AuthLoading,
                  width: double.infinity,
                  onPressed: _handleRegister,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ─── Login link ───────────────────────────────────────────────────────────

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Sudah punya akun?', style: AppTextStyles.body2),
        TextButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          child: const Text(
            'Masuk di sini',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Handlers ─────────────────────────────────────────────────────────────

  void _handleRegister() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthCubit>().register(
      username: _usernameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      fullName: _fullNameController.text,
    );
  }

  void _handleAuthState(BuildContext context, AuthState state) {
    if (state is AuthRegisterSuccess) {
      _showSuccessDialog(state.savedUsername, state.savedPassword);
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

  void _showSuccessDialog(String username, String password) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 44,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Registrasi Berhasil!',
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Akun Anda telah dibuat. Kredensial login disimpan otomatis.',
              style: AppTextStyles.body2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Saved credentials info box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.save_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Tersimpan otomatis',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _CredentialRow(label: 'Username', value: username),
                  const SizedBox(height: 4),
                  _CredentialRow(
                    label: 'Password',
                    value: '•' * password.length,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushReplacementNamed(context, '/dashboard');
                },
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('Lanjut ke Dashboard'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helper widget ────────────────────────────────────────────────────────────

class _CredentialRow extends StatelessWidget {
  final String label;
  final String value;

  const _CredentialRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        const Text(': ', style: AppTextStyles.caption),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.body2.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
