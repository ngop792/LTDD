import 'package:note1/data/models/auth/create_user_req.dart';
import 'package:note1/data/sources/auth/auth_firebase_service.dart';
import 'package:note1/domain/repository/auth/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:note1/core/utils/firebase_error_mapper.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthFirebaseService _service;
  AuthRepositoryImpl(this._service);

  @override
  Future<void> signup(CreateUserReq req) async {
    try {
      await _service.signup(req);
    } on FirebaseAuthException catch (e) {
      // map lỗi Firebase → thông báo đẹp
      throw FirebaseErrorMapper.getMessage(e);
    }
  }
}
