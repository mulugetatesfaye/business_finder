class BusinessModel {
  String businessId;
  String ownerId; // Links to UserModel
  String name;
  String? description; // Optional
  String? categoryId; // Optional
  String? contactNumber; // Optional
  String? email; // Optional
  String? website; // Optional
  String? imageUrl; // Optional
  LocationModel? location; // Optional
  Map<String, String>? workingHours; // Optional
  String? status; // Optional, e.g., "Open" or "Closed"
  double averageRating;
  int reviewCount;
  bool isFeatured;
  DateTime createdAt;

  // Constructor
  BusinessModel({
    required this.businessId,
    required this.ownerId,
    required this.name,
    this.description,
    this.categoryId,
    this.contactNumber,
    this.email,
    this.website,
    this.imageUrl,
    this.location,
    this.workingHours,
    this.status,
    this.averageRating = 0.0,
    this.reviewCount = 0,
    this.isFeatured = false,
    required this.createdAt,
  });

  // **fromJson Method**: Converts JSON data to BusinessModel
  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      businessId: json['businessId'] as String,
      ownerId: json['ownerId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      categoryId: json['categoryId'] as String?,
      contactNumber: json['contactNumber'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      imageUrl: json['imageUrl'] as String?,
      location: json['location'] != null
          ? LocationModel.fromJson(json['location'])
          : null,
      workingHours: (json['workingHours'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, value as String)),
      status: json['status'] as String?,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      isFeatured: json['isFeatured'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // **toJson Method**: Converts BusinessModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'businessId': businessId,
      'ownerId': ownerId,
      'name': name,
      'description': description,
      'categoryId': categoryId,
      'contactNumber': contactNumber,
      'email': email,
      'website': website,
      'imageUrl': imageUrl,
      'location': location?.toJson(),
      'workingHours': workingHours,
      'status': status,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'isFeatured': isFeatured,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class LocationModel {
  double latitude;
  double longitude;
  String address;
  String city;
  String state;

  // Constructor
  LocationModel({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
    required this.state,
  });

  // **fromJson Method**
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
    );
  }

  // **toJson Method**
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'state': state,
    };
  }
}
