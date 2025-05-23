import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import '../blocs/video/video_bloc.dart';
import '../blocs/video/video_event.dart';
import '../blocs/video/video_state.dart';

class VideoPlaybackScreen extends StatefulWidget {
  const VideoPlaybackScreen({super.key});

  @override
  _VideoPlaybackScreenState createState() => _VideoPlaybackScreenState();
}

class _VideoPlaybackScreenState extends State<VideoPlaybackScreen>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final bloc = context.read<VideoPlaybackBloc>();

    if (state == AppLifecycleState.paused) {
      bloc.add(PausePlayback());
    } else if (state == AppLifecycleState.resumed) {
      bloc.add(ResumePlayback());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        elevation: 0,
      ),
      body: BlocBuilder<VideoPlaybackBloc, VideoPlaybackState>(
        builder: (context, state) {
          if (state.status == PlaybackStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == PlaybackStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.errorMessage}',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<VideoPlaybackBloc>().add(InitializeVideos());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Video Title
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Text(
                  state.videos.isNotEmpty
                      ? state.videos[state.currentVideoIndex].title
                      : 'No Video',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Video Player
              Expanded(
                child: Container(
                  width: double.infinity,
                  child: state.controller != null && state.controller!.value.isInitialized
                      ? AspectRatio(
                    aspectRatio: state.controller!.value.aspectRatio,
                    child: VideoPlayer(state.controller!),
                  )
                      : const Center(
                    child: Text(
                      'No video loaded',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),

              // Progress Indicators for all videos
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: state.videos.asMap().entries.map((entry) {
                    final index = entry.key;
                    final video = entry.value;
                    final isActive = index == state.currentVideoIndex;
                    final progress = isActive
                        ? (video.duration != null
                        ? state.currentPosition.inMilliseconds / video.duration!.inMilliseconds
                        : 0.0)
                        : (index < state.currentVideoIndex ? 1.0 : 0.0);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                video.title,
                                style: TextStyle(
                                  color: isActive ? Colors.blue : Colors.white70,
                                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              Text(
                                isActive
                                    ? '${_formatDuration(state.currentPosition)} / ${_formatDuration(video.duration ?? Duration.zero)}'
                                    : _formatDuration(video.duration ?? Duration.zero),
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            backgroundColor: Colors.white24,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isActive ? Colors.blue : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Control Buttons
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (state.status == PlaybackStatus.initial)
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<VideoPlaybackBloc>().add(StartPlayback());
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start'),
                      ),

                    if (state.status == PlaybackStatus.playing)
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<VideoPlaybackBloc>().add(PausePlayback());
                        },
                        icon: const Icon(Icons.pause),
                        label: const Text('Pause'),
                      ),

                    if (state.status == PlaybackStatus.paused)
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<VideoPlaybackBloc>().add(ResumePlayback());
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Resume'),
                      ),

                    if (state.status == PlaybackStatus.completed)
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<VideoPlaybackBloc>().add(StartPlayback());
                        },
                        icon: const Icon(Icons.replay),
                        label: const Text('Replay'),
                      ),
                  ],
                ),
              ),

              // Sequence Indicator
              Container(
                padding: const EdgeInsets.all(8),
                child: Text(
                  'Sequence: ${state.playbackSequence + 1} | Status: ${state.status.name}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
