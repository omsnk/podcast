class Podcast {
  final int? id;
  final String title;
  final String description;
  final String category;
  final String channel;
  final String link;
  final String? thumbnailUrl;
  final int rating;

  Podcast({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.channel,
    required this.link,
    this.thumbnailUrl,
    this.rating = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'channel': channel,
      'link': link,
      'thumbnailUrl': thumbnailUrl,
      'rating': rating,
    };
  }

  factory Podcast.fromMap(Map<String, dynamic> map) {
    return Podcast(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      channel: map['channel'] ?? '',
      link: map['link'] ?? '',
      thumbnailUrl: map['thumbnailUrl'],
      rating: map['rating'] ?? 0,
    );
  }
}
