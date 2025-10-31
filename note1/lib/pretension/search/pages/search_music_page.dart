import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:note1/domain/entities/simple_songs.dart';
import 'package:note1/pretension/song_player/pages/song_player.dart';
import 'package:note1/core/configs/assets/app_images.dart';
import 'package:note1/pretension/search/pages/voice_search_page.dart';
import 'package:note1/services/api_constants.dart';

class SearchMusicPage extends StatefulWidget {
  const SearchMusicPage({super.key});

  @override
  State<SearchMusicPage> createState() => _SearchMusicPageState();
}

class _SearchMusicPageState extends State<SearchMusicPage> {
  final TextEditingController _searchController = TextEditingController();
  bool isSearching = false;
  bool _isLoading = false;

  static const String _recentSearchesKey = 'recent_music_searches';
  List<Map<String, String>> recentSearches = [];
  List<SimpleSong> searchResults = [];

  // ✅ Danh sách ảnh random
  final List<String> songImages = [
    AppImages.s1,
    AppImages.s2,
    AppImages.s3,
    AppImages.s4,
    AppImages.s5,
    AppImages.s6,
  ];

  // ✅ Tạo ảnh random nếu API không trả ảnh
  String getRandomSongImage() {
    songImages.shuffle();
    return songImages.first;
  }

  // ✅ Gợi ý bài hát
  List<SimpleSong> suggestionSongs = [];
  bool _isSuggestionLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadRecentSearches();
    _fetchSuggestions();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // ================= SharedPreferences =================
  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedList = prefs.getStringList(_recentSearchesKey);
    if (savedList != null) {
      recentSearches = savedList
          .map(
            (item) => {
              "title": item,
              "subtitle": "Đã tìm kiếm",
              "imageUrl": AppImages.b1,
            },
          )
          .toList();
      setState(() {});
    }
  }

  Future<void> _saveRecentSearch(String title) async {
    final prefs = await SharedPreferences.getInstance();

    recentSearches.removeWhere((item) => item['title'] == title);
    recentSearches.insert(0, {
      "title": title,
      "subtitle": "Đã tìm kiếm",
      "imageUrl": AppImages.b1,
    });

    if (recentSearches.length > 10) {
      recentSearches = recentSearches.sublist(0, 10);
    }

    await prefs.setStringList(
      _recentSearchesKey,
      recentSearches.map((e) => e['title']!).toList(),
    );
    setState(() {});
  }

  Future<void> _clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentSearchesKey);
    setState(() => recentSearches.clear());
  }

  // ================= Search Logic =================
  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      if (!isSearching) setState(() => isSearching = true);
      _fetchSearchResults(query);
    } else {
      if (isSearching) {
        setState(() {
          isSearching = false;
          searchResults = [];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchSearchResults(String query) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      searchResults = [];
    });

    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/songs?query=${Uri.encodeQueryComponent(query)}',
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> songs = data['songs'];

        final results = songs.map<SimpleSong>((song) {
          return SimpleSong(
            title: song['title'] ?? 'Không có tiêu đề',
            artist: song['artist'] ?? 'Không rõ',
            duration: song['duration'] ?? 200,
            audioUrl: song['url'] ?? '',

            // ✅ RANDOM ảnh nếu API không có
            imageUrl:
                (song['imageUrl'] != null &&
                    song['imageUrl'].toString().isNotEmpty)
                ? song['imageUrl']
                : getRandomSongImage(),
          );
        }).toList();

        if (mounted) {
          setState(() {
            searchResults = results;
            _isLoading = false;
          });

          if (results.isNotEmpty) _saveRecentSearch(query);
        }
      } else {
        setState(() {
          searchResults = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        searchResults = [];
        _isLoading = false;
      });
      debugPrint('Lỗi gọi API tìm kiếm: $e');
    }
  }

  // ================= API: Gợi ý =================
  Future<void> _fetchSuggestions() async {
    setState(() => _isSuggestionLoading = true);

    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/songs/suggestions');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> songs = data['suggested_songs'] ?? [];

        setState(() {
          suggestionSongs = songs.map<SimpleSong>((song) {
            return SimpleSong(
              title: song['title'] ?? 'Không có tiêu đề',
              artist: song['artist'] ?? 'Không rõ nghệ sĩ',
              duration: song['duration'] ?? 200,
              audioUrl: song['url'] ?? '',

              // ✅ RANDOM ảnh nếu thiếu
              imageUrl:
                  (song['imageUrl'] != null &&
                      song['imageUrl'].toString().isNotEmpty)
                  ? song['imageUrl']
                  : getRandomSongImage(),
            );
          }).toList();
        });
      }
    } catch (e) {
      debugPrint('Lỗi tải gợi ý bài hát: $e');
    } finally {
      setState(() => _isSuggestionLoading = false);
    }
  }

  // ================= UI =================
  Widget _buildSuggestionTags() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Đề xuất cho bạn",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          if (_isSuggestionLoading)
            const Center(child: CircularProgressIndicator())
          else if (suggestionSongs.isEmpty)
            const Text("Không có bài hát gợi ý.")
          else
            Column(
              children: suggestionSongs.map((song) {
                return ListTile(
                  leading: song.imageUrl.startsWith('http')
                      ? Image.network(
                          song.imageUrl,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          song.imageUrl,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                  title: Text(song.title),
                  subtitle: Text(song.artist),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SongPlayerPage(
                          playlist: suggestionSongs,
                          initialIndex: suggestionSongs.indexOf(song),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches() {
    if (recentSearches.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Tìm kiếm gần đây",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: _clearRecentSearches,
                child: const Text(
                  "XÓA",
                  style: TextStyle(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...recentSearches.map((item) {
          return ListTile(
            leading: Image.asset(
              item['imageUrl']!,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
            title: Text(item['title']!),
            subtitle: const Text("Đã tìm kiếm"),
            onTap: () {
              _searchController.text = item['title']!;
              _onSearchChanged();
            },
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.blue));
    }

    if (searchResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'Không tìm thấy kết quả cho "${_searchController.text}"',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final song = searchResults[index];
        return ListTile(
          leading: song.imageUrl.startsWith('http')
              ? Image.network(
                  song.imageUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                )
              : Image.asset(
                  song.imageUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
          title: Text(song.title),
          subtitle: Text(song.artist),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SongPlayerPage(
                  playlist: searchResults,
                  initialIndex: index,
                ),
              ),
            );
            _saveRecentSearch(song.title);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    void handleBackPress() {
      if (_searchController.text.isNotEmpty) {
        _searchController.clear();
        _onSearchChanged();
        FocusScope.of(context).unfocus();
      } else {
        Navigator.pop(context);
      }
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        toolbarHeight: 64,
        title: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 40,
          decoration: BoxDecoration(
            color: _searchController.text.isEmpty
                ? Colors.grey.shade100
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              if (_searchController.text.isNotEmpty)
                BoxShadow(
                  color: Colors.grey.shade400,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: handleBackPress,
                icon: Icon(
                  _searchController.text.isNotEmpty
                      ? Icons.close
                      : Icons.chevron_left,
                  color: Colors.black,
                  size: 28,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    hintText: "Tìm kiếm bài hát, nghệ sĩ",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) _onSearchChanged();
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.mic, color: Colors.deepPurple),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const VoiceSearchPage()),
                  );
                  if (result != null && result is String && result.isNotEmpty) {
                    _searchController.text = result;
                    _onSearchChanged();
                  }
                },
              ),
            ],
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: isSearching
            ? _buildSearchResults()
            : ListView(
                children: [_buildSuggestionTags(), _buildRecentSearches()],
              ),
      ),
    );
  }
}
