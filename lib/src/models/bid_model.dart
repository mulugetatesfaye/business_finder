class Bid {
  final String id; // Firestore document ID
  final String vendorId;
  final String tenderId;
  final int bidAmount;
  final int? estimatedCompletionTime; // In days
  final String? proposalNotes;
  final DateTime? submittedAt;
  final String status; // 'submitted', 'accepted', or 'rejected'

  Bid({
    required this.id,
    required this.vendorId,
    required this.tenderId,
    required this.bidAmount,
    this.estimatedCompletionTime,
    this.proposalNotes,
    this.submittedAt,
    required this.status,
  });

  // Convert Bid object to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'vendorId': vendorId,
        'tenderId': tenderId,
        'bidAmount': bidAmount,
        'estimatedCompletionTime': estimatedCompletionTime,
        'proposalNotes': proposalNotes,
        'submittedAt': submittedAt?.toIso8601String(),
        'status': status,
      };

  // Create Bid object from JSON
  factory Bid.fromJson(Map<String, dynamic> json) => Bid(
        id: json['id'],
        vendorId: json['vendorId'],
        tenderId: json['tenderId'],
        bidAmount: json['bidAmount'],
        estimatedCompletionTime: json['estimatedCompletionTime'],
        proposalNotes: json['proposalNotes'],
        submittedAt: json['submittedAt'] != null
            ? DateTime.parse(json['submittedAt'])
            : null,
        status: json['status'],
      );
}
