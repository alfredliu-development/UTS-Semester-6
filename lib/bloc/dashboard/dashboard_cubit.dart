import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/customer_repository.dart';
import '../../data/repositories/order_repository.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final OrderRepository _orderRepository;
  final CustomerRepository _customerRepository;

  DashboardCubit({
    OrderRepository? orderRepository,
    CustomerRepository? customerRepository,
  }) : _orderRepository = orderRepository ?? OrderRepository(),
       _customerRepository = customerRepository ?? CustomerRepository(),
       super(DashboardInitial());

  Future<void> loadSummary() async {
    emit(DashboardLoading());

    try {
      final results = await Future.wait([
        _orderRepository.getTodayOrderCount(),
        _customerRepository.getTotalVisited(),
        _orderRepository.getTodayTotalAmount(),
      ]);

      emit(
        DashboardLoaded(
          totalOrdersToday: results[0] as int,
          totalCustomersVisited: results[1] as int,
          totalSalesAmount: results[2] as double,
        ),
      );
    } catch (e) {
      emit(DashboardError('Gagal memuat data dashboard'));
    }
  }
}
