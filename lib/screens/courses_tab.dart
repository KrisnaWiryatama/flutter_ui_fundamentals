import 'package:flutter/material.dart';
import '../models/course.dart';
import '../widgets/course_card.dart';
import 'course_detail_screen.dart';

class CoursesTab extends StatelessWidget {
  final List<Course> courses;

  const CoursesTab({
    super.key,
    required this.courses,
  });

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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daftar Materi Kuliah (v2)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '${courses.length} Course',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            '• Tap: Detail | Long Press: Modal | Terintegrasi Provider -> Repository -> Service',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final Course item = courses[index];
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