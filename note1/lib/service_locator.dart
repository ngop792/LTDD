import 'package:get_it/get_it.dart';
import 'package:note1/data/repository/auth/auth_repository_impl.dart';
import 'package:note1/data/repository/song/song_repository_impl.dart';
import 'package:note1/data/sources/auth/auth_firebase_service.dart';
import 'package:note1/data/sources/song/song_superbase_service.dart';
import 'package:note1/domain/repository/auth/auth.dart';
import 'package:note1/domain/repository/song/song_repository.dart';
import 'package:note1/domain/usecase/auth/signup.dart';
import 'package:note1/domain/usecase/song/get_news_songs.dart';
import 'package:note1/domain/usecase/song/get_play_list.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // Service Firebase
  sl.registerLazySingleton<AuthFirebaseService>(
    () => AuthFirebaseServiceImpl(),
  );
  sl.registerLazySingleton<SongSupabaseService>(
    () => SongSupabaseServiceImpl(),
  );

  // Repository (inject service)
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthFirebaseService>()),
  );
  sl.registerLazySingleton<SongRepository>(
    () => SongRepositoryImpl(sl<SongSupabaseService>()),
  );

  // UseCase (inject repo)
  sl.registerLazySingleton<SignupUseCase>(
    () => SignupUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<GetPlayListUseCase>(
    () => GetPlayListUseCase(sl<SongRepository>()),
  );
}
