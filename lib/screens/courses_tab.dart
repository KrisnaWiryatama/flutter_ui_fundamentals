import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/course.dart';
import '../widgets/course_card.dart';
import 'course_detail_screen.dart';

const String apiUrl = 'https://course-api-pearl.vercel.app/courses';

class CoursesTab extends StatefulWidget {
  final List<Course> courses;

  const CoursesTab({
    super.key,
    required this.courses,
  });

  @override
  State<CoursesTab> createState() => _CoursesTabState();
}

class _CoursesTabState extends State<CoursesTab> {
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        debugPrint('HTTP GET Berhasil: ${data.length} item');

        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetchCourses: $e');

      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showCourseDetailModal(BuildContext context, Course item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.code,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Beban SKS: ${item.credits} SKS | Status: ${item.status}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              const Text(
                'Info singkat dibuka via long press gesture pada kartu materi.',
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Gagal Memuat Data',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: fetchCourses,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daftar Materi Kuliah (v2)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            '• Tap: Detail | Long Press: Modal | Terintegrasi Provider -> Repository -> Service',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: widget.courses.length,
              itemBuilder: (context, index) {
                final Course item = widget.courses[index];
                return CourseCard(
                  item: item,
                  onLongPress: () => _showCourseDetailModal(context, item),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CourseDetailScreen(course: item),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}