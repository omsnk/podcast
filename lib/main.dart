import 'package:flutter/material.dart';
import 'package:podcast/screens/add_podcast.dart';
import 'package:podcast/screens/edit_podcast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/podcast_provider.dart';
import 'screens/list_podcast.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => PodcastProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Podcast List',
      theme: ThemeData(
        textTheme: GoogleFonts.promptTextTheme(),
        inputDecorationTheme: InputDecorationTheme(
          floatingLabelStyle: TextStyle(color: Colors.grey.shade800),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(16),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade800, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          // labelStyle: const TextStyle(color: Colors.grey),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const ListPodcastScreen(),
        AddPodcastScreen.routeName: (context) => const AddPodcastScreen(),
        // EditPodcastScreen.routeName: (context) => const EditPodcastScreen(podcast: ,),
      },
    );
  }
}
