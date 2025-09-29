import 'package:dartz/dartz.dart';
import 'package:note1/data/models/auth/create_user_req.dart';
import 'package:note1/domain/repository/auth/auth.dart';

class SignupUseCase {
  final AuthRepository _repo;
  SignupUseCase(this._repo);

  /// Trả về Either<errorMessage, void>
  Future<Either<String, void>> call({required CreateUserReq params}) async {
    try {
      await _repo.signup(params);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
