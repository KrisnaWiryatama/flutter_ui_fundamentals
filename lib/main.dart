import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

// Identitas Mahasiswa Praktikan
const String studentName = 'Putu Krisna Wiryatama';
const String studentId = '2415051099';

void main() {
  runApp(const LearningExplorerApp());
}

class LearningExplorerApp extends StatelessWidget {
  const LearningExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Course Explorer - Final',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const MainAdaptiveShell(),
    );
  }
}

// =========================================================================
// 1. ADAPTIVE SHELL (NAVIGATION RAIL & BOTTOM NAVIGATION BAR)
// =========================================================================
class MainAdaptiveShell extends StatefulWidget {
  const MainAdaptiveShell({super.key});

  @override
  State<MainAdaptiveShell> createState() => _MainAdaptiveShellState();
}

class _MainAdaptiveShellState extends State<MainAdaptiveShell> {
  int _selectedIndex = 0;
  late Future<Map<String, dynamic>> _dashboardFuture;
  final Set<String> _favoriteCourses = {};

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _loadStudentData();
  }

  Future<Map<String, dynamic>> _loadStudentData() async {
    final jsonString = await rootBundle.loadString('assets/data/student_data.json');
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  void _toggleFavorite(String courseCode) {
    setState(() {
      if (_favoriteCourses.contains(courseCode)) {
        _favoriteCourses.remove(courseCode);
      } else {
        _favoriteCourses.add(courseCode);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _dashboardFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                'Gagal memuat data: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        final data = snapshot.data!;
        final student = data['student'] as Map<String, dynamic>;
        final courses = data['courses'] as List<dynamic>;

        final List<Widget> pages = [
          HomeTab(student: student, courses: courses),
          CoursesTab(
            courses: courses,
            favoriteCourses: _favoriteCourses,
            onToggleFavorite: _toggleFavorite,
          ),
          ProfileTab(student: student),
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth >= 840;

            if (isWide) {
              return Scaffold(  
                appBar: AppBar(
                  title: const Text(
                    'Learning Dashboard • Final Polish',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  backgroundColor: Colors.blueAccent,
                ),
                body: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NavigationRail(
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: (index) => setState(() => _selectedIndex = index),
                      labelType: NavigationRailLabelType.all,
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
                    Expanded(child: pages[_selectedIndex]),
                  ],
                ),
              );
            }

            return Scaffold(
              appBar: AppBar(
                title: const Text(
                  'Learning Dashboard',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                backgroundColor: Colors.blueAccent,
              ),
              body: pages[_selectedIndex],
              bottomNavigationBar: NavigationBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) => setState(() => _selectedIndex = index),
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
// 2. TAB 1: HOME TAB (WRAP SKILLS & STATS)
// =========================================================================
class HomeTab extends StatelessWidget {
  final Map<String, dynamic> student;
  final List<dynamic> courses;

  const HomeTab({super.key, required this.student, required this.courses});

  final List<String> skills = const [
    'Flutter UI',
    'Dart Fundamentals',
    'Adaptive Layout',
    'Stateful Navigation',
    'Form Validation',
    'Async & SnackBar',
  ];

  @override
  Widget build(BuildContext context) {
    final int doneCount = courses.where((c) => c['status'] == 'done').length;
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
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: AssetImage('assets/images/Nyengir.jpg'),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(studentName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 2),
                        Text('NIM: $studentId', style: TextStyle(fontSize: 13)),
                        SizedBox(height: 2),
                        Text('Pendidikan Teknik Informatika • Sem 5', style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Text('Ringkasan Akademik', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildStatCard('Total Topik', '${courses.length}', Colors.blueAccent, Icons.topic),
              const SizedBox(width: 8),
              _buildStatCard('Selesai', '$doneCount', Colors.green, Icons.task_alt),
              const SizedBox(width: 8),
              _buildStatCard('Total SKS', '$totalCredits', Colors.orange, Icons.school),
            ],
          ),
          const SizedBox(height: 24),

          const Text('Kompetensi Praktikum (Wrap Chips)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills.map((s) {
              return Chip(
                avatar: const Icon(Icons.check_circle_outline, size: 16, color: Colors.blueAccent),
                label: Text(s, style: const TextStyle(fontSize: 12)),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              );
            }).toList(),
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
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
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
// 3. TAB 2: COURSES TAB (RESPONSIVE GRID, INKWELL, & PASSING/RETURNING DATA)
// =========================================================================
class CoursesTab extends StatelessWidget {
  final List<dynamic> courses;
  final Set<String> favoriteCourses;
  final Function(String) onToggleFavorite;

  const CoursesTab({
    super.key,
    required this.courses,
    required this.favoriteCourses,
    required this.onToggleFavorite,
  });

  int _calculateColumns(double width) {
    if (width < 600) return 1;
    if (width < 900) return 2;
    return 3;
  }

  void _showCourseDetailModal(BuildContext context, Map<String, dynamic> item) {
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
              Text(item['code'] as String, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              const SizedBox(height: 6),
              Text(item['title'] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Beban SKS: ${item['credits']} SKS | Status: ${item['status']}', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 12),
              const Text('Info singkat dibuka via Long Press gesture pada kartu materi.'),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int columnCount = _calculateColumns(constraints.maxWidth);

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daftar Materi Kuliah ($columnCount Kolom)',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                '• Tap: Buka Detail | Long Press: Modal Ringkas | Love: Toggle Favorit',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columnCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: columnCount == 1 ? 3.4 : (columnCount == 2 ? 2.5 : 2.0),
                  ),
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final item = courses[index] as Map<String, dynamic>;
                    final String code = item['code'] as String;
                    final bool isFav = favoriteCourses.contains(code);

                    final String status = item['status'] as String;
                    Color statusColor = Colors.grey;
                    String statusText = 'Belum';
                    if (status == 'done') {
                      statusColor = Colors.green;
                      statusText = 'Selesai';
                    } else if (status == 'active') {
                      statusColor = Colors.orange;
                      statusText = 'Berjalan';
                    }

                    return Card(
                      elevation: 1.5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () async {
                          // Navigasi ke DetailPage & menunggu hasil return
                          final result = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CourseDetailPage(course: item),
                            ),
                          );

                          if (result == true && context.mounted) {
                            onToggleFavorite(code);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('"${item['title']}" difavoritkan oleh $studentName!'),
                                backgroundColor: Colors.indigo,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        onLongPress: () => _showCourseDetailModal(context, item),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: statusColor.withOpacity(0.15),
                                child: Icon(Icons.school, color: statusColor, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      item['title'] as String,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${item['code']} • ${item['credits']} SKS',
                                      style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  statusText,
                                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  isFav ? Icons.favorite : Icons.favorite_border,
                                  color: isFav ? Colors.red : Colors.grey,
                                  size: 20,
                                ),
                                onPressed: () => onToggleFavorite(code),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// =========================================================================
// 4. COURSE DETAIL PAGE (MATCHING DESIGN & RETURNING DATA)
// =========================================================================
class CourseDetailPage extends StatelessWidget {
  final Map<String, dynamic> course;

  const CourseDetailPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final String status = course['status'] as String;
    Color statusColor = Colors.grey;
    String statusText = 'Belum';

    if (status == 'done') {
      statusColor = Colors.green;
      statusText = 'Selesai';
    } else if (status == 'active') {
      statusColor = Colors.orange;
      statusText = 'Berjalan';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          course['title'] as String,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            course['code'] as String,
                            style: const TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      course['title'] as String,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Beban Belajar: ${course['credits']} SKS',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Card(
              elevation: 1,
              color: Colors.grey.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const Padding(
                padding: EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pemeriksa / Praktikan:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey),
                    ),
                    SizedBox(height: 4),
                    Text('$studentId - $studentName', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  ],
                ),
              ),
            ),
            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.favorite),
                label: const Text('Favoritkan Course Ini', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () => Navigator.pop(context, true),
              ),
            ),
            const SizedBox(height: 10),

            // Tombol Kembali
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Kembali ke Daftar Materi'),
                onPressed: () => Navigator.pop(context, false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// 5. TAB 3: PROFILE TAB (FORM VALIDATION, ASYNC LOADING & ALERT DIALOG)
// =========================================================================
class ProfileTab extends StatefulWidget {
  final Map<String, dynamic> student;

  const ProfileTab({super.key, required this.student});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _commentController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    final bool? confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Colors.blueAccent),
            SizedBox(width: 8),
            Text('Konfirmasi Kirim'),
          ],
        ),
        content: Text('Kirim formulir evaluasi untuk praktikan $studentName ($studentId)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Kirim'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2)); // Simulasi async

    if (!mounted) return;
    setState(() => _isProcessing = false);

    _commentController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Evaluasi berhasil terkirim dan tersimpan!'),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

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
          const Text(studentName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('NIM: $studentId', style: TextStyle(fontSize: 14, color: Colors.blueGrey)),
          const SizedBox(height: 20),

          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.school, color: Colors.blueAccent),
                  title: const Text('Program Studi'),
                  subtitle: Text(widget.student['program'] as String),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.blueAccent),
                  title: const Text('Semester'),
                  subtitle: Text('Semester ${widget.student['semester']}'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Formulir Evaluasi Modul',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
            ),
          ),
          const SizedBox(height: 10),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _commentController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Kritik & Saran / Catatan Modul',
                    hintText: 'Minimal 5 karakter masukan...',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Komentar tidak boleh kosong';
                    if (val.trim().length < 5) return 'Minimal 5 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _isProcessing ? null : _submitFeedback,
                    child: _isProcessing
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              ),
                              SizedBox(width: 12),
                              Text('Mengirimkan Masukan...'),
                            ],
                          )
                        : const Text('Kirim Evaluasi', style: TextStyle(fontWeight: FontWeight.bold)),
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