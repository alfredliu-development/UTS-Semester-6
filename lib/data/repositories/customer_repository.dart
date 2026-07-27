import '../api/api_service.dart';
import '../models/customer_model.dart';

class CustomerRepository {
  final ApiService _api = ApiService.instance;

  Future<List<CustomerModel>> getAll() async {
    try {
      final response = await _api.get('/customers');
      final List data = response.data as List;
      return data
          .map((e) => CustomerModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      return [];
    }
  }

  Future<List<CustomerModel>> search(String query) async {
    try {
      final response = await _api.get(
        '/customers/search',
        queryParameters: {'q': query},
      );
      final List data = response.data as List;
      return data
          .map((e) => CustomerModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      return [];
    }
  }

  Future<CustomerModel?> getById(int id) async {
    try {
      final response = await _api.get('/customers/$id');
      if (response.data == null) return null;
      return CustomerModel.fromMap(response.data as Map<String, dynamic>);
    } on ApiException {
      return null;
    }
  }

  Future<void> updateVisitStatus(int id, bool isVisited) async {
    try {
      await _api.put(
        '/customers/$id/visit',
        data: {'is_visited': isVisited ? 1 : 0},
      );
    } on ApiException {
      // Gagal silent — caller bisa cek via getById jika perlu konfirmasi
    }
  }

  Future<int> getTotalVisited() async {
    try {
      final response = await _api.get('/customers/stats/total-visited');
      return (response.data['count'] as int?) ?? 0;
    } on ApiException {
      return 0;
    }
  }
}
