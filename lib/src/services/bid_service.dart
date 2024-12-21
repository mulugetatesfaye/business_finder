import 'package:business_finder/src/models/bid_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BidService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> submitBid(String tenderId, Bid bid) async {
    await _db
        .collection('tenders')
        .doc(tenderId)
        .collection('bids')
        .doc(bid.id)
        .set(bid.toJson());
  }

  Stream<List<Bid>> getBidsForTender(String tenderId) {
    return _db
        .collection('tenders')
        .doc(tenderId)
        .collection('bids')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Bid.fromJson(doc.data())).toList());
  }
}
