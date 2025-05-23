import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_and_video_player/screens/video_play_back_screen.dart';
import 'blocs/video/video_event.dart';
import 'screens/main_screen.dart';
import 'blocs/map/map_bloc.dart';
import 'blocs/video/video_bloc.dart';
import 'services/baato_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => MapBloc(BaatoService()),
        ),
        BlocProvider(
          create: (context) => VideoPlaybackBloc()..add(InitializeVideos()),
        )
      ],
      child:  MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Baato Maps Video Player',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: MainScreen(),
      ),
    );
  }
}

