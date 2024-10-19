class ReviewModel {
  String reviewId;
  String businessId; // Links to BusinessModel
  String userId; // Links to UserModel
  String comment;
  double rating; // e.g., 1.0 - 5.0
  DateTime createdAt;

  ReviewModel({
    required this.reviewId,
    required this.businessId,
    required this.userId,
    required this.comment,
    required this.rating,
    required this.createdAt,
  });
}
