import 'package:dartz/dartz.dart';
import 'package:note1/domain/entities/song/song.dart';
import 'package:note1/domain/repository/song/song_repository.dart';

class GetNewsSongsUseCase {
  final SongRepository repository;

  GetNewsSongsUseCase(this.repository);

  Future<Either<String, List<SongEntity>>> call() async {
    return await repository.getNewsSongs();
  }
}
