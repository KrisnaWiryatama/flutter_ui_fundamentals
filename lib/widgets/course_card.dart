import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';

class CourseCard extends StatefulWidget {
  final Course item;
  final VoidCallback onLongPress;
  final VoidCallback onTap;

  const CourseCard({
    super.key,
    required this.item,
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
    Color statusColor = Colors.grey;
    String statusText = 'Belum';
    if (widget.item.status == 'done') {
      statusColor = Colors.green;
      statusText = 'Selesai';
    } else if (widget.item.status == 'active') {
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
                          widget.item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${widget.item.code} • ${widget.item.credits} SKS',
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
                  Consumer<CourseProvider>(
                    builder: (context, provider, child) {
                      final bool isFav = provider.isFavorite(widget.item.code);
                      return IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.red : Colors.grey,
                          size: 20,
                        ),
                        onPressed: () {
                          context.read<CourseProvider>().toggleFavorite(widget.item.code);
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                !isFav
                                    ? '"${widget.item.title}" ditambahkan ke favorit!'
                                    : '"${widget.item.title}" dihapus dari favorit.',
                              ),
                              backgroundColor: !isFav ? Colors.indigo : Colors.grey.shade800,
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      );
                    },
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
                    'Catatan Lokal: Materi "${widget.item.title}" sedang diperiksa (State lokal via setState).',
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