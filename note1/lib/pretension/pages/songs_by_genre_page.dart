import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:note1/services/song_service.dart';
import 'package:note1/domain/entities/simple_songs.dart';
import 'package:note1/pretension/home/widgets/playlist_genre.dart';
import 'package:note1/core/configs/assets/app_images.dart';
import 'package:note1/services/api_constants.dart';
import 'package:note1/pretension/settings/bloc/settings_cubit.dart';

final List<String> songImages = [
  AppImages.s1,
  AppImages.s2,
  AppImages.s3,
  AppImages.s4,
  AppImages.s5,
  AppImages.s6,
];

class SongsByGenrePage extends StatefulWidget {
  final String genre;

  const SongsByGenrePage({super.key, required this.genre});

  @override
  State<SongsByGenrePage> createState() => _SongsByGenrePageState();
}

class _SongsByGenrePageState extends State<SongsByGenrePage> {
  final SongService _songService = SongService();
  bool isLoading = true;
  String? errorMessage;
  List<SimpleSong> songs = [];

  final Map<String, String> genreMap = {
    'pop': 'Pop',
    'rock': 'Rock',
    'jazz': 'Jazz',
    'hip-hop': 'Hip Hop',
    'hip hop': 'Hip Hop',
    'hiphop': 'Hip Hop',
    'classical': 'Classical',
  };

  @override
  void initState() {
    super.initState();
    fetchSongsByGenre();
  }

  Future<void> fetchSongsByGenre() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final allSongs = await _songService.fetchSongs();

      final filtered = allSongs.where((song) {
        final genreFromApi = (song['genre'] ?? '').toString().toLowerCase();
        final mappedGenre = genreMap[genreFromApi];
        return mappedGenre != null &&
            mappedGenre.toLowerCase() == widget.genre.toLowerCase();
      }).toList();

      songs = List.generate(filtered.length, (index) {
        final song = filtered[index];
        final url = (song['url'] ?? '').toString();
        final fixedUrl = Uri.encodeFull(
          url.replaceFirst(
            RegExp(r'http://(localhost|10\.0\.2\.2):\d+'),
            ApiConstants.baseUrl,
          ),
        );

        final imageUrl = (song['imageUrl'] ?? '').toString().isNotEmpty
            ? song['imageUrl'].toString()
            : songImages[index % songImages.length];

        return SimpleSong(
          title: song['title'] ?? 'no_title'.tr,
          artist: song['artist'] ?? song['genre'] ?? 'unknown'.tr,
          duration: song['duration'] ?? 0,
          imageUrl: imageUrl,
          audioUrl: fixedUrl,
        );
      });

      setState(() => isLoading = false);
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'error_loading_songs'.trParams({'error': '$e'});
      });
      debugPrint(errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        const accentColors = [
          Colors.blue,
          Colors.green,
          Colors.purple,
          Colors.orange,
        ];

        final accentColor = accentColors[settings.accentIndex];
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Hero(
                tag: 'back_icon_${settings.accentIndex}', // 👈 tránh trùng tag
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? accentColor.withOpacity(0.2)
                            : accentColor.withOpacity(0.15),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: accentColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            title: Text(
              '${'genre'.tr}: ${widget.genre}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: settings.fontSize == 'small'
                    ? 14
                    : settings.fontSize == 'large'
                    ? 20
                    : 16,
                color: accentColor,
              ),
            ),
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : songs.isEmpty
              ? Center(child: Text('no_songs_in_genre'.tr))
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: PlayList(songs: songs),
                ),
        );
      },
    );
  }
}
