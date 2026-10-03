import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

// Identitas Mahasiswa Wajib
const String studentName = 'Putu Krisna Wiryatama';
const String studentId = '2415051099';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learning Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const DashboardShellPage(),
    );
  }
}

class DashboardShellPage extends StatefulWidget {
  const DashboardShellPage({super.key});

  @override
  State<DashboardShellPage> createState() => _DashboardShellPageState();
}

class _DashboardShellPageState extends State<DashboardShellPage> {
  late Future<Map<String, dynamic>> dashboardFuture;

  @override
  void initState() {
    super.initState();
    dashboardFuture = loadStudentData();
  }

  Future<Map<String, dynamic>> loadStudentData() async {
    final jsonString = await rootBundle.loadString('assets/data/student_data.json');
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tahap 3: LayoutBuilder & Breakpoint',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
              ),
            );
          }

          final data = snapshot.data!;
          final student = data['student'] as Map<String, dynamic>;
          final courses = data['courses'] as List<dynamic>;

          // ========================================================
          // IMPLEMENTASI TAHAP 3: LAYOUTBUILDER DENGAN 3 BREAKPOINT
          // ========================================================
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                // Breakpoint Compact (< 600 px)
                return CompactLayout(
                  student: student,
                  courses: courses,
                  maxWidth: constraints.maxWidth,
                );
              } else if (constraints.maxWidth < 840) {
                // Breakpoint Medium (600 - 839 px)
                return MediumLayout(
                  student: student,
                  courses: courses,
                  maxWidth: constraints.maxWidth,
                );
              } else {
                // Breakpoint Expanded (>= 840 px)
                return ExpandedLayout(
                  student: student,
                  courses: courses,
                  maxWidth: constraints.maxWidth,
                );
              }
            },
          );
        },
      ),
    );
  }
}

// =========================================================================
// WIDGET 1: COMPACT LAYOUT (< 600 px) - Kolom tunggal vertikal
// =========================================================================
class CompactLayout extends StatelessWidget {
  final Map<String, dynamic> student;
  final List<dynamic> courses;
  final double maxWidth;

  const CompactLayout({
    super.key,
    required this.student,
    required this.courses,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBanner(
            category: 'Compact (< 600px)',
            color: Colors.orange.shade700,
            icon: Icons.phone_android,
          ),
          const SizedBox(height: 12),
          _buildProfileCard(student),
          const SizedBox(height: 16),
          const Text('Daftar Materi (Vertical List)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: courses.length,
            itemBuilder: (context, index) => _buildCourseCard(courses[index] as Map<String, dynamic>),
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// WIDGET 2: MEDIUM LAYOUT (600 - 839 px) - Grid 2 Kolom
// =========================================================================
class MediumLayout extends StatelessWidget {
  final Map<String, dynamic> student;
  final List<dynamic> courses;
  final double maxWidth;

  const MediumLayout({
    super.key,
    required this.student,
    required this.courses,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBanner(
            category: 'Medium (600 - 839px)',
            color: Colors.blue.shade700,
            icon: Icons.tablet_android,
          ),
          const SizedBox(height: 16),
          _buildProfileCard(student),
          const SizedBox(height: 20),
          const Text('Daftar Materi (Grid 2 Kolom)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.8,
            ),
            itemCount: courses.length,
            itemBuilder: (context, index) => _buildCourseCard(courses[index] as Map<String, dynamic>),
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// WIDGET 3: EXPANDED LAYOUT (>= 840 px) - Dua Panel Samping (Profile Kiri, Grid Kanan)
// =========================================================================
class ExpandedLayout extends StatelessWidget {
  final Map<String, dynamic> student;
  final List<dynamic> courses;
  final double maxWidth;

  const ExpandedLayout({
    super.key,
    required this.student,
    required this.courses,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBanner(
            category: 'Expanded (>= 840px)',
            color: Colors.teal.shade700,
            icon: Icons.desktop_windows,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Panel Sisi Kiri: Profil Mahasiswa
                SizedBox(
                  width: 320,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: _buildProfileCard(student),
                  ),
                ),
                const SizedBox(width: 24),
                // Panel Sisi Kanan: Grid 3 Kolom
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Daftar Materi (Grid 3 Kolom)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 2.2,
                          ),
                          itemCount: courses.length,
                          itemBuilder: (context, index) => _buildCourseCard(courses[index] as Map<String, dynamic>),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// KOMPONEN PEMBANTU (REUSABLE UI)
// =========================================================================
Widget _buildBanner({required String category, required Color color, required IconData icon}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color),
    ),
    child: Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 10),
        Text(
          '$studentId - $studentName | Mode: $category',
          style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13),
        ),
      ],
    ),
  );
}

Widget _buildProfileCard(Map<String, dynamic> student) {
  return Card(
    elevation: 2,
    color: Colors.blue.shade50,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        // Tambahkan baris ini agar foto profil dan teks selalu rata di bagian atas
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundImage: AssetImage('assets/images/Nyengir.jpg'),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Menjaga kolom teks tetap ringkas
              children: [
                Text(
                  student['name'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  'NIM: ${student['nim']}',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  '${student['program']} • Sem ${student['semester']}',
                  style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildCourseCard(Map<String, dynamic> item) {
  final String status = item['status'] as String;
  Color statusColor = status == 'done' ? Colors.green : (status == 'active' ? Colors.orange : Colors.grey);

  return Card(
    elevation: 1,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.book, color: statusColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(item['title'] as String, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text('${item['code']} • ${item['credits']} SKS', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}