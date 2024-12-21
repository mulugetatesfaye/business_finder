import 'package:business_finder/src/models/tender_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TenderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createTender(Tender tender) async {
    await _db.collection('tenders').doc(tender.id).set(tender.toJson());
  }

  Future<List<Tender>> getOpenTendersOnce() async {
    final snapshot = await _db
        .collection('tenders')
        .orderBy('createdAt', descending: true)
        .where('status', isEqualTo: 'open')
        .get();
    return snapshot.docs.map((doc) => Tender.fromJson(doc.data())).toList();
  }

  Stream<List<Tender>> getOpenTenders() {
    return _db
        .collection('tenders')
        .where('status', isEqualTo: 'open')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Tender.fromJson(doc.data())).toList());
  }
}
