import 'package:equatable/equatable.dart';
import 'package:video_player/video_player.dart';

enum PlaybackStatus { initial, loading, playing, paused, completed, error }

class VideoInfo {
  final String title;
  final String path;
  final Duration? duration;
  final Duration pauseAt;

  VideoInfo({
    required this.title,
    required this.path,
    this.duration,
    required this.pauseAt,
  });

  VideoInfo copyWith({Duration? duration}) {
    return VideoInfo(
      title: title,
      path: path,
      duration: duration ?? this.duration,
      pauseAt: pauseAt,
    );
  }
}

class VideoPlaybackState extends Equatable {
  final PlaybackStatus status;
  final List<VideoInfo> videos;
  final int currentVideoIndex;
  final Duration currentPosition;
  final String? errorMessage;
  final VideoPlayerController? controller;
  final int playbackSequence; // Track which sequence we're in

  const VideoPlaybackState({
    this.status = PlaybackStatus.initial,
    this.videos = const [],
    this.currentVideoIndex = 0,
    this.currentPosition = Duration.zero,
    this.errorMessage,
    this.controller,
    this.playbackSequence = 0,
  });

  @override
  List<Object?> get props => [
    status,
    videos,
    currentVideoIndex,
    currentPosition,
    errorMessage,
    controller,
    playbackSequence,
  ];

  VideoPlaybackState copyWith({
    PlaybackStatus? status,
    List<VideoInfo>? videos,
    int? currentVideoIndex,
    Duration? currentPosition,
    String? errorMessage,
    VideoPlayerController? controller,
    int? playbackSequence,
  }) {
    return VideoPlaybackState(
      status: status ?? this.status,
      videos: videos ?? this.videos,
      currentVideoIndex: currentVideoIndex ?? this.currentVideoIndex,
      currentPosition: currentPosition ?? this.currentPosition,
      errorMessage: errorMessage ?? this.errorMessage,
      controller: controller ?? this.controller,
      playbackSequence: playbackSequence ?? this.playbackSequence,
    );
  }
}