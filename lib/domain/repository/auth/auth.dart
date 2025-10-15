import 'package:note1/data/models/auth/create_user_req.dart';

abstract class AuthRepository {
  Future<void> signup(CreateUserReq req);
}
