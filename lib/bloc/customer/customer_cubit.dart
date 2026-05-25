import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/customer_repository.dart';
import 'customer_state.dart';

class CustomerCubit extends Cubit<CustomerState> {
  final CustomerRepository _repository;

  CustomerCubit({CustomerRepository? repository})
    : _repository = repository ?? CustomerRepository(),
      super(CustomerInitial());

  Future<void> loadCustomers() async {
    emit(CustomerLoading());

    try {
      final customers = await _repository.getAll();
      emit(CustomerLoaded(customers: customers));
    } catch (e) {
      emit(CustomerError('Gagal memuat data pelanggan'));
    }
  }

  Future<void> searchCustomers(String query) async {
    try {
      final customers = query.trim().isEmpty
          ? await _repository.getAll()
          : await _repository.search(query.trim());

      emit(CustomerLoaded(customers: customers, searchQuery: query));
    } catch (e) {
      emit(CustomerError('Gagal mencari pelanggan'));
    }
  }

  Future<void> loadCustomerDetail(int id) async {
    emit(CustomerLoading());

    try {
      final customer = await _repository.getById(id);

      if (customer == null) {
        emit(CustomerError('Pelanggan tidak ditemukan'));
        return;
      }

      emit(CustomerDetailLoaded(customer));
    } catch (e) {
      emit(CustomerError('Gagal memuat detail pelanggan'));
    }
  }

  Future<void> markAsVisited(int id) async {
    try {
      await _repository.updateVisitStatus(id, true);
    } catch (_) {}
  }
}
