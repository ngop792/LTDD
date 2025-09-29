import 'package:firebase_auth/firebase_auth.dart';
import 'package:note1/data/models/auth/create_user_req.dart';

abstract class AuthFirebaseService {
  Future<UserCredential> signup(CreateUserReq req);
}

class AuthFirebaseServiceImpl implements AuthFirebaseService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<UserCredential> signup(CreateUserReq req) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
      email: req.email,
      password: req.password,
    );
  }
}
