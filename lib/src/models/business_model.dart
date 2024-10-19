class BusinessModel {
  String businessId;
  String ownerId; // Links to UserModel
  String name;
  String description;
  String categoryId; // Links to CategoryModel
  String contactNumber;
  String email;
  String? website;
  String imageUrl;
  LocationModel location;
  double averageRating;
  int reviewCount;
  bool isFeatured;
  DateTime createdAt;

  // Constructor
  BusinessModel({
    required this.businessId,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.contactNumber,
    required this.email,
    this.website,
    required this.imageUrl,
    required this.location,
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
      description: json['description'] as String,
      categoryId: json['categoryId'] as String,
      contactNumber: json['contactNumber'] as String,
      email: json['email'] as String,
      website: json['website'] as String?,
      imageUrl: json['imageUrl'] as String,
      location: LocationModel.fromJson(json['location']),
      averageRating: (json['averageRating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      isFeatured: json['isFeatured'] as bool,
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
      'location': location.toJson(),
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
  String country;
  String postalCode;

  // Constructor
  LocationModel({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
  });

  // **fromJson Method**
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      country: json['country'] as String,
      postalCode: json['postalCode'] as String,
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
      'country': country,
      'postalCode': postalCode,
    };
  }
}
