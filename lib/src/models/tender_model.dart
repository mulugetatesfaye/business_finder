class Tender {
  final String id; // Firestore document ID
  final String userId;
  final String title;
  final String? description;
  final double? budget;
  final DateTime? deadline;
  final List<String>? attachments;
  final String status; // 'open' or 'closed'
  final DateTime? createdAt;

  Tender({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.budget,
    this.deadline,
    this.attachments,
    required this.status,
    this.createdAt,
  });

  // Convert Tender object to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'businessId': userId,
        'title': title,
        'description': description,
        'budget': budget,
        'deadline': deadline?.toIso8601String(),
        'attachments': attachments,
        'status': status,
        'createdAt': createdAt?.toIso8601String(),
      };

  // Create Tender object from JSON
  factory Tender.fromJson(Map<String, dynamic> json) => Tender(
        id: json['id'],
        userId: json['businessId'],
        title: json['title'],
        description: json['description'],
        budget: json['budget'],
        deadline:
            json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
        attachments: List<String>.from(json['attachments'] ?? []),
        status: json['status'],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : null,
      );
}
