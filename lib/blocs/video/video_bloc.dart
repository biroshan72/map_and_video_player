import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_and_video_player/blocs/video/video_event.dart';
import 'package:map_and_video_player/blocs/video/video_state.dart';
import 'package:video_player/video_player.dart';

class VideoPlaybackBloc extends Bloc<VideoPlaybackEvent, VideoPlaybackState> {
  VideoPlayerController? _currentController;

  VideoPlaybackBloc() : super(const VideoPlaybackState()) {
    on<InitializeVideos>(_onInitializeVideos);
    on<StartPlayback>(_onStartPlayback);
    on<PausePlayback>(_onPausePlayback);
    on<ResumePlayback>(_onResumePlayback);
    on<VideoCompleted>(_onVideoCompleted);
    on<UpdateProgress>(_onUpdateProgress);
  }

  Future<void> _onInitializeVideos(
      InitializeVideos event,
      Emitter<VideoPlaybackState> emit,
      ) async {
    emit(state.copyWith(status: PlaybackStatus.loading));

    try {
      // In a real app, these would be actual file paths from local storage
      final videos = [
        VideoInfo(
          title: "First Video",
          path: "assets/videos/video1.mp4", // Replace with actual local path
          pauseAt: const Duration(seconds: 15),
        ),
        VideoInfo(
          title: "Second Video",
          path: "assets/videos/video2.mp4", // Replace with actual local path
          pauseAt: const Duration(seconds: 20),
        ),
        VideoInfo(
          title: "Third Video",
          path: "assets/videos/video3.mp4", // Replace with actual local path
          pauseAt: Duration.zero, // No pause for third video
        ),
      ];

      emit(state.copyWith(
        status: PlaybackStatus.initial,
        videos: videos,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PlaybackStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onStartPlayback(
      StartPlayback event,
      Emitter<VideoPlaybackState> emit,
      ) async {
    if (state.videos.isEmpty) return;

    await _initializeController(0, emit);
  }

  Future<void> _initializeController(
      int videoIndex,
      Emitter<VideoPlaybackState> emit,
      ) async {
    try {
      await _currentController?.dispose();

      final videoPath = state.videos[videoIndex].path;

      // For local files, use VideoPlayerController.file()
      // For assets, use VideoPlayerController.asset()
      _currentController = VideoPlayerController.asset(videoPath);

      await _currentController!.initialize();

      final updatedVideos = List<VideoInfo>.from(state.videos);
      updatedVideos[videoIndex] = updatedVideos[videoIndex].copyWith(
        duration: _currentController!.value.duration,
      );

      emit(state.copyWith(
        status: PlaybackStatus.playing,
        currentVideoIndex: videoIndex,
        controller: _currentController,
        videos: updatedVideos,
        currentPosition: Duration.zero,
      ));

      _currentController!.addListener(() {
        if (_currentController!.value.position != Duration.zero) {
          add(UpdateProgress(_currentController!.value.position));
        }

        if (_currentController!.value.position >= _currentController!.value.duration) {
          add(VideoCompleted());
        }
      });

      await _currentController!.play();
    } catch (e) {
      emit(state.copyWith(
        status: PlaybackStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onPausePlayback(
      PausePlayback event,
      Emitter<VideoPlaybackState> emit,
      ) async {
    await _currentController?.pause();
    emit(state.copyWith(status: PlaybackStatus.paused));
  }

  Future<void> _onResumePlayback(
      ResumePlayback event,
      Emitter<VideoPlaybackState> emit,
      ) async {
    await _currentController?.play();
    emit(state.copyWith(status: PlaybackStatus.playing));
  }

  Future<void> _onVideoCompleted(
      VideoCompleted event,
      Emitter<VideoPlaybackState> emit,
      ) async {
    final currentIndex = state.currentVideoIndex;
    final sequence = state.playbackSequence;

    // Complex sequence logic
    if (sequence == 0) {
      // First sequence: video1 -> video2 -> video3
      if (currentIndex == 2) {
        // Third video completed, move to sequence 1 (restart second video)
        emit(state.copyWith(playbackSequence: 1));
        await _initializeController(1, emit);
      } else {
        // Move to next video in sequence
        await _initializeController(currentIndex + 1, emit);
      }
    } else if (sequence == 1) {
      // Second sequence: video2 completed, resume video1
      emit(state.copyWith(playbackSequence: 2));
      await _initializeController(0, emit);
      // Resume from where it was paused (15 seconds)
      await _currentController?.seekTo(const Duration(seconds: 15));
    } else if (sequence == 2) {
      // Final sequence: video1 completed
      emit(state.copyWith(status: PlaybackStatus.completed));
    }
  }

  Future<void> _onUpdateProgress(
      UpdateProgress event,
      Emitter<VideoPlaybackState> emit,
      ) async {
    final currentVideo = state.videos[state.currentVideoIndex];
    final pauseTime = currentVideo.pauseAt;

    emit(state.copyWith(currentPosition: event.position));

    // Check if we need to pause at specific time
    if (pauseTime > Duration.zero &&
        event.position >= pauseTime &&
        state.status == PlaybackStatus.playing &&
        state.playbackSequence == 0) {

      await _currentController?.pause();
      emit(state.copyWith(status: PlaybackStatus.paused));

      // Auto-resume after a short delay or move to next video
      await Future.delayed(const Duration(milliseconds: 500));

      if (state.currentVideoIndex < 2) {
        await _initializeController(state.currentVideoIndex + 1, emit);
      }
    }
  }

  @override
  Future<void> close() {
    _currentController?.dispose();
    return super.close();
  }
}