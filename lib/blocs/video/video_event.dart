import 'package:equatable/equatable.dart';

abstract class VideoPlaybackEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class InitializeVideos extends VideoPlaybackEvent {}
class StartPlayback extends VideoPlaybackEvent {}
class PausePlayback extends VideoPlaybackEvent {}
class ResumePlayback extends VideoPlaybackEvent {}
class VideoCompleted extends VideoPlaybackEvent {}
class UpdateProgress extends VideoPlaybackEvent {
  final Duration position;
  UpdateProgress(this.position);

  @override
  List<Object?> get props => [position];
}
