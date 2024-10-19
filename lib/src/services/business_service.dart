import 'package:business_finder/src/models/business_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final businessServiceProvider = Provider<BusinessService>((ref) {
  return BusinessService();
});

class BusinessService {
  final CollectionReference _businessCollection =
      FirebaseFirestore.instance.collection('businesses');

  Future<void> createBusiness(BusinessModel business) async {
    await _businessCollection.doc(business.businessId).set(business.toJson());
  }

  // Fetch all businesses once (for Riverpod's async handling)
  Future<List<BusinessModel>> fetchBusinessesOnce() async {
    final snapshot = await _businessCollection.get();
    return snapshot.docs.map((doc) {
      return BusinessModel.fromJson(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  Stream<List<BusinessModel>> fetchBusinesses() {
    return _businessCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              BusinessModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<void> updateBusiness(BusinessModel business) async {
    await _businessCollection
        .doc(business.businessId)
        .update(business.toJson());
  }

  Future<void> deleteBusiness(String businessId) async {
    await _businessCollection.doc(businessId).delete();
  }
}
