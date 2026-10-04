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
      title: 'Course Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const AdaptiveMainShell(),
    );
  }
}

// =========================================================================
// ADAPTIVE SHELL: NAVIGATION BAR vs NAVIGATION RAIL (TAHAP 11)
// =========================================================================
class AdaptiveMainShell extends StatefulWidget {
  const AdaptiveMainShell({super.key});

  @override
  State<AdaptiveMainShell> createState() => _AdaptiveMainShellState();
}

class _AdaptiveMainShellState extends State<AdaptiveMainShell> {
  int selectedIndex = 0;
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
    return FutureBuilder<Map<String, dynamic>>(
      future: dashboardFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Gagal memuat data: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
            ),
          );
        }

        final data = snapshot.data!;
        final student = data['student'] as Map<String, dynamic>;
        final courses = data['courses'] as List<dynamic>;
        final List<Widget> pages = [
          HomeTab(student: student, courses: courses),
          CoursesTab(courses: courses),
          ProfileTab(student: student),
        ];

        // ========================================================
        // IMPLEMENTASI TAHAP 11: LAYOUTBUILDER UNTUK ADAPTIVE NAV
        // ========================================================
        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 840) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(
                    'Course Explorer - Expanded (${constraints.maxWidth.toStringAsFixed(0)}px)',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  backgroundColor: Colors.blueAccent,
                ),
                body: Row(
                  children: [
                    NavigationRail(
                      selectedIndex: selectedIndex,
                      onDestinationSelected: (index) {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      labelType: NavigationRailLabelType.all,
                      leading: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.blue.shade100,
                          child: const Icon(Icons.school, color: Colors.blueAccent),
                        ),
                      ),
                      destinations: const [
                        NavigationRailDestination(
                          icon: Icon(Icons.home_outlined),
                          selectedIcon: Icon(Icons.home),
                          label: Text('Home'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.school_outlined),
                          selectedIcon: Icon(Icons.school),
                          label: Text('Courses'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.person_outline),
                          selectedIcon: Icon(Icons.person),
                          label: Text('Profile'),
                        ),
                      ],
                    ),
                    const VerticalDivider(thickness: 1, width: 1),
                    Expanded(
                      child: pages[selectedIndex],
                    ),
                  ],
                ),
              );
            }

            return Scaffold(
              appBar: AppBar(
                title: Text(
                  'Course Explorer - Compact (${constraints.maxWidth.toStringAsFixed(0)}px)',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                backgroundColor: Colors.blueAccent,
              ),
              body: pages[selectedIndex],
              bottomNavigationBar: NavigationBar(
                selectedIndex: selectedIndex,
                onDestinationSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.school_outlined),
                    selectedIcon: Icon(Icons.school),
                    label: 'Courses',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// =========================================================================
// TAB 1: HOME TAB
// =========================================================================
class HomeTab extends StatelessWidget {
  final Map<String, dynamic> student;
  final List<dynamic> courses;

  const HomeTab({super.key, required this.student, required this.courses});

  @override
  Widget build(BuildContext context) {
    final int doneCourses = courses.where((c) => c['status'] == 'done').length;
    final int totalCredits = courses.fold(0, (sum, c) => sum + (c['credits'] as int));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            color: Colors.blue.shade50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundImage: AssetImage('assets/images/Nyengir.jpg'),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Halo, $studentName!', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 2),
                        Text('NIM: $studentId', style: const TextStyle(fontSize: 13)),
                        const SizedBox(height: 2),
                        Text('${student['program']}', style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Ringkasan Pembelajaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildStatCard('Total Topik', '${courses.length}', Colors.blueAccent, Icons.topic),
              const SizedBox(width: 8),
              _buildStatCard('Selesai', '$doneCourses', Colors.green, Icons.task_alt),
              const SizedBox(width: 8),
              _buildStatCard('Total SKS', '$totalCredits', Colors.orange, Icons.school),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String val, Color color, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(height: 8),
              Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
              Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

// =========================================================================
// TAB 2: COURSES TAB
// =========================================================================
class CoursesTab extends StatelessWidget {
  final List<dynamic> courses;

  const CoursesTab({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final item = courses[index] as Map<String, dynamic>;
        final String status = item['status'] as String;
        Color statusColor = status == 'done'
            ? Colors.green
            : (status == 'active' ? Colors.orange : Colors.grey);
        String statusText = status == 'done'
            ? 'Selesai'
            : (status == 'active' ? 'Berjalan' : 'Belum');

        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: statusColor.withOpacity(0.15),
              child: Icon(Icons.menu_book, color: statusColor, size: 20),
            ),
            title: Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text('${item['code']} • ${item['credits']} SKS'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                statusText,
                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ),
          ),
        );
      },
    );
  }
}

// =========================================================================
// TAB 3: PROFILE TAB
// =========================================================================
class ProfileTab extends StatelessWidget {
  final Map<String, dynamic> student;

  const ProfileTab({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Center(
            child: CircleAvatar(
              radius: 46,
              backgroundImage: AssetImage('assets/images/Nyengir.jpg'),
            ),
          ),
          const SizedBox(height: 12),
          Text(studentName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('NIM: $studentId', style: const TextStyle(fontSize: 14, color: Colors.blueGrey)),
          const SizedBox(height: 20),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.school, color: Colors.blueAccent),
                  title: const Text('Program Studi'),
                  subtitle: Text(student['program'] as String),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.blueAccent),
                  title: const Text('Semester Aktif'),
                  subtitle: Text('Semester ${student['semester']}'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}