import 'package:flutter/foundation.dart';
import 'models/course.dart';
import 'repositories/course_repository.dart';

class CourseState extends ChangeNotifier {
  // Poin 4: Provider menerima dan hanya berinteraksi dengan CourseRepository
  final CourseRepository repository;

  CourseState(this.repository);

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

  // Method pemanggilan data mata kuliah lewat repository
  Future<List<Course>> fetchCourses() {
    return repository.getCourses();
  }

  // Method pemanggilan data profil mahasiswa lewat repository
  Future<Map<String, dynamic>> fetchStudentProfile() {
    return repository.getStudentProfile();
  }
}