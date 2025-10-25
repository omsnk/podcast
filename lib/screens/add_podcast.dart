import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/podcast.dart';
import '../providers/podcast_provider.dart';

class AddPodcastScreen extends StatefulWidget {
  static const routeName = '/add';
  const AddPodcastScreen({super.key});

  @override
  State<AddPodcastScreen> createState() => _AddPodcastScreenState();
}

class _AddPodcastScreenState extends State<AddPodcastScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _channelController = TextEditingController();
  final _linkController = TextEditingController();
  int _rating = 0;

  final List<String> _categories = [
    'Technology – เทคโนโลยี',
    'Education – การศึกษา',
    'Music – ดนตรี',
    'Business – ธุรกิจ',
    'Lifestyle – ไลฟ์สไตล์',
    'Health – สุขภาพ',
    'Entertainment – บันเทิง',
  ];
  String? _selectedCategory;

  Widget buildStar(int index) {
    return IconButton(
      icon: Icon(
        Icons.star,
        color: _rating >= index ? Colors.amber : Colors.grey,
      ),
      onPressed: () => setState(() => _rating = index),
    );
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

  void _saveForm() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณากรอกชื่อเรื่อง')));
      return;
    }

    final provider = Provider.of<PodcastProvider>(context, listen: false);
    final link = _linkController.text;
    final thumbnailUrl = _extractYouTubeThumbnail(link);

    final newPodcast = Podcast(
      title: _titleController.text,
      description: _descriptionController.text,
      category: _selectedCategory ?? 'ยังไม่ระบุหมวดหมู่',
      channel: _channelController.text,
      link: link,
      thumbnailUrl: thumbnailUrl,
      rating: _rating,
    );

    await provider.addPodcast(newPodcast);
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'เพิ่ม Podcast',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 10),
            Icon(Icons.add, color: Colors.red, size: 30),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 126, 221, 255),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
                hintText: 'ใส่รายละเอียดสั้น ๆ เกี่ยวกับพอดแคสต์ของคุณ',
                hintStyle: TextStyle(color: Colors.grey),
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
              onPressed: _saveForm,
              child: const Text(
                'บันทึก',
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
