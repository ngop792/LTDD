import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note1/core/configs/constants/app_urls.dart';
import 'package:note1/domain/entities/song/song.dart';
import 'package:note1/pretension/home/bloc/news_songs_cubit.dart';
import 'package:note1/pretension/home/bloc/news_songs_state.dart';

class NewsSongs extends StatelessWidget {
  const NewsSongs({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NewsSongsCubit()..getNewsSongs(),
      child: SizedBox(
        height: 200,
        child: BlocBuilder<NewsSongsCubit, NewsSongsState>(
          builder: (context, state) {
            if (state is NewsSongsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is NewsSongsLoaded) {
              return _songs(state.songs);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _songs(List<SongEntity> songs) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      itemCount: songs.length,
      separatorBuilder: (context, _) => const SizedBox(width: 14),
      itemBuilder: (context, index) {
        final song = songs[index];

        // -----------------------------------------------------------------
        // LOGIC TẠO URL CHÍNH XÁC CHO SUPABASE
        // -----------------------------------------------------------------
        final rawFileName = '${song.artist} - ${song.title}.jpg';

        // Mã hóa ký tự đặc biệt/khoảng trắng
        final encodedFileName = Uri.encodeComponent(rawFileName);

        // KẾT HỢP URL HOÀN CHỈNH (Giả định AppUrls.superstorageBaseUrl là đúng)
        final imageUrl = '${AppUrls.superstorageBaseUrl}$encodedFileName';

        // *ĐỂ GỠ LỖI:* Bạn có thể in ra URL cuối cùng ở đây để kiểm tra trên trình duyệt:
        // print('Final Image URL for ${song.title}: $imageUrl');
        // -----------------------------------------------------------------

        return SizedBox(
          width: 160,
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  // Dùng ClipRRect để bo tròn Image.network
                  borderRadius: BorderRadius.circular(30),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    // Thêm errorBuilder để báo lỗi rõ ràng nếu ảnh không tải được
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                    // Thêm loadingBuilder nếu bạn muốn hiển thị spinner khi đang tải
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Hiển thị Tên bài hát (để kiểm tra dữ liệu)
              Text(
                song.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              // Hiển thị Tên nghệ sĩ (để kiểm tra dữ liệu)
              Text(
                song.artist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}
