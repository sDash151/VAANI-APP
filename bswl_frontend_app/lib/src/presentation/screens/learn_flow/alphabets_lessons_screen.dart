import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/page_header.dart';
import '../../widgets/video_lesson_card.dart';
import '../../widgets/advanced_video_player.dart';
import '../../../services/video_asset_service.dart';

class AlphabetsLessonsScreen extends StatelessWidget {
  AlphabetsLessonsScreen({Key? key}) : super(key: key);

  final List<String> lessons = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: 'Alphabets',
                onBackPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.builder(
                  itemCount: lessons.length,
                  itemBuilder: (context, index) {
                    final lesson = lessons[index];

                    return VideoLessonCard(
                      title: lesson,
                      subtitle: 'Tap to watch.',
                      onTap: () async {
                        // Show loading indicator
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Loading video...'),
                            duration: Duration(seconds: 1),
                          ),
                        );

                        final videoPath =
                            await VideoAssetService.getFullVideoPath(lesson);

                        if (videoPath != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VideoLessonScreen(
                                title: 'Alphabet: $lesson',
                                videoUrl: videoPath,
                                onVideoComplete: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Great job learning letter $lesson!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                                onVideoError: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Error loading video. Please try again.'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Video for letter $lesson is coming soon!'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      },
                    )
                        .animate()
                        .fadeIn(duration: 500.ms, delay: (index * 100).ms)
                        .slideY(begin: 0.15);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VideoLessonScreen extends StatefulWidget {
  final String title;
  final String videoUrl;
  final VoidCallback? onVideoComplete;
  final VoidCallback? onVideoError;

  const VideoLessonScreen({
    Key? key,
    required this.title,
    required this.videoUrl,
    this.onVideoComplete,
    this.onVideoError,
  }) : super(key: key);

  @override
  State<VideoLessonScreen> createState() => _VideoLessonScreenState();
}

class _VideoLessonScreenState extends State<VideoLessonScreen> {
  bool _isFullscreen = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _isFullscreen
          ? null
          : AppBar(
              title: Text(
                widget.title,
                style: TextStyle(
                  color: colorScheme.onBackground,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              backgroundColor: colorScheme.background,
              elevation: 0,
              iconTheme: IconThemeData(
                color: colorScheme.onBackground,
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                color: colorScheme.onBackground,
                onPressed: () => Navigator.pop(context),
              ),
            ),
      body: AdvancedVideoPlayer(
        videoUrl: widget.videoUrl,
        title: widget.title,
        autoPlay: false,
        showControls: true,
        enableFullscreen: true,
        enableQualitySelection: true,
        enablePlaybackSpeed: true,
        enableSubtitles: false,
        onVideoComplete: widget.onVideoComplete,
        onVideoError: widget.onVideoError,
        onFullscreenChanged: (isFullscreen) {
          setState(() {
            _isFullscreen = isFullscreen;
          });
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Set system UI overlays for video player
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    // Reset orientation to portrait when leaving the video screen
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }
}
