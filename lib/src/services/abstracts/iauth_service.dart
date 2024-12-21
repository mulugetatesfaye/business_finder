import 'dart:io';

import 'package:business_finder/src/models/user_model.dart';

abstract class IAuthService {
  Future<UserModel?> signUp(String email, String password, String role,
      {String? username, File? profilePic});

  Future<UserModel?> login(String email, String password);

  Future<void> logout();
}
