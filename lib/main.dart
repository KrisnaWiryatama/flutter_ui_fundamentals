import 'package:flutter/material.dart';

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
      home: const Tahap6Page(),
    );
  }
}

class Tahap6Page extends StatefulWidget {
  const Tahap6Page({super.key});

  @override
  State<Tahap6Page> createState() => _Tahap6PageState();
}

class _Tahap6PageState extends State<Tahap6Page> {
  // Flag simulasi:
  // true  -> Menggunakan SingleChildScrollView (Solusi anti-overflow saat keyboard muncul)
  // false -> Tanpa SingleChildScrollView (Memicu Bottom Overflow saat keyboard muncul)
  bool useScrollView = true;

  @override
  Widget build(BuildContext context) {
    // Konten formulir yang disusun vertikal
    Widget contentBody = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Status Uji
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: useScrollView ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: useScrollView ? Colors.green : Colors.red,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  useScrollView ? Icons.check_circle : Icons.warning,
                  color: useScrollView ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    useScrollView
                        ? 'SingleChildScrollView: AKTIF (Scrollable)'
                        : 'SingleChildScrollView: NONAKTIF (Overflow)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: useScrollView ? Colors.green.shade800 : Colors.red.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Kartu Identitas Mahasiswa
          Card(
            elevation: 2,
            color: Colors.blue.shade50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.all(14.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
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
            'Form Profil & Feedback Course',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Field 1: Nama Lengkap
          TextFormField(
            initialValue: studentName,
            decoration: const InputDecoration(
              labelText: 'Nama Lengkap',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          // Field 2: NIM
          TextFormField(
            initialValue: studentId,
            decoration: const InputDecoration(
              labelText: 'NIM',
              prefixIcon: Icon(Icons.badge),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          // Field 3: Program Studi
          TextFormField(
            initialValue: 'Pendidikan Teknik Informatika',
            decoration: const InputDecoration(
              labelText: 'Program Studi',
              prefixIcon: Icon(Icons.school),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          // Field 4: Catatan / Feedback (Fokus keyboard)
          TextFormField(
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Komentar / Feedback Pembelajaran',
              hintText: 'Ketik feedback di sini untuk memunculkan keyboard...',
              prefixIcon: Icon(Icons.feedback),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // Tombol Aksi
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Form berhasil disubmit!')),
                );
              },
              icon: const Icon(Icons.save),
              label: const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tahap 6: Scrollable Content',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        actions: [
          // Tombol toggle untuk menguji perbandingan sebelum vs sesudah SingleChildScrollView
          IconButton(
            tooltip: 'Toggle ScrollView',
            icon: Icon(useScrollView ? Icons.lock_open : Icons.lock),
            onPressed: () {
              setState(() {
                useScrollView = !useScrollView;
              });
            },
          ),
        ],
      ),
      // ========================================================
      // PENERAPAN SINGLECHILDSCROLLVIEW (SESUAI TAHAP 6)
      // ========================================================
      body: useScrollView
          ? SingleChildScrollView(child: contentBody)
          : contentBody,
    );
  }
}