import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchMusicPage extends StatefulWidget {
  const SearchMusicPage({super.key});

  @override
  State<SearchMusicPage> createState() => _SearchMusicPageState();
}

class _SearchMusicPageState extends State<SearchMusicPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> allSongs = [
    "As It Was - Harry Styles",
    "God Did - DJ Khaled",
    "Heat Waves - Glass Animals",
    "Stay - The Kid LAROI & Justin Bieber",
    "Someone Like You - Adele",
    "Levitating - Dua Lipa",
    "Shape of You - Ed Sheeran",
  ];
  List<String> filteredSongs = [];

  @override
  void initState() {
    super.initState();
    filteredSongs = allSongs;
  }

  void _search(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredSongs = allSongs;
      } else {
        filteredSongs = allSongs
            .where((song) => song.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          onChanged: _search,
          decoration: InputDecoration(
            hintText: "Search songs...".tr,
            border: InputBorder.none,
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: filteredSongs.isEmpty
          ? Center(
              child: Text(
                "No results found".tr,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            )
          : ListView.builder(
              itemCount: filteredSongs.length,
              itemBuilder: (context, index) {
                final song = filteredSongs[index];
                return ListTile(
                  title: Text(
                    song,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                  leading: const Icon(Icons.music_note),
                  onTap: () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Playing: $song")));
                  },
                );
              },
            ),
    );
  }
}
