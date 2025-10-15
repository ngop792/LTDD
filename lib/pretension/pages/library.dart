import 'package:flutter/material.dart';
import 'package:note1/domain/entities/playlist.dart';
import 'package:note1/pretension/song_player/pages/playlist_detail.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Playlist> playlists = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // ✅ Hộp thoại tạo playlist mới
  void _showCreatePlaylistSheet() {
    final TextEditingController nameController = TextEditingController();
    bool isPrivate = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Tạo playlist mới",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.black),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: nameController,
                      maxLength: 100,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: "Nhập tên playlist",
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        counterText: "0/100",
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      onChanged: (_) => setModalState(() {}),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () =>
                              setModalState(() => isPrivate = !isPrivate),
                          child: Icon(
                            isPrivate
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Cài đặt riêng tư",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: nameController.text.trim().isEmpty
                            ? null
                            : () {
                                final playlist = Playlist(
                                  id: DateTime.now().millisecondsSinceEpoch
                                      .toString(),
                                  name: nameController.text.trim(),
                                );
                                setState(() => playlists.add(playlist));
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        PlaylistDetailPage(playlist: playlist),
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: nameController.text.trim().isEmpty
                              ? Colors.grey.shade300
                              : Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          elevation: 0,
                        ),
                        child: Text(
                          "Tạo playlist",
                          style: TextStyle(
                            color: nameController.text.trim().isEmpty
                                ? Colors.grey.shade600
                                : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8FC),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF9F8FC),
        elevation: 0,
        centerTitle: true, // ✅ Giữ chữ "Thư viện" ở giữa
        title: const Text(
          "Thư viện",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(42),
          child: Container(
            alignment: Alignment.centerLeft, // ✅ Căn trái cho TabBar
            padding: const EdgeInsets.only(left: 12), // cách trái nhẹ
            child: TabBar(
              controller: _tabController,
              isScrollable: true, // ✅ Giúp sát nhau
              tabAlignment: TabAlignment.start, // ✅ Flutter 3.16+
              labelPadding: const EdgeInsets.symmetric(
                horizontal: 8,
              ), // ✅ Rất sát
              indicatorColor: Colors.transparent,
              dividerColor: Colors.transparent,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
              tabs: const [
                Tab(text: "Playlist"),
                Tab(text: "Album"),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPlaylistTab(),
          const Center(child: Text("Album (đang phát triển)")),
        ],
      ),
    );
  }

  // --- Danh sách playlist ---
  Widget _buildPlaylistTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        itemCount: playlists.length + 1,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 34,
          crossAxisSpacing: 30,
          childAspectRatio: 1.1,
        ),
        itemBuilder: (context, index) {
          if (index == 0) {
            return GestureDetector(
              onTap: _showCreatePlaylistSheet,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: const Offset(1, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 36, color: Colors.black54),
                      SizedBox(height: 8),
                      Text(
                        "Tạo playlist",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final playlist = playlists[index - 1];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlaylistDetailPage(playlist: playlist),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF6A5AE0), Color(0xFFB798F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(2, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  playlist.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
