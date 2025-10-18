import 'package:flutter/material.dart';
import 'package:note1/domain/entities/playlist.dart';

// Giả định class Song (giữ lại để tránh lỗi biên dịch)
class Song {
  final String title;
  final String artist;
  final String imageUrl; // URL hoặc path asset

  Song({required this.title, required this.artist, required this.imageUrl});
}

// ⚠️ Danh sách này chỉ là biến toàn cục rỗng, không cần dùng
// Nếu dùng API, bạn nên load trực tiếp vào _sourceSongs.
final List<Song> availableSongs = [];

class AddSongPage extends StatefulWidget {
  final Playlist playlist;

  const AddSongPage({super.key, required this.playlist});

  @override
  State<AddSongPage> createState() => _AddSongPageState();
}

class _AddSongPageState extends State<AddSongPage> {
  // Biến trạng thái để lưu danh sách bài hát được tìm kiếm/hiển thị
  List<Song> currentSongs = [];
  bool isLoading = false; // Trạng thái tải dữ liệu

  // Dữ liệu gốc mà ô tìm kiếm sẽ lọc trên đó.
  // ✅ ĐÃ SỬA: Không dùng 'final' và khởi tạo bằng danh sách rỗng để có thể gán lại
  List<Song> _sourceSongs = [];

  @override
  void initState() {
    super.initState();
    // ✅ THÊM: Bắt đầu tải dữ liệu khi widget được khởi tạo
    _loadInitialSongs();
  }

  // ✅ HÀM TẢI DỮ LIỆU ĐƯỢC THÊM VÀO
  Future<void> _loadInitialSongs() async {
    setState(() {
      isLoading = true; // Bắt đầu tải, hiển thị CircularProgressIndicator
    });

    // --- PHẦN GỌI API THỰC TẾ CỦA BẠN SẼ Ở ĐÂY ---

    // 💡 Tạm thời dùng Future.delayed để giả lập độ trễ mạng (2 giây)
    await Future.delayed(const Duration(seconds: 2));

    // 💡 Dữ liệu mẫu tạm thời (thay thế bằng kết quả từ API)
    final List<Song> fetchedSongs = [
      Song(
        title: "Bài Hát API Mới",
        artist: "Ca Sĩ API",
        imageUrl: "assets/new_song_1.jpg",
      ),
      Song(
        title: "Nhạc Hot 2024",
        artist: "Trending",
        imageUrl: "assets/new_song_2.jpg",
      ),
      Song(
        title: "Đêm Đà Nẵng",
        artist: "Ai Đó",
        imageUrl: "assets/new_song_3.jpg",
      ),
    ];

    // ----------------------------------------------------

    setState(() {
      _sourceSongs = fetchedSongs; // Cập nhật danh sách gốc
      currentSongs = fetchedSongs; // Cập nhật danh sách hiển thị
      isLoading = false; // Kết thúc tải
    });
  }

  // Hàm xử lý logic tìm kiếm và lọc dữ liệu (không thay đổi)
  void _filterSongs(String query) {
    if (query.isEmpty) {
      setState(() {
        currentSongs = _sourceSongs;
      });
      return;
    }

    final filteredList = _sourceSongs.where((song) {
      final titleLower = song.title.toLowerCase();
      final artistLower = song.artist.toLowerCase();
      final searchLower = query.toLowerCase();
      return titleLower.contains(searchLower) ||
          artistLower.contains(searchLower);
    }).toList();

    setState(() {
      currentSongs = filteredList;
    });
  }

  // ... (các widget _buildSearchBar, _buildTabBar, _buildSongList và build method không đổi)

  // --- Widget Thanh Tìm Kiếm ---
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextField(
          onChanged: _filterSongs,
          decoration: const InputDecoration(
            hintText: "Tìm kiếm bài hát, nghệ sĩ",
            hintStyle: TextStyle(color: Colors.grey),
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 8.0),
          ),
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  // --- Widget TabBar (Giãn đều) ---
  Widget _buildTabBar() {
    return const Align(
      alignment: Alignment.centerLeft,
      child: TabBar(
        isScrollable: false, // Giãn đều các tab
        indicatorColor: Colors.purple,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
        labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        tabs: [
          Tab(text: "Online"),
          Tab(text: "Cá nhân"),
          Tab(text: "Gần đây"),
          Tab(text: "Upload"),
        ],
      ),
    );
  }

  // --- Widget Danh sách Bài hát (Tối ưu giao diện Thẳng hàng) ---
  Widget _buildSongList(List<Song> songs, BuildContext context) {
    if (isLoading) {
      // ✅ Hiển thị loading khi dữ liệu đang được tải
      return const Center(child: CircularProgressIndicator());
    }

    // Trường hợp 1: Danh sách gốc có data nhưng kết quả lọc rỗng
    if (songs.isEmpty && _sourceSongs.isNotEmpty) {
      return const Center(
        child: Text(
          "Không tìm thấy bài hát nào phù hợp với từ khóa tìm kiếm.",
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    // Trường hợp 2: Danh sách gốc rỗng (chưa load data hoặc data API rỗng)
    if (songs.isEmpty && _sourceSongs.isEmpty) {
      return const Center(
        child: Text(
          "Chưa có bài hát nào được tải lên.",
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    // Phần hiển thị danh sách bài hát và DẤU CỘNG
    return ListView.builder(
      itemCount: songs.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final song = songs[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 4.0,
          ),

          leading: ClipRRect(
            borderRadius: BorderRadius.circular(5.0),
            child: Image.asset(
              song.imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 50,
                height: 50,
                color: Colors.grey.shade300,
                child: const Icon(Icons.music_note, color: Colors.white),
              ),
            ),
          ),

          title: Text(
            song.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            song.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          trailing: IconButton(
            icon: const Icon(
              Icons.add_circle_outline,
              color: Colors.grey,
              size: 28,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Đã thêm "${song.title}" vào playlist "${widget.playlist.name}"',
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                automaticallyImplyLeading: false,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0.5,
                centerTitle: true,
                title: const Text(
                  "Thêm bài hát",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(100.0),
                  child: Column(
                    children: [
                      _buildSearchBar(),
                      _buildTabBar(),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xFFE0E0E0),
                      ),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              _buildSongList(currentSongs, context),
              const Center(child: Text("Danh sách bài hát Cá nhân")),
              const Center(child: Text("Danh sách bài hát Gần đây")),
              const Center(child: Text("Upload nhạc")),
            ],
          ),
        ),
      ),
    );
  }
}
