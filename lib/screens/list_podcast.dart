import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/podcast_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'add_podcast.dart';
import 'edit_podcast.dart';

class ListPodcastScreen extends StatefulWidget {
  const ListPodcastScreen({super.key});

  @override
  State<ListPodcastScreen> createState() => _ListPodcastScreenState();
}

class _ListPodcastScreenState extends State<ListPodcastScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<PodcastProvider>(
        context,
        listen: false,
      ).fetchAndSetPodcasts(),
    );
  }

  Widget buildStars(int rating) {
    return Row(
      children: List.generate(
        5,
        (index) => Icon(
          Icons.star,
          color: index < rating ? Colors.amber : Colors.grey.shade400,
          size: 18,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PodcastProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Podcast 🎧',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 30, color: Colors.red),
            onPressed: () {
              Navigator.pushNamed(context, '/add');
            },
          ),
          const SizedBox(width: 20),
        ],
        backgroundColor: const Color.fromARGB(255, 126, 221, 255),
      ),
      body: provider.podcasts.isEmpty
          ? const Center(child: Text('ไม่มีรายการ Podcast'))
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(top: 15),
              itemCount: provider.podcasts.length,
              itemBuilder: (context, i) {
                final p = provider.podcasts[i];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'หมวดหมู่: ${p.category}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditPodcastScreen(podcast: p),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('ยืนยันการลบ'),
                                        content: const Text(
                                          'คุณแน่ใจหรือไม่ว่า ต้องการลบรายการนี้?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(
                                                ctx,
                                              ).pop(); // ปิด dialog (ยกเลิก)
                                            },
                                            child: const Text('ยกเลิก'),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                    255,
                                                    224,
                                                    56,
                                                    56,
                                                  ),
                                            ),
                                            onPressed: () {
                                              Navigator.of(
                                                ctx,
                                              ).pop(); // ปิด dialog ก่อน
                                              Provider.of<PodcastProvider>(
                                                context,
                                                listen: false,
                                              ).deletePodcast(p.id!);
                                            },
                                            child: const Text(
                                              'ยืนยัน',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                p.thumbnailUrl ?? '',
                                width: 90,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color.fromARGB(
                                        255,
                                        123,
                                        188,
                                        241,
                                      ),
                                      width: 2, // ความหนาขอบ
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.podcasts,
                                    size: 30,
                                    color: Color.fromARGB(255, 123, 188, 241),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 13),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'channel: ${p.channel}',
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (p.description != null && p.description.isNotEmpty)
                          Text(
                            'รายละเอียด: ${p.description}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                            maxLines: 8,
                            overflow: TextOverflow.ellipsis,
                          ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text('Favorite : '),
                                buildStars(p.rating),
                              ],
                            ),
                            TextButton.icon(
                              onPressed: () async {
                                if (p.link == null || p.link.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('ไม่มีลิงก์')),
                                  );
                                  return;
                                }

                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('เปิดลิงก์ภายนอก'),
                                    content: Text(
                                      'คุณต้องการเปิดลิงก์นี้หรือไม่?\n\n${p.link}',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(ctx).pop(); // ปิด dialog
                                        },
                                        child: const Text('ยกเลิก'),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blueAccent,
                                        ),
                                        onPressed: () async {
                                          Navigator.of(
                                            ctx,
                                          ).pop(); // ปิด dialog ก่อนเปิดลิงก์
                                          final Uri url = Uri.parse(p.link);
                                          try {
                                            await launchUrl(url);
                                          } catch (e) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'เปิดลิงก์ไม่สำเร็จ',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        child: const Text(
                                          'เปิดลิงก์',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.link,
                                color: Colors.blueAccent,
                              ),
                              label: const Text(
                                'เปิดลิงก์',
                                style: TextStyle(
                                  color: Colors.blueAccent,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
