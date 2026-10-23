import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/course_api_service.dart';
import 'repositories/course_repository.dart';
import 'providers/course_provider.dart';
import 'screens/main_shell_screen.dart';

void main() {
  const String apiBaseUrl = 'https://course-api-pearl.vercel.app';
  
  final apiService = CourseApiService(apiBaseUrl);
  final repository = CourseRepository(apiService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CourseProvider(repository)..loadCourses(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Course Explorer v2',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainShellScreen(),
    );
  }
}