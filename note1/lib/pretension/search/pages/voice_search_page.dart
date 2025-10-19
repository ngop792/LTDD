// voice_search_page.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceSearchPage extends StatefulWidget {
  const VoiceSearchPage({super.key});

  @override
  State<VoiceSearchPage> createState() => _VoiceSearchPageState();
}

class _VoiceSearchPageState extends State<VoiceSearchPage>
    with SingleTickerProviderStateMixin {
  final SpeechToText _speechToText = SpeechToText();

  // Giữ nguyên logic kết quả
  String _lastWords = 'Bấm micro và thử nói...';
  bool _speechInitialized = false;
  bool _listeningStarted = false;

  // Sound level (được cập nhật từ plugin)
  double _soundLevel = 0.0; // 0.0 .. ~30.0 (tùy plugin/device)

  // Animation controller cho ripple waves
  late AnimationController _rippleController;

  // Timer để auto-hide waves khi dừng
  Timer? _waveFadeTimer;

  @override
  void initState() {
    super.initState();
    _initSpeech();

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(); // repeat để waves liên tục
  }

  @override
  void dispose() {
    _waveFadeTimer?.cancel();
    _rippleController.dispose();
    _speechToText.stop();
    super.dispose();
  }

  // Giữ nguyên popWithResult như bạn muốn
  void _popWithResult(bool forceEmpty) {
    if (!mounted) return;
    String result = _lastWords.replaceAll('"', '').trim();

    if (forceEmpty ||
        result == 'Thử nói...' ||
        result == 'Đang lắng nghe...' ||
        result == 'Bấm micro và thử nói...' ||
        result.contains('Không thể mở Micro') ||
        result.contains('Không thể khởi tạo dịch vụ giọng nói.')) {
      result = "";
    }

    Navigator.pop(context, result);
  }

  // Reset UI (không đóng trang)
  void _stopListeningAndResetUI() {
    if (_speechToText.isListening) {
      _speechToText.stop();
    }

    // Khi dừng, giảm dần âm lượng hiển thị
    _startWaveFadeOut();

    if (mounted) {
      setState(() {
        _listeningStarted = false;
        _soundLevel = 0.0;
        _lastWords = _speechToText.isAvailable
            ? 'Bấm micro và thử nói...'
            : 'Không thể khởi tạo dịch vụ giọng nói.';
      });
    }
  }

  void _startWaveFadeOut() {
    // nếu có timer trước thì huỷ
    _waveFadeTimer?.cancel();
    // tạo timer để tắt ripple sau 700ms
    _waveFadeTimer = Timer(const Duration(milliseconds: 700), () {
      if (mounted)
        setState(() {
          _soundLevel = 0.0;
        });
    });
  }

  // Khởi tạo speech
  Future<void> _initSpeech() async {
    bool isEnabled = await _speechToText.initialize(
      onError: (e) {
        // Bạn có thể log e
        // Trường hợp lỗi nặng, đóng trang trả về rỗng
        _popWithResult(true);
      },
      onStatus: (status) {
        // Nếu status chuyển thành notListening sau khi đang lắng nghe:
        if (status == 'notListening' && _listeningStarted && mounted) {
          _stopListeningAndResetUI();
          // Nếu bạn muốn đóng trang tự động khi nói xong, bạn có thể gọi:
          // _popWithResult(false);
        }
      },
    );

    if (mounted) {
      setState(() {
        _speechInitialized = isEnabled;
        if (!isEnabled) {
          _lastWords = 'Không thể khởi tạo dịch vụ giọng nói.';
        }
      });
    }
  }

  // Bắt đầu lắng nghe, truyền onSoundLevelChange để lấy sound level
  Future<void> _startListening() async {
    if (!_speechInitialized) return;

    try {
      if (mounted) {
        setState(() {
          _listeningStarted = true;
          _lastWords = 'Đang lắng nghe...';
        });
      }

      await _speechToText.listen(
        onResult: _onSpeechResult,
        localeId: 'vi_VN',
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 1),
        onSoundLevelChange: _onSoundLevelChange,
        cancelOnError: true,
      );
    } catch (e) {
      // xử lý lỗi khi mở mic
      if (mounted) {
        setState(() {
          _listeningStarted = false;
          _lastWords = 'Không thể mở Micro, vui lòng kiểm tra quyền truy cập.';
        });
      }
    }
  }

  // Handler sound level
  void _onSoundLevelChange(double level) {
    // level thường ~ 0.0..30.0 tuỳ platform/plugin/device
    if (mounted) {
      setState(() {
        // clamp để không lớn quá
        _soundLevel = level.clamp(0.0, 30.0);
      });
    }
  }

  void _handleMicrophoneButton() {
    final bool isListening = _speechToText.isListening || _listeningStarted;

    if (isListening) {
      _stopListeningAndResetUI();
    } else {
      if (_speechInitialized) _startListening();
    }
  }

  // Xử lý kết quả
  void _onSpeechResult(result) {
    if (mounted) {
      setState(() {
        _lastWords = '"${result.recognizedWords}"';
      });
    }
    if (result.finalResult) {
      // Khi final -> dừng và trở về UI gợi ý
      _stopListeningAndResetUI();
    }
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    final bool showListeningUI = _speechToText.isListening || _listeningStarted;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Close button top-left
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => _popWithResult(true),
              ),
            ),

            const SizedBox(height: 34),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: showListeningUI
                  ? _buildListeningHeader()
                  : _buildIdleHeader(),
            ),

            const Spacer(),

            // Waves + Mic button
            SizedBox(
              height: 220,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Ripples: nhiều vòng, giá trị radius dựa vào animation & soundLevel
                    AnimatedBuilder(
                      animation: _rippleController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: RipplePainter(
                            progress: _rippleController.value,
                            soundLevel: _soundLevel,
                          ),
                          size: const Size(220, 220),
                        );
                      },
                    ),

                    // Mic button with scale based on sound level
                    GestureDetector(
                      onTap: _speechInitialized
                          ? _handleMicrophoneButton
                          : null,
                      child: Transform.scale(
                        scale: 1.0 + (_soundLevel / 40.0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          width: showListeningUI ? 84 : 72,
                          height: showListeningUI ? 84 : 72,
                          decoration: BoxDecoration(
                            color: showListeningUI
                                ? Colors.blue
                                : Colors.blue.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(
                              showListeningUI ? 16 : 36,
                            ),
                            border: showListeningUI
                                ? null
                                : Border.all(color: Colors.blue, width: 2),
                            boxShadow: showListeningUI
                                ? [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.28),
                                      blurRadius: 18,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : [],
                          ),
                          child: Icon(
                            showListeningUI ? Icons.stop : Icons.mic_none,
                            color: showListeningUI ? Colors.white : Colors.blue,
                            size: showListeningUI ? 36 : 34,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Footer info
            if (!showListeningUI && _speechInitialized)
              const Text(
                'POWERED BY ZALO AI',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  // Header khi đang lắng nghe
  Widget _buildListeningHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thử nói...',
          style: TextStyle(
            fontSize: 20,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
            color: _lastWords.contains('Không thể mở Micro')
                ? Colors.red
                : Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          // Nếu vẫn text mặc định "Đang lắng nghe..." thì hiển thị gợi ý "Thử nói..."
          _lastWords.replaceAll('Đang lắng nghe...', 'Thử nói...'),
          style: TextStyle(
            fontSize: 20,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w400,
            color: _lastWords.contains('Không thể mở Micro')
                ? Colors.red
                : Colors.blue,
          ),
        ),
      ],
    );
  }

  // Header khi idle (gợi ý)
  Widget _buildIdleHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Bấm micro và thử nói...',
          style: TextStyle(
            fontSize: 20,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 14),
        SuggestionItem(
          icon: Icons.music_note,
          text: 'Mở bài Bấc Bling',
          subtitle: 'Nghe giai điệu bạn yêu thích',
        ),
        SuggestionItem(
          icon: Icons.person,
          text: 'Mở nhạc Quang Hùng',
          subtitle: 'Nghe danh sách hit của nghệ sĩ',
        ),
        SuggestionItem(
          icon: Icons.skip_next,
          text: 'Mở nhạc trữ tình',
          subtitle: 'Chọn thể loại nhạc bất kì',
        ),
      ],
    );
  }
}

// ---------------- RipplePainter: vẽ nhiều vòng ripple ----------------
class RipplePainter extends CustomPainter {
  final double progress; // 0..1
  final double soundLevel; // 0..~30

  RipplePainter({required this.progress, required this.soundLevel});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Map soundLevel -> intensity 0..1
    final intensity = (soundLevel / 30.0).clamp(0.0, 1.0);

    // 3 layers of ripples with different speeds/colors
    final baseRadius = min(size.width, size.height) * 0.18;

    final paints = [
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                Colors.blue.withOpacity(0.12 * (0.8 + intensity * 0.6)),
                Colors.transparent,
              ],
            ).createShader(
              Rect.fromCircle(center: center, radius: size.width * 0.6),
            )
        ..style = PaintingStyle.fill,
      Paint()
        ..color = Colors.blue.withOpacity(0.10 * (0.8 + intensity * 0.6))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
      Paint()
        ..color = Colors.blue.withOpacity(0.08 * (0.8 + intensity * 0.6))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    ];

    for (int i = 0; i < 3; i++) {
      // offsetProgress shifts each layer
      final layerProgress = (progress + i * 0.25) % 1.0;
      final maxExtra = size.width * (0.45 + i * 0.12 + intensity * 0.3);
      final radius = baseRadius + layerProgress * maxExtra + intensity * 12;

      if (i == 0) {
        // filled soft glow
        canvas.drawCircle(center, radius, paints[0]);
      } else {
        canvas.drawCircle(center, radius, paints[i]);
      }
    }
  }

  @override
  bool shouldRepaint(covariant RipplePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.soundLevel != soundLevel;
  }
}

// ---------------- SuggestionItem with ripple ----------------
class SuggestionItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final String subtitle;

  const SuggestionItem({
    required this.icon,
    required this.text,
    required this.subtitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          // Bạn có thể muốn gửi hành động khi bấm gợi ý
          // ví dụ Navigator.pop(context, text) hoặc gửi event
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue.withOpacity(0.10),
                radius: 20,
                child: Icon(icon, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '"$text"',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
