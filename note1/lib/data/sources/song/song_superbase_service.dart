import 'package:dartz/dartz.dart';
import 'package:note1/data/models/song/song.dart';
import 'package:note1/domain/entities/song/song.dart';
// ignore: unused_import
import 'package:note1/data/models/song_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SongSupabaseService {
  Future<Either<String, List<SongEntity>>> getNewsSong();
}

class SongSupabaseServiceImpl extends SongSupabaseService {
  final SupabaseClient client = Supabase.instance.client;

  @override
  Future<Either<String, List<SongEntity>>> getNewsSong() async {
    try {
      // Lấy 3 bài hát mới nhất từ Supabase
      final response = await client
          .from('songs')
          .select()
          .order('release_date', ascending: false)
          .limit(6);

      // Ép kiểu dữ liệu trả về thành List<Map<String, dynamic>>
      final data = response as List<dynamic>;

      // Convert sang List<SongEntity>
      final songs = data
          .map((e) => SongModel.fromJson(e as Map<String, dynamic>).toEntity())
          .toList();

      return Right(songs);
    } catch (e) {
      return Left('Lỗi khi lấy bài hát: $e');
    }
  }
}
