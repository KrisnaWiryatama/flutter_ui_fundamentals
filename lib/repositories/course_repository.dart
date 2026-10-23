import '../models/course.dart';
import '../services/course_api_service.dart';

class CourseRepository {
  final CourseApiService apiService;

  CourseRepository(this.apiService);

  // Ambil daftar course langsung dari REST API
  Future<List<Course>> getCourses() {
    return apiService.getCourses();
  }

  // Pertahankan method ini agar home_tab dan profile_tab tidak error
  Future<Map<String, dynamic>> getStudentProfile() async {
    return {
      'name': 'Putu Krisna Wiryatama',
      'nim': '2415051099',
      'prodi': 'Pendidikan Teknik Informatika',
      'semester': 5,
    };
  }
}