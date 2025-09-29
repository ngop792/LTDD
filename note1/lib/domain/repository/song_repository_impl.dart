import 'package:dartz/dartz.dart';
import 'package:note1/data/repository/song/song.dart';
import 'package:note1/data/sources/song/song_superbase_service.dart';

import '../../service_locator.dart';

class SongRepositoryImpl extends SongsRepository {
  @override
  Future<Either> getNewSongs() async {
    return sl<SongSupabaseService>().getNewsSong();
  }
}
