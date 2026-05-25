abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final int totalOrdersToday;
  final int totalCustomersVisited;
  final double totalSalesAmount;

  DashboardLoaded({
    required this.totalOrdersToday,
    required this.totalCustomersVisited,
    required this.totalSalesAmount,
  });
}

class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
}
