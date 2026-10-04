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
      title: 'Course Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const Tahap14FeedbackPage(),
    );
  }
}

class Tahap14FeedbackPage extends StatefulWidget {
  const Tahap14FeedbackPage({super.key});

  @override
  State<Tahap14FeedbackPage> createState() => _Tahap14FeedbackPageState();
}

class _Tahap14FeedbackPageState extends State<Tahap14FeedbackPage> {
  bool _isLoading = false;

  // Fungsi simulasi proses asinkron dengan loading feedback
  Future<void> _processEnrollment() async {
    setState(() {
      _isLoading = true;
    });

    // Simulasi jeda network request selama 2 detik
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    // SnackBar Feedback setelah proses selesai
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Berhasil didaftarkan untuk $studentName ($studentId)!',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'TUTUP',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Menampilkan Dialog Konfirmasi
  void _showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User wajib memilih salah satu tombol
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.help_outline, color: Colors.blueAccent),
              SizedBox(width: 8),
              Text('Konfirmasi'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Apakah Anda yakin ingin mendaftar ke kursus ini?'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data Praktikan:',
                      style: TextStyle(fontSize: 11, color: Colors.blueGrey, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 2),
                    Text('$studentId - $studentName', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
                _processEnrollment();   // Jalankan loading dan snackbar
              },
              child: const Text('Ya, Daftarkan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dialog & Feedback',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Identitas Mahasiswa Card
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
            const SizedBox(height: 28),

            const Text(
              'Uji Alur Interaksi Feedback:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Alur: Klik Tombol -> Muncul AlertDialog Konfirmasi -> Animasi Loading 2 Detik -> SnackBar Berhasil.',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 24),

            // Tombol Memicu Dialog atau Menampilkan Loading
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _isLoading ? null : _showConfirmationDialog,
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Memproses Pendaftaran...'),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.app_registration),
                          SizedBox(width: 8),
                          Text(
                            'Daftar Kursus Baru',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}