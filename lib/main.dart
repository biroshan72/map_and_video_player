import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'blocs/video/video_event.dart';
import 'screens/main_screen.dart';
import 'blocs/map/map_bloc.dart';
import 'blocs/video/video_bloc.dart';
import 'services/baato_service.dart';


void main() async {
  await dotenv.load(fileName: ".env");

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


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

