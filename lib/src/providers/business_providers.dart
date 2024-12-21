import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/business_model.dart';
import '../services/business_service.dart';

// StateNotifier to manage businesses state
class BusinessNotifier extends StateNotifier<AsyncValue<List<BusinessModel>>> {
  final FirebaseBusinessService _service;

  BusinessNotifier(this._service) : super(const AsyncValue.loading()) {
    _loadBusinesses();
  }

  Future<void> _loadBusinesses() async {
    try {
      final businesses = await _service.fetchBusinessesOnce();
      state = AsyncValue.data(businesses);
    } catch (e) {
      state = AsyncValue.error(e, state.stackTrace!);
    }
  }

  Future<void> addBusiness(BusinessModel business) async {
    await _service.createBusiness(business);
    _loadBusinesses(); // Refresh the list
  }

  Future<void> deleteBusiness(String businessId) async {
    await _service.deleteBusiness(businessId);
    _loadBusinesses(); // Refresh the list
  }
}

// Provider to expose BusinessNotifier
final businessNotifierProvider =
    StateNotifierProvider<BusinessNotifier, AsyncValue<List<BusinessModel>>>(
  (ref) => BusinessNotifier(FirebaseBusinessService()),
);
