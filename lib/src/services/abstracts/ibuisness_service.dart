import 'package:business_finder/src/models/business_model.dart';

abstract class IBusinessService {
  Future<void> createBusiness(BusinessModel business);

  Future<List<BusinessModel>> fetchBusinessesOnce();

  Stream<List<BusinessModel>> fetchBusinesses();

  Future<void> updateBusiness(BusinessModel business);

  Future<void> deleteBusiness(String businessId);
}
