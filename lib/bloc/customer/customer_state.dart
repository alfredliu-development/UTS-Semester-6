import '../../data/models/customer_model.dart';

abstract class CustomerState {}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomerLoaded extends CustomerState {
  final List<CustomerModel> customers;
  final String searchQuery;

  CustomerLoaded({required this.customers, this.searchQuery = ''});
}

class CustomerDetailLoaded extends CustomerState {
  final CustomerModel customer;

  CustomerDetailLoaded(this.customer);
}

class CustomerError extends CustomerState {
  final String message;
  CustomerError(this.message);
}
