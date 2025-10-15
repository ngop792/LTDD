import 'package:dartz/dartz.dart';
import 'package:note1/data/models/song/song.dart';
import 'package:note1/domain/entities/song/song.dart';
// ignore: unused_import
import 'package:note1/data/models/song_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SongSupabaseService {
  Future<Either<String, List<SongEntity>>> getNewsSong();
  Future<Either<String, List<SongEntity>>> getPlayList();
}

class SongSupabaseServiceImpl extends SongSupabaseService {
  final SupabaseClient client = Supabase.instance.client;

  @override
  Future<Either<String, List<SongEntity>>> getNewsSong() async {
    try {
      final response = await client
          .from('songs')
          .select()
          .order('release_date', ascending: false)
          .limit(6);

      // Ép kiểu dữ liệu an toàn
      final data = (response as List<dynamic>?) ?? [];

      // Convert sang List<SongEntity
      final songs = data
          .whereType<Map<String, dynamic>>()
          .map((e) => SongModel.fromJson(e).toEntity())
          .toList();

      return Right(songs);
    } catch (e) {
      return Left('Lỗi khi lấy bài hát: $e');
    }
  }

  @override
  Future<Either<String, List<SongEntity>>> getPlayList() async {
    try {
      final response = await client
          .from('songs')
          .select()
          .order('release_date', ascending: false)
          .limit(10); // Lấy 10 bài làm playlist ví dụ

      final data = (response as List<dynamic>?) ?? [];

      final songs = data
          .whereType<Map<String, dynamic>>()
          .map((e) => SongModel.fromJson(e).toEntity())
          .toList();

      return Right(songs);
    } catch (e) {
      return Left('Lỗi khi lấy playlist: $e');
    }
  }
}
