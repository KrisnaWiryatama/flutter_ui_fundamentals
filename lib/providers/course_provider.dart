import 'package:flutter/foundation.dart';
import '../models/course.dart';
import '../repositories/course_repository.dart';

class CourseProvider extends ChangeNotifier {
  final CourseRepository repository;

  CourseProvider(this.repository);

  List<Course> courses = [];
  Map<String, dynamic>? student;
  bool isLoading = false;
  String? error;

  final Set<String> favorites = {};

  bool isFavorite(String id) => favorites.contains(id);

  void toggleFavorite(String id) {
    if (favorites.contains(id)) {
      favorites.remove(id);
    } else {
      favorites.add(id);
    }
    notifyListeners();
  }

  int get favoriteCount => favorites.length;

  Future<void> loadCourses() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      courses = await repository.getCourses();
      student = await repository.getStudentProfile();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Aksi membuat course baru dan langsung merefresh daftar course
  Future<void> addCourse(Course newCourse) async {
    await repository.createCourse(newCourse);
    await loadCourses(); // Merefresh list secara utuh
  }
}