import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Import VoiceSearchPage (giả định file này nằm cùng cấp hoặc đúng đường dẫn)
import 'package:note1/pretension/search/pages/voice_search_page.dart';

class SearchMusicPage extends StatefulWidget {
  const SearchMusicPage({super.key});

  @override
  State<SearchMusicPage> createState() => _SearchMusicPageState();
}

class _SearchMusicPageState extends State<SearchMusicPage>
    with SingleTickerProviderStateMixin {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = ''; // Biến này không dùng trực tiếp trong page này nữa
  final TextEditingController _searchController = TextEditingController();
  bool isSearching = false;
  bool _isLoading = false;

  static const String _recentSearchesKey = 'recent_music_searches';

  final List<String> suggestionTags = [
    "anh trai say hi",
    "#zingchart",
    "workout",
    "hôm nay nghe gì",
  ];

  List<Map<String, String>> recentSearches = [];
  final GlobalKey<AnimatedListState> _recentListKey =
      GlobalKey<AnimatedListState>();

  List<String> searchResults = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _initSpeech();
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // --- Shared Preferences & AnimatedList Logic (ĐÃ SỬA LỖI HIỂN THỊ) ---
  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedList = prefs.getStringList(_recentSearchesKey);

    if (savedList != null && mounted) {
      final loadedSearches = savedList.map((item) {
        final parts = item.split('|');
        if (parts.length == 3) {
          return {
            "title": parts[0],
            "subtitle": parts[1],
            "imageUrl": parts[2],
          };
        } else {
          return {
            "title": parts[0],
            "subtitle": "Đã tìm kiếm",
            "imageUrl": "assets/default_placeholder.png",
          };
        }
      }).toList();

      // 1. Cập nhật dữ liệu và rebuild widget để AnimatedList được render
      recentSearches = loadedSearches;
      setState(() {});

      // 2. Chờ AnimatedList sẵn sàng rồi thêm từng mục vào AnimatedList
      await Future.microtask(() {});

      if (_recentListKey.currentState != null && recentSearches.isNotEmpty) {
        for (int i = 0; i < recentSearches.length; i++) {
          try {
            _recentListKey.currentState?.insertItem(i);
          } catch (e) {
            break;
          }
        }
      }
    }
  }

  // Logic _saveRecentSearch giữ nguyên vì đã đúng cho AnimatedList

  Future<void> _saveRecentSearch(String title) async {
    final newSearchItem = {
      "title": title,
      "subtitle": "Tìm kiếm mới",
      "imageUrl": "assets/default_placeholder.png",
    };

    int oldIndex = recentSearches.indexWhere((item) => item['title'] == title);
    bool isNewItem = oldIndex == -1;

    // 1. Xóa mục cũ (nếu có)
    if (!isNewItem) {
      final removedItem = recentSearches[oldIndex];
      recentSearches.removeAt(oldIndex);
      _recentListKey.currentState?.removeItem(
        oldIndex,
        (context, animation) => SizeTransition(
          sizeFactor: animation,
          child: _buildRecentSongTile(removedItem, oldIndex),
        ),
        duration: const Duration(milliseconds: 300),
      );
    }

    // 2. Thêm mục mới vào đầu danh sách dữ liệu
    recentSearches.insert(0, newSearchItem);

    // 3. Tạo hiệu ứng thêm mục mới vào đầu AnimatedList
    if (_recentListKey.currentState != null) {
      _recentListKey.currentState!.insertItem(
        0,
        duration: const Duration(milliseconds: 300),
      );
    }

    // 4. Giới hạn 10 mục và xử lý animation xóa mục cuối
    if (recentSearches.length > 10) {
      if (_recentListKey.currentState != null) {
        final removedItem = recentSearches.last;
        _recentListKey.currentState?.removeItem(
          10,
          (context, animation) => SizeTransition(
            sizeFactor: animation,
            child: _buildRecentSongTile(removedItem, 10),
          ),
          duration: const Duration(milliseconds: 300),
        );
      }
      recentSearches = recentSearches.sublist(0, 10);
    }

    // 5. Lưu vào SharedPreferences
    final List<String> stringList = recentSearches
        .map(
          (item) => '${item['title']}|${item['subtitle']}|${item['imageUrl']}',
        )
        .toList();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentSearchesKey, stringList);

    if (mounted) setState(() {});
  }

  Future<void> _clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentSearchesKey);

    final int count = recentSearches.length;
    final List<Map<String, String>> removedItems = List.from(recentSearches);

    setState(() {
      recentSearches.clear();
    });

    for (int i = count - 1; i >= 0; i--) {
      _recentListKey.currentState?.removeItem(i, (context, animation) {
        return SizeTransition(
          sizeFactor: animation,
          child: _buildRecentSongTile(removedItems[i], i),
        );
      }, duration: const Duration(milliseconds: 300));
    }
  }

  // --- Speech & Search Logic ---

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  // Xử lý kết quả trả về từ VoiceSearchPage
  Future<void> _openVoiceSearch() async {
    FocusScope.of(context).unfocus();

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const VoiceSearchPage(),
        fullscreenDialog: true,
      ),
    );

    if (result is String && result.isNotEmpty) {
      _lastWords = result;
      _searchController.text = result;
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: _searchController.text.length),
      );
      _onSearchChanged();
    }
    if (mounted) setState(() {});
  }

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

  void _fetchSearchResults(String query) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      searchResults = [];
    });

    // Sử dụng Placeholder API
    final uri = Uri.parse('https://jsonplaceholder.typicode.com/posts');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final filteredResults = data
            .where(
              (item) =>
                  item['title'].toString().toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  item['body'].toString().toLowerCase().contains(
                    query.toLowerCase(),
                  ),
            )
            .map((item) => item['title'].toString())
            .toList();

        if (mounted) {
          setState(() {
            searchResults = filteredResults;
            _isLoading = false;
          });

          // Lưu mục tìm kiếm chỉ khi có kết quả
          if (filteredResults.isNotEmpty) _saveRecentSearch(query);
        }
      } else {
        if (mounted)
          setState(() {
            searchResults = [];
            _isLoading = false;
          });
      }
    } catch (e) {
      if (mounted)
        setState(() {
          searchResults = [];
          _isLoading = false;
        });
      print('Lỗi gọi API tìm kiếm: $e');
    }
  }

  // --- Widgets ---

  Widget _buildSuggestionTags() {
    // ... (logic không đổi)
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Đề xuất cho bạn",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: suggestionTags
                .map((tag) => _buildGradientTag(tag))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientTag(String text) {
    // ... (logic không đổi)
    return Material(
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          final query = text.replaceAll('#', '');
          _searchController.text = query;
          _searchController.selection = TextSelection.fromPosition(
            TextPosition(offset: _searchController.text.length),
          );
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
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
          // Sửa: Đặt initialItemCount = 0 để quản lý việc thêm bằng insertItem trong _loadRecentSearches
          AnimatedList(
            key: _recentListKey,
            initialItemCount: 0,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index, animation) {
              if (index >= recentSearches.length) {
                return const SizedBox.shrink();
              }
              final item = recentSearches[index];
              return SizeTransition(
                sizeFactor: animation,
                child: _buildRecentSongTile(item, index),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSongTile(Map<String, String> item, int index) {
    // ... (logic không đổi)
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(5.0),
        child: Container(
          width: 40,
          height: 40,
          color: Colors.grey.shade300,
          child: const Icon(Icons.music_note, color: Colors.white, size: 20),
        ),
      ),
      title: Text(item['title']!),
      subtitle: const Row(
        children: [
          Icon(Icons.history, size: 14, color: Colors.grey),
          SizedBox(width: 4),
          Text("Đã tìm kiếm", style: TextStyle(color: Colors.grey)),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.close, color: Colors.grey),
        onPressed: () {
          final removedItem = recentSearches[index];

          _recentListKey.currentState?.removeItem(
            index,
            (context, animation) => SizeTransition(
              sizeFactor: animation,
              child: _buildRecentSongTile(removedItem, index),
            ),
            duration: const Duration(milliseconds: 300),
          );

          setState(() {
            recentSearches.removeAt(index);
          });

          final List<String> stringList = recentSearches
              .map((e) => '${e['title']}|${e['subtitle']}|${e['imageUrl']}')
              .toList();
          SharedPreferences.getInstance().then((prefs) {
            prefs.setStringList(_recentSearchesKey, stringList);
          });
        },
      ),
      onTap: () {
        _searchController.text = item['title']!;
        _searchController.selection = TextSelection.fromPosition(
          TextPosition(offset: _searchController.text.length),
        );
        _onSearchChanged();
      },
    );
  }

  Widget _buildSearchResults() {
    // ... (logic không đổi)
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.blue),
              SizedBox(height: 16),
              Text("Đang tải kết quả tìm kiếm..."),
            ],
          ),
        ),
      );
    }

    if (searchResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'Không tìm thấy kết quả nào cho "${_searchController.text}"',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final song = searchResults[index];
        return TweenAnimationBuilder(
          tween: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero),
          duration: Duration(milliseconds: 200 + index * 50),
          builder: (context, Offset offset, child) {
            return Transform.translate(
              offset: Offset(0, offset.dy * 50),
              child: Opacity(opacity: 1.0 - offset.dy, child: child),
            );
          },
          child: ListTile(
            title: Text(song),
            leading: const Icon(Icons.music_note),
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("Tìm kiếm: $song")));
            },
          ),
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
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: handleBackPress,
              ),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: "Tìm kiếm bài hát, nghệ sĩ".tr,
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 12.0,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface,
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) _onSearchChanged();
                  },
                ),
              ),
              _searchController.text.isEmpty
                  ? AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _speechEnabled
                            ? Colors.blueAccent.withOpacity(0.2)
                            : Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.mic,
                          color: _speechEnabled ? Colors.blue : Colors.grey,
                        ),
                        onPressed: _speechEnabled ? _openVoiceSearch : null,
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged();
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
