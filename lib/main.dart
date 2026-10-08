import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

// Identitas Wajib Praktikum
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
      title: 'Learning Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const MainAdaptiveShell(),
    );
  }
}

class MainAdaptiveShell extends StatefulWidget {
  const MainAdaptiveShell({super.key});

  @override
  State<MainAdaptiveShell> createState() => _MainAdaptiveShellState();
}

class _MainAdaptiveShellState extends State<MainAdaptiveShell> {
  int _selectedIndex = 0;
  late Future<Map<String, dynamic>> _dashboardFuture;

  // Koleksi mata kuliah favorit
  final Set<String> _favoriteCourses = {};

  // TAHAP 4: Deklarasi ValueNotifier<int> untuk nilai sederhana jumlah favorit
  final ValueNotifier<int> _favoriteCountNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _loadStudentData();
  }

  @override
  void dispose() {
    // Praktik terbaik: dispose ValueNotifier ketika widget dihancurkan
    _favoriteCountNotifier.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _loadStudentData() async {
    final jsonString = await rootBundle.loadString('assets/data/student_data.json');
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  void _handleFavoriteChanged(String courseCode) {
    setState(() {
      if (_favoriteCourses.contains(courseCode)) {
        _favoriteCourses.remove(courseCode);
      } else {
        _favoriteCourses.add(courseCode);
      }
      // Memperbarui nilai ValueNotifier
      _favoriteCountNotifier.value = _favoriteCourses.length;
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
          HomeTab(
            student: student,
            courses: courses,
            favoriteCourses: _favoriteCourses,
            favoriteCountNotifier: _favoriteCountNotifier, // Kirim ValueNotifier ke Child
          ),
          CoursesTab(
            courses: courses,
            favoriteCourses: _favoriteCourses,
            onFavoriteChanged: _handleFavoriteChanged,
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
                    'Learning Dashboard',
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

class HomeTab extends StatelessWidget {
  final Map<String, dynamic> student;
  final List<dynamic> courses;
  final Set<String> favoriteCourses;
  final ValueNotifier<int> favoriteCountNotifier; // TAHAP 4: Menerima ValueNotifier

  const HomeTab({
    super.key,
    required this.student,
    required this.courses,
    required this.favoriteCourses,
    required this.favoriteCountNotifier,
  });

  final List<String> skills = const [
    'Flutter UI',
    'Dart Fundamentals',
    'Adaptive Layout',
    'Stateful Navigation',
    'Form Validation',
    'Async & SnackBar',
  ];

  void _showFavoritesModal(BuildContext context) {
    final List<dynamic> favList = courses
        .where((c) => favoriteCourses.contains(c['code'] as String))
        .toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Text(
                    'Mata Kuliah Favorit (${favList.length})',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (favList.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'Belum ada mata kuliah yang difavoritkan.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: favList.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, idx) {
                      final item = favList[idx] as Map<String, dynamic>;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: Colors.red.shade50,
                          child: const Icon(Icons.school, color: Colors.redAccent, size: 20),
                        ),
                        title: Text(
                          item['title'] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: Text('${item['code']} • ${item['credits']} SKS'),
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
              _buildStatCard('Topik', '${courses.length}', Colors.blueAccent, Icons.topic),
              const SizedBox(width: 6),
              _buildStatCard('Selesai', '$doneCount', Colors.green, Icons.task_alt),
              const SizedBox(width: 6),
              _buildStatCard('SKS', '$totalCredits', Colors.orange, Icons.school),
              const SizedBox(width: 6),

              // TAHAP 4: Tampilkan nilai dengan ValueListenableBuilder & Tambahkan Button Pengubah Value
              Expanded(
                child: ValueListenableBuilder<int>(
                  valueListenable: favoriteCountNotifier,
                  builder: (context, val, child) {
                    return Card(
                      elevation: 1.5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => _showFavoritesModal(context),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Icon(Icons.favorite, size: 16, color: Colors.redAccent),
                                  // Tombol Aksi Pengubah ValueNotifier (Tahap 4)
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          if (favoriteCountNotifier.value > 0) {
                                            favoriteCountNotifier.value--; // Ubah value (-1)
                                          }
                                        },
                                        borderRadius: BorderRadius.circular(4),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text('-', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                      InkWell(
                                        onTap: () {
                                          favoriteCountNotifier.value++; // Ubah value (+1)
                                        },
                                        borderRadius: BorderRadius.circular(4),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade100,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text('+', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$val', // Menampilkan nilai terkini dari ValueNotifier
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent),
                              ),
                              const Text('Favorit', style: TextStyle(fontSize: 10, color: Colors.grey)),
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
          const SizedBox(height: 24),

          const Text('Kompetensi Praktikum', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(height: 6),
              Text(val, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
              Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

class CoursesTab extends StatelessWidget {
  final List<dynamic> courses;
  final Set<String> favoriteCourses;
  final Function(String) onFavoriteChanged;

  const CoursesTab({
    super.key,
    required this.courses,
    required this.favoriteCourses,
    required this.onFavoriteChanged,
  });

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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daftar Materi Kuliah',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            '• Tap: Detail | Long Press: Modal | Love: Callback ke Parent',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final item = courses[index] as Map<String, dynamic>;
                final String code = item['code'] as String;
                final bool isFav = favoriteCourses.contains(code);

                return CourseCard(
                  item: item,
                  isFavorite: isFav,
                  onFavoriteChanged: () {
                    onFavoriteChanged(code);
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          !isFav
                              ? '"${item['title']}" ditambahkan ke favorit!'
                              : '"${item['title']}" dihapus dari favorit.',
                        ),
                        backgroundColor: !isFav ? Colors.indigo : Colors.grey.shade800,
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  onLongPress: () => _showCourseDetailModal(context, item),
                  onTap: () async {
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CourseDetailPage(
                          course: item,
                          isInitiallyFavorite: isFav,
                        ),
                      ),
                    );

                    if (result == true && context.mounted) {
                      onFavoriteChanged(code);
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            !isFav
                                ? '"${item['title']}" ditambahkan ke favorit!'
                                : '"${item['title']}" dihapus dari favorit.',
                          ),
                          backgroundColor: !isFav ? Colors.indigo : Colors.grey.shade800,
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
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

class CourseCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final bool isFavorite;
  final VoidCallback onFavoriteChanged;
  final VoidCallback onLongPress;
  final VoidCallback onTap;

  const CourseCard({
    super.key,
    required this.item,
    required this.isFavorite,
    required this.onFavoriteChanged,
    required this.onLongPress,
    required this.onTap,
  });

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  bool _showLocalNote = false;

  @override
  Widget build(BuildContext context) {
    final String status = widget.item['status'] as String;
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
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: statusColor.withOpacity(0.15),
                    child: Icon(Icons.school, color: statusColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item['title'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${widget.item['code']} • ${widget.item['credits']} SKS',
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
                    tooltip: 'Toggle Catatan Lokal',
                    icon: Icon(
                      _showLocalNote ? Icons.info : Icons.info_outline,
                      color: Colors.blueAccent,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _showLocalNote = !_showLocalNote;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: widget.isFavorite ? Colors.red : Colors.grey,
                      size: 20,
                    ),
                    onPressed: widget.onFavoriteChanged,
                  ),
                ],
              ),
              if (_showLocalNote) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Text(
                    'Catatan Lokal: Materi "${widget.item['title']}" sedang diperiksa (State lokal via setState).',
                    style: TextStyle(fontSize: 11, color: Colors.blue.shade900),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class CourseDetailPage extends StatelessWidget {
  final Map<String, dynamic> course;
  final bool isInitiallyFavorite;

  const CourseDetailPage({
    super.key,
    required this.course,
    required this.isInitiallyFavorite,
  });

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
                  backgroundColor: isInitiallyFavorite ? Colors.red.shade600 : Colors.grey.shade200,
                  foregroundColor: isInitiallyFavorite ? Colors.white : Colors.black87,
                  elevation: isInitiallyFavorite ? 2 : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isInitiallyFavorite ? Colors.red.shade700 : Colors.grey.shade400,
                    ),
                  ),
                ),
                icon: Icon(
                  isInitiallyFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isInitiallyFavorite ? Colors.white : Colors.grey.shade700,
                ),
                label: Text(
                  isInitiallyFavorite ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () => Navigator.pop(context, true),
              ),
            ),
            const SizedBox(height: 10),

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
    await Future.delayed(const Duration(seconds: 2));

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