import 'package:dartz/dartz.dart';
import 'package:note1/domain/entities/song/song.dart';

abstract class SongRepository {
  Future<Either<String, List<SongEntity>>> getNewsSongs();
}
