import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/course.dart';

class CourseService {
  Future<List<Course>> loadCourses() async {
    final jsonString = await rootBundle.loadString(
      'assets/data/student_data.json', // Poin 1: Menggunakan rootBundle untuk membaca file JSON dari assets
    );
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final list = data['courses'] as List<dynamic>;
    return list
        .map((e) => Course.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> loadStudentProfile() async {
    final jsonString = await rootBundle.loadString(
      'assets/data/student_data.json',
    );
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    return data['student'] as Map<String, dynamic>;
  }
}