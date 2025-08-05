# Video Components for Sign Language Learning App

This document provides comprehensive documentation for the advanced video module UI components designed for the sign language learning application.

## Overview

The video module consists of three main components:

1. **AdvancedVideoPlayer** - Full-featured video player with advanced controls
2. **SimpleVideoPlayer** - Basic video player for simple use cases
3. **VideoLessonScreen** - Complete video lesson experience with progress tracking

## Features

### 🎥 Advanced Video Player Features

- **Custom Controls**: Beautiful, intuitive video controls with smooth animations
- **Progress Tracking**: Real-time progress updates and completion callbacks
- **Quality Selection**: Support for multiple video quality options
- **Playback Speed**: Adjustable playback speed (0.25x to 2.0x)
- **Volume Control**: Precise volume control with mute functionality
- **Fullscreen Support**: Seamless fullscreen mode with orientation handling
- **Subtitles Support**: Built-in subtitle display capabilities
- **Error Handling**: Comprehensive error handling with retry functionality
- **Buffering Indicators**: Visual feedback during video buffering
- **Auto-hide Controls**: Controls automatically hide during playback
- **Seek Controls**: 10-second forward/backward seek buttons
- **Wakelock**: Prevents device sleep during video playback

### 🎬 Simple Video Player Features

- **Essential Controls**: Basic play/pause, seek, and fullscreen controls
- **Auto-play Support**: Configurable auto-play functionality
- **Looping**: Option to loop videos
- **Error Handling**: Basic error handling with retry option
- **Lightweight**: Minimal overhead for performance-critical scenarios

### 📱 Video Lesson Screen Features

- **Progress Tracking**: Visual progress indicators and completion status
- **Lesson Information**: Detailed lesson metadata display
- **Related Lessons**: Suggestions for additional learning content
- **Completion Dialog**: Celebration dialog when lessons are completed
- **Responsive Design**: Adapts to different screen sizes and orientations
- **Smooth Animations**: Elegant transitions and micro-interactions

## Installation

### Dependencies

Add the following dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  video_player: ^2.8.1
  chewie: ^1.7.4
  wakelock_plus: ^1.1.4
```

### Platform Configuration

#### Android
Add the following permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
```

#### iOS
Add the following to `ios/Runner/Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## Usage Examples

### Basic Advanced Video Player

```dart
import 'package:flutter/material.dart';
import 'package:your_app/src/presentation/widgets/advanced_video_player.dart';

class MyVideoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Video Lesson')),
      body: AspectRatio(
        aspectRatio: 16 / 9,
        child: AdvancedVideoPlayer(
          videoUrl: 'https://example.com/video.mp4',
          title: 'Basic Sign Language Lesson',
          subtitle: 'Learn the fundamentals',
          autoPlay: false,
          enableFullscreen: true,
          enableQualitySelection: true,
          enablePlaybackSpeed: true,
          enableSubtitles: true,
          onVideoComplete: () {
            print('Video completed!');
          },
          onVideoError: () {
            print('Video error occurred');
          },
          onProgressUpdate: (progress) {
            print('Progress: ${progress.inSeconds} seconds');
          },
        ),
      ),
    );
  }
}
```

### Simple Video Player

```dart
import 'package:flutter/material.dart';
import 'package:your_app/src/presentation/widgets/simple_video_player.dart';

class SimpleVideoExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: SimpleVideoPlayer(
        videoUrl: 'https://example.com/demo.mp4',
        title: 'Quick Demo',
        autoPlay: false,
        looping: false,
        showControls: true,
        allowFullScreen: true,
        onVideoComplete: () {
          print('Video completed!');
        },
      ),
    );
  }
}
```

### Complete Video Lesson Screen

```dart
import 'package:flutter/material.dart';
import 'package:your_app/src/presentation/screens/video_lesson_screen.dart';

class LessonNavigationExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => VideoLessonScreen(
              videoUrl: 'https://example.com/lesson.mp4',
              title: 'Complete Sign Language Lesson',
              subtitle: 'Master the basics',
              description: 'This comprehensive lesson covers fundamental signs...',
              thumbnailUrl: 'https://example.com/thumbnail.jpg',
              relatedLessons: [
                {
                  'title': 'Greetings in Sign Language',
                  'subtitle': 'Learn how to greet people',
                },
                {
                  'title': 'Numbers and Counting',
                  'subtitle': 'Master number signs',
                },
              ],
            ),
          ),
        );
      },
      child: Text('Start Lesson'),
    );
  }
}
```

## Component Properties

### AdvancedVideoPlayer Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `videoUrl` | `String` | Required | URL of the video to play |
| `title` | `String?` | null | Video title displayed in controls |
| `subtitle` | `String?` | null | Video subtitle |
| `thumbnailUrl` | `String?` | null | Thumbnail image URL |
| `autoPlay` | `bool` | false | Whether to start playing automatically |
| `showControls` | `bool` | true | Whether to show custom controls |
| `enableFullscreen` | `bool` | true | Whether to allow fullscreen mode |
| `enableQualitySelection` | `bool` | true | Whether to show quality selection |
| `enablePlaybackSpeed` | `bool` | true | Whether to allow speed adjustment |
| `enableSubtitles` | `bool` | true | Whether to enable subtitle support |
| `subtitles` | `Map<String, String>?` | null | Subtitle tracks |
| `startAt` | `Duration?` | null | Position to start playback from |
| `onVideoComplete` | `VoidCallback?` | null | Called when video completes |
| `onVideoError` | `VoidCallback?` | null | Called when video error occurs |
| `onProgressUpdate` | `Function(Duration)?` | null | Called with progress updates |

### SimpleVideoPlayer Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `videoUrl` | `String` | Required | URL of the video to play |
| `title` | `String?` | null | Video title |
| `autoPlay` | `bool` | false | Whether to start playing automatically |
| `looping` | `bool` | false | Whether to loop the video |
| `showControls` | `bool` | true | Whether to show controls |
| `allowFullScreen` | `bool` | true | Whether to allow fullscreen |
| `onVideoComplete` | `VoidCallback?` | null | Called when video completes |
| `onVideoError` | `VoidCallback?` | null | Called when video error occurs |

### VideoLessonScreen Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `videoUrl` | `String` | Required | URL of the video to play |
| `title` | `String` | Required | Lesson title |
| `subtitle` | `String?` | null | Lesson subtitle |
| `description` | `String?` | null | Lesson description |
| `thumbnailUrl` | `String?` | null | Lesson thumbnail |
| `relatedLessons` | `List<Map<String, dynamic>>?` | null | Related lesson suggestions |
| `startAt` | `Duration?` | null | Position to start playback from |

## Best Practices

### Performance Optimization

1. **Use SimpleVideoPlayer** for basic video playback needs
2. **Implement video caching** for frequently accessed content
3. **Optimize video formats** (H.264 for compatibility)
4. **Consider bandwidth** when selecting video quality
5. **Preload videos** for better user experience

### User Experience

1. **Provide loading states** while videos initialize
2. **Handle errors gracefully** with retry options
3. **Save progress** for long videos
4. **Use appropriate aspect ratios** (16:9 recommended)
5. **Test on different devices** and screen sizes

### Accessibility

1. **Provide captions** for hearing-impaired users
2. **Use semantic labels** for screen readers
3. **Ensure keyboard navigation** support
4. **Maintain color contrast** in controls
5. **Support high contrast modes**

## Customization

### Theming

The video components automatically adapt to your app's theme using `Theme.of(context)`. Key theme properties used:

- `colorScheme.primary` - Progress bar and control colors
- `colorScheme.surface` - Background colors
- `colorScheme.onSurface` - Text colors
- `colorScheme.surfaceVariant` - Secondary background colors

### Custom Controls

You can customize the appearance of controls by modifying the theme or creating custom control widgets. The components use standard Flutter widgets and can be easily styled.

### Error Handling

Both video players include built-in error handling with retry functionality. You can customize error messages and retry behavior by implementing the `onVideoError` callback.

## Troubleshooting

### Common Issues

1. **Video not playing**: Check internet connection and video URL
2. **Controls not showing**: Ensure `showControls` is true
3. **Fullscreen not working**: Verify platform permissions
4. **Performance issues**: Use SimpleVideoPlayer for basic needs

### Debug Tips

1. **Check console logs** for error messages
2. **Verify video format** compatibility
3. **Test with different video URLs**
4. **Monitor memory usage** during playback

## Contributing

When contributing to the video components:

1. **Maintain backward compatibility**
2. **Add comprehensive tests**
3. **Update documentation**
4. **Follow Flutter best practices**
5. **Test on multiple platforms**

## License

This video module is part of the sign language learning app and follows the same license terms as the main project.

---

For more information, see the example usage file: `lib/src/presentation/widgets/video_components_usage.dart` 