import '../../data/models/sales_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final SalesModel sales;
  AuthSuccess(this.sales);
}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}

class AuthLoggedOut extends AuthState {}

/// Emitted after a successful registration.
/// Carries the registered credentials so the login form can be pre-filled.
class AuthRegisterSuccess extends AuthState {
  final SalesModel sales;
  final String savedUsername;
  final String savedPassword;

  AuthRegisterSuccess({
    required this.sales,
    required this.savedUsername,
    required this.savedPassword,
  });
}
