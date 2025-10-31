import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:note1/domain/entities/playlist.dart';
import 'package:note1/pretension/song_player/pages/playlist_detail.dart';
import 'package:note1/services/api_constants.dart';
import 'package:note1/pretension/settings/bloc/settings_cubit.dart';
import 'package:note1/pretension/choose_mode/bloc/theme_cubit.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Playlist> playlists = [];
  bool isLoading = true;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    currentUser = FirebaseAuth.instance.currentUser;
    fetchPlaylists();
  }

  Future<void> fetchPlaylists() async {
    if (currentUser == null) {
      setState(() => isLoading = false);
      return;
    }

    final userId = currentUser!.uid;
    final url = Uri.parse('${ApiConstants.baseUrl}/playlists?user_id=$userId');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success' && data['playlists'] != null) {
          final List<dynamic> list = data['playlists'];
          setState(() {
            playlists
              ..clear()
              ..addAll(list.map((e) => Playlist.fromJson(e)).toList());
          });
        }
      }
    } catch (e) {
      debugPrint('⚠️ fetchPlaylists error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _createPlaylist(String name, bool isPrivate) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/playlists');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'author': user.displayName ?? 'User',
          'user_id': user.uid,
          'is_private': isPrivate ? 1 : 0,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success' && data['playlist'] != null) {
          final newPlaylist = Playlist.fromJson(data['playlist']);
          if (!mounted) return;
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlaylistDetailPage(playlist: newPlaylist),
            ),
          ).then((_) => fetchPlaylists());
        }
      }
    } catch (e) {
      debugPrint('⚠️ _createPlaylist error: $e');
    }
  }

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
            final primaryColor = Theme.of(context).colorScheme.primary;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
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
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "create_playlist".tr,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: nameController,
                      maxLength: 100,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: "enter_playlist_name".tr,
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        counterText: '${nameController.text.trim().length}/100',
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
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "private_setting".tr,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: nameController.text.trim().isEmpty
                            ? null
                            : () async {
                                await _createPlaylist(
                                  nameController.text.trim(),
                                  isPrivate,
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          elevation: 0,
                        ),
                        child: Text(
                          "create_playlist".tr,
                          style: const TextStyle(
                            color: Colors.white,
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
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        final fontSize = _getFontSize(settings.fontSize);

        return BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            final isDark = themeMode == ThemeMode.dark;
            final primaryColor = Theme.of(context).colorScheme.primary;

            return Scaffold(
              backgroundColor: isDark ? Colors.black : const Color(0xFFF9F8FC),
              appBar: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: isDark
                    ? Colors.grey[900]
                    : const Color(0xFFF9F8FC),
                elevation: 0,
                centerTitle: true,
                title: Text(
                  "Library".tr,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize + 6,
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(42),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 12),
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      indicatorColor: primaryColor,
                      dividerColor: Colors.transparent,
                      labelColor: primaryColor,
                      unselectedLabelColor: isDark
                          ? Colors.white70
                          : Colors.grey,
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize,
                      ),
                      unselectedLabelStyle: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: fontSize,
                      ),
                      tabs: [
                        Tab(text: "Playlist".tr),
                        Tab(text: "Album"),
                      ],
                    ),
                  ),
                ),
              ),
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildPlaylistTab(fontSize, isDark, primaryColor),
                  Center(
                    child: Text(
                      "album_in_progress".tr,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontSize: fontSize,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  double _getFontSize(String size) {
    switch (size) {
      case 'small':
        return 14.0;
      case 'large':
        return 20.0;
      default:
        return 16.0;
    }
  }

  Widget _buildPlaylistTab(double fontSize, bool isDark, Color primaryColor) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    final allItems = [null, ...playlists];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        itemCount: allItems.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 34,
          crossAxisSpacing: 30,
          childAspectRatio: 1.1,
        ),
        itemBuilder: (context, index) {
          final playlist = allItems[index];

          if (playlist == null) {
            // Create Playlist button (màu theo chủ đạo)
            return _HoverContainer(
              onTap: _showCreatePlaylistSheet,
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, color: Colors.white, size: 36),
                  const SizedBox(height: 10),
                  Text(
                    "create_playlist".tr,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: fontSize,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Playlist item (giữ layout, dùng màu chủ đạo)
          return _HoverContainer(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlaylistDetailPage(playlist: playlist),
                ),
              ).then((_) => fetchPlaylists());
            },
            gradient: LinearGradient(
              colors: [primaryColor, primaryColor.withOpacity(0.6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            child: Center(
              child: Text(
                playlist.name,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HoverContainer extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Gradient? gradient;

  const _HoverContainer({required this.child, this.onTap, this.gradient});

  @override
  State<_HoverContainer> createState() => _HoverContainerState();
}

class _HoverContainerState extends State<_HoverContainer> {
  bool _isHovered = false;
  static const _animationDuration = Duration(milliseconds: 150);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: _animationDuration,
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(_isHovered ? 24 : 20),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          padding: const EdgeInsets.all(16),
          child: widget.child,
        ),
      ),
    );
  }
}
