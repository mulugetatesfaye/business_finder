// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/review_model.dart';

// class ReviewService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Future<void> addReview(ReviewModel review) async {
//     await _firestore
//         .collection('businesses')
//         .doc(review.businessId)
//         .collection('reviews')
//         .doc(review.reviewId)
//         .set(review.toJson());
//   }

//   Stream<List<ReviewModel>> fetchReviews(String businessId) {
//     return _firestore
//         .collection('businesses')
//         .doc(businessId)
//         .collection('reviews')
//         .snapshots()
//         .map((snapshot) {
//       return snapshot.docs
//           .map((doc) => ReviewModel.fromJson(doc.data() as Map<String, dynamic>))
//           .toList();
//     });
//   }
// }
