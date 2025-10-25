import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/podcast.dart';
import '../providers/podcast_provider.dart';

class EditPodcastScreen extends StatefulWidget {
  static const routeName = '/edit';
  final Podcast podcast;
  const EditPodcastScreen({super.key, required this.podcast});

  @override
  State<EditPodcastScreen> createState() => _EditPodcastScreenState();
}

class _EditPodcastScreenState extends State<EditPodcastScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _channelController;
  late TextEditingController _linkController;
  int _rating = 0;
  String? _selectedCategory;

  final List<String> _categories = [
    'Technology – เทคโนโลยี',
    'Education – การศึกษา',
    'Music – ดนตรี',
    'Business – ธุรกิจ',
    'Lifestyle – ไลฟ์สไตล์',
    'Health – สุขภาพ',
    'Entertainment – บันเทิง',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.podcast;

    _titleController = TextEditingController(text: p.title);
    _descriptionController = TextEditingController(text: p.description);
    _channelController = TextEditingController(text: p.channel);
    _linkController = TextEditingController(text: p.link);
    _rating = p.rating;

    // ตรวจสอบหมวดหมู่เก่าก่อนใส่ค่าใน dropdown
    if (p.category != null && _categories.contains(p.category)) {
      _selectedCategory = p.category;
    } else if (p.category != null && p.category!.isNotEmpty) {
      // ถ้าไม่มีใน list ให้เพิ่มไว้ชั่วคราว (ไม่ซ้ำ)
      final missingCat = '${p.category!} (ไม่พบในหมวด)';
      if (!_categories.contains(missingCat)) {
        _categories.insert(0, missingCat);
      }
      _selectedCategory = missingCat;
    } else {
      _selectedCategory = null;
    }
  }

  String? _extractYouTubeThumbnail(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    if (uri.host.contains('youtube.com') && uri.queryParameters['v'] != null) {
      final videoId = uri.queryParameters['v'];
      return 'https://img.youtube.com/vi/$videoId/0.jpg';
    } else if (uri.host.contains('youtu.be')) {
      final videoId = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
      if (videoId != null) {
        return 'https://img.youtube.com/vi/$videoId/0.jpg';
      }
    }
    return null;
  }

  void _saveEdit() async {
    final provider = Provider.of<PodcastProvider>(context, listen: false);
    final link = _linkController.text;
    final thumbnailUrl = _extractYouTubeThumbnail(link);

    // 🔹 ตัด "(ไม่พบในหมวด)" ก่อนบันทึก
    String? cleanCategory = _selectedCategory;
    if (cleanCategory != null && cleanCategory.contains('(ไม่พบในหมวด)')) {
      cleanCategory = cleanCategory.replaceAll(' (ไม่พบในหมวด)', '');
    }

    final updated = Podcast(
      id: widget.podcast.id,
      title: _titleController.text,
      description: _descriptionController.text,
      category: cleanCategory ?? widget.podcast.category,
      channel: _channelController.text,
      link: link,
      thumbnailUrl: thumbnailUrl,
      rating: _rating,
    );

    await provider.updatePodcast(widget.podcast.id!, updated);
    if (context.mounted) Navigator.pop(context);
  }

  Widget buildStar(int index) {
    return IconButton(
      icon: Icon(
        Icons.star,
        color: _rating >= index ? Colors.amber : Colors.grey,
      ),
      onPressed: () => setState(() => _rating = index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'แก้ไข Podcast',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 10),
            Icon(Icons.edit, color: Colors.red),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 126, 221, 255),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _channelController,
              decoration: const InputDecoration(
                labelText: 'ชื่อช่อง (channel)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'ชื่อเรื่อง',
                border: OutlineInputBorder(),
              ),
              minLines: 1,
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'รายละเอียด',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 13),
              minLines: 3,
              maxLines: 8,
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'หมวดหมู่',
                border: OutlineInputBorder(),
              ),
              items: _categories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCategory = val),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _linkController,
              decoration: const InputDecoration(
                labelText: 'ลิงก์ Podcast',
                border: OutlineInputBorder(),
              ),
              minLines: 1,
              maxLines: 4,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [for (int i = 1; i <= 5; i++) buildStar(i)],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _saveEdit,
              child: const Text(
                'บันทึกการแก้ไข',
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 89, 178),
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
