import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:note1/domain/entities/simple_songs.dart';
import 'package:note1/pretension/song_player/pages/song_player.dart';
import 'package:note1/core/configs/assets/app_images.dart';
import 'package:note1/pretension/search/pages/voice_search_page.dart'; // ✅ import thêm

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

  final List<String> suggestionTags = [
    "anh trai say hi",
    "#zingchart",
    "workout",
    "hôm nay nghe gì",
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // ================= SharedPreferences Recent Search =================
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
        'http://192.168.0.105:8000/api/songs?query=${Uri.encodeQueryComponent(query)}',
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> songs = data['songs'];

        final results = songs.map<SimpleSong>((song) {
          final fullAudioUrl = song['url'] ?? '';
          final title = song['title'] ?? 'Không có tiêu đề';
          return SimpleSong(
            title: title,
            artist: 'Không rõ',
            duration: 200,
            imageUrl: AppImages.b1,
            audioUrl: fullAudioUrl,
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

  // ================= UI Widgets =================
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
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: suggestionTags
                .map((tag) => _buildGradientTag(tag))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientTag(String text) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          final query = text.replaceAll('#', '');
          _searchController.text = query;
          _onSearchChanged();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6A5AE0), Color(0xFFB798F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
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
              MaterialPageRoute(builder: (_) => SongPlayerPage(song: song)),
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
              // Nút Back/Clear
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

              // TextField
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

              // ✅ Nút ghi âm thực sự
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
