class UserModel {
  String uid;
  String email;
  String? displayName;
  String? phoneNumber;
  String role; // 'customer', 'business_owner', 'admin'
  String? profilePictureUrl;
  DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.phoneNumber,
    this.role = 'customer',
    this.profilePictureUrl,
    required this.createdAt,
  });

  // **fromJson Method**: Converts JSON data to UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      role: json['role'] as String,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // **toJson Method**: Converts UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'role': role,
      'profilePictureUrl': profilePictureUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
