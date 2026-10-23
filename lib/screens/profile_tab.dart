import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class ProfileTab extends StatefulWidget {
  final Map<String, dynamic>? student;

  const ProfileTab({super.key, required this.student});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    final bool? confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Kirim'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Kirim masukan ke tim pengembang aplikasi?'),
            const SizedBox(height: 12),
            Text(
              '"${_feedbackController.text.trim()}"',
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.blueAccent,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Kirim'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    _feedbackController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Terima kasih, masukan Anda telah terkirim!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final studentData = widget.student;

    // Tampilkan loading jika data profil masih diambil asynchronous oleh provider
    if (studentData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final String name = studentData['name']?.toString() ?? studentName;
    final String nim = studentData['nim']?.toString() ?? studentId;
    final String program = studentData['program']?.toString() ?? 'Pendidikan Teknik Informatika';
    final String semester = studentData['semester']?.toString() ?? '5';
    final String track = studentData['track']?.toString() ?? 'Mobile Application Development';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Center(
            child: CircleAvatar(
              radius: 45,
              backgroundImage: AssetImage('assets/images/Nyengir.jpg'),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'NIM: $nim',
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // Detail Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.school, color: Colors.blueAccent),
                    title: const Text('Program Studi'),
                    subtitle: Text(program),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.calendar_today, color: Colors.blueAccent),
                    title: const Text('Semester'),
                    subtitle: Text('Semester $semester'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.code, color: Colors.blueAccent),
                    title: const Text('Jalur Peminatan'),
                    subtitle: Text(track),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Formulir Evaluasi Diri',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 8),

          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _feedbackController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Kritik & Saran / Catatan Mandiri',
                    hintStyle: TextStyle(color: Colors.grey),
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
                    onPressed: _isSubmitting ? null : _submitFeedback,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
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