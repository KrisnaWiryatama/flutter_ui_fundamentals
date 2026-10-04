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
      home: const Tahap9ListPage(),
    );
  }
}

// =========================================================================
// 1. LIST PAGE (Screen Pemanggil yang Menunggu Hasil Balikan)
// =========================================================================
class Tahap9ListPage extends StatefulWidget {
  const Tahap9ListPage({super.key});

  @override
  State<Tahap9ListPage> createState() => _Tahap9ListPageState();
}

class _Tahap9ListPageState extends State<Tahap9ListPage> {
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
          'List Page',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
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
          final courses = data['courses'] as List<dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Identitas Mahasiswa
                Card(
                  elevation: 2,
                  color: Colors.blue.shade50,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: const Padding(
                    padding: EdgeInsets.all(14.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundImage: AssetImage('assets/images/Nyengir.jpg'),
                        ),
                        SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(studentName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            Text('NIM: $studentId', style: TextStyle(fontSize: 13)),
                            Text('Pendidikan Teknik Informatika', style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Daftar Materi Pembelajaran:',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                Expanded(
                  child: ListView.builder(
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
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: statusColor.withOpacity(0.15),
                            child: Icon(Icons.school, color: statusColor, size: 20),
                          ),
                          title: Text(
                            item['title'] as String,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          subtitle: Text('${item['code']} • ${item['credits']} SKS'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  statusText,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                            ],
                          ),
                          // ========================================================
                          // IMPLEMENTASI TAHAP 9: MENUNGGU DATA KEMBALIAN (AWAIT)
                          // ========================================================
                          onTap: () async {
                            final result = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CourseDetailPage(course: item),
                              ),
                            );
                            
                            if (result == true && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Materi "${item['title']}" berhasil ditambahkan ke Favorit!'),
                                  backgroundColor: Colors.indigo,
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// =========================================================================
// 2. DETAIL PAGE (Screen Pengirim Balikan Data via pop(result))
// =========================================================================
class CourseDetailPage extends StatelessWidget {
  final Map<String, dynamic> course;

  const CourseDetailPage({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Logika penentuan teks dan warna status yang dinamis
    final String status = course['status'] as String;
    Color statusColor = Colors.grey;
    String statusText = 'Belum';

    if (status == 'done') {
      statusColor = Colors.green;
      statusText = 'Selesai';
    } else if (status == 'active') {
      statusColor = Colors.orange; // Warna oranye/kuning sesuai halaman awal
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
            // Kartu Ringkasan Course dengan Badge Status Dinamis
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Badge Kode Mata Pelajaran (MOB02)
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
                        // Badge Status Menyesuaikan Warna Dinamis (Hijau / Oranye / Abu-abu)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15), // Background warna transparan mengikuti status
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor, // Warna teks mengikuti status
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
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Beban Belajar: ${course['credits']} SKS',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Kartu Identitas Praktikan
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

            // Tombol Favoritkan (Pop dengan nilai true)
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
                label: const Text(
                  'Favoritkan Course Ini',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
            ),
            const SizedBox(height: 10),

            // Tombol Kembali
            SizedBox(
              width: double.infinity,
              height: 46,
              child: TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal / Kembali'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}