import 'package:flutter/material.dart';
import 'package:note1/domain/entities/simple_songs.dart';
import 'package:note1/core/configs/theme/app_colors.dart';
import 'package:note1/pretension/song_player/pages/song_player.dart';

final List<SimpleSong> dummySongs = [
  SimpleSong(
    title: "lovely",
    artist: "Billie Eilish , Khalid",
    duration: 200,
    imageUrl: "assets/images/song_1.png",
  ),
  SimpleSong(
    title: "One Kiss",
    artist: "Calvin Harris , Dua Lipa",
    duration: 210,
    imageUrl: "assets/images/song_2.png",
  ),
  SimpleSong(
    title: "Banner song",
    artist: "Unknown Artist",
    duration: 180,
    imageUrl: "assets/images/song_3.png",
  ),
  SimpleSong(
    title: "Shape Of You",
    artist: "Unknown Artist",
    duration: 180,
    imageUrl: "assets/images/song_4.png",
  ),
  SimpleSong(
    title: "Tonight",
    artist: "Unknown Artist",
    duration: 180,
    imageUrl: "assets/images/song_5.png",
  ),
  SimpleSong(
    title: "Dinamond",
    artist: "Unknown Artist",
    duration: 180,
    imageUrl: "assets/images/song_6.png",
  ),
];

class NewsSongs extends StatelessWidget {
  const NewsSongs({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dummySongs.length,
        itemBuilder: (context, index) {
          final song = dummySongs[index];
          return _SongCard(song: song);
        },
      ),
    );
  }
}

class _SongCard extends StatefulWidget {
  final SimpleSong song;
  const _SongCard({required this.song, super.key});

  @override
  State<_SongCard> createState() => _SongCardState();
}

class _SongCardState extends State<_SongCard> {
  double _scale = 1.0;

  void _openPlayer() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SongPlayerPage(song: widget.song)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: _openPlayer,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 155,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      widget.song.imageUrl,
                      fit: BoxFit.cover,
                      width: 150,
                      height: 155,
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: AnimatedScale(
                      scale: _scale,
                      duration: const Duration(milliseconds: 150),
                      child: Material(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkGrey
                            : const Color(0xffE6E6E6),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          splashColor: Colors.black26,
                          onTap: _openPlayer,
                          onTapDown: (_) => setState(() => _scale = 0.85),
                          onTapCancel: () => setState(() => _scale = 1.0),
                          onTapUp: (_) => setState(() => _scale = 1.0),
                          child: const SizedBox(
                            height: 40,
                            width: 40,
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: Color(0xff959595),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.song.title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              widget.song.artist,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
