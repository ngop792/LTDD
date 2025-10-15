import 'package:dartz/dartz.dart';
import 'package:note1/domain/entities/song/song.dart';
import 'package:note1/domain/repository/song/song_repository.dart';

class GetPlayListUseCase {
  final SongRepository repository;

  GetPlayListUseCase(this.repository);

  Future<Either<String, List<SongEntity>>> call() {
    return repository.getPlayList();
  }
}
