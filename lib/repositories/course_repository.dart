import '../constants/app_constants.dart';
import '../models/course.dart';
import '../services/course_api_service.dart';

class CourseRepository {
  final CourseApiService apiService;

  CourseRepository(this.apiService);

  Future<List<Course>> getCourses() {
    return apiService.getCourses();
  }

  Future<Course> createCourse(Course course) {
    return apiService.createCourse(course);
  }

  // Teruskan pembaruan course
  Future<void> updateCourse(int id, Course course) {
    return apiService.updateCourse(id, course);
  }

  Future<Map<String, dynamic>> getStudentProfile() async {
    return {
      'name': studentName,
      'nim': studentId,
      'program': 'Pendidikan Teknik Informatika',
      'semester': 5,
      'track': 'Mobile Application Development',
    };
  }
}