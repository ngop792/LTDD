import 'package:dartz/dartz.dart';
import 'package:note1/data/sources/song/song_superbase_service.dart';
import 'package:note1/domain/entities/song/song.dart';
import 'package:note1/domain/repository/song/song_repository.dart';

class SongRepositoryImpl extends SongRepository {
  final SongSupabaseService service;

  SongRepositoryImpl(this.service);

  @override
  Future<Either<String, List<SongEntity>>> getNewsSongs() async {
    return await service.getNewsSong();
  }

  @override
  Future<Either<String, List<SongEntity>>> getPlayList() async {
    return await service.getPlayList();
  }
}
