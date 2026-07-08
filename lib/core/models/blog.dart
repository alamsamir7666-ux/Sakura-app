class BlogPost {
  final int id;
  final String title;
  final String slug;
  final String excerpt;
  final String content;
  final String? coverImage;
  final String? author;
  final List<String> tags;
  final String createdAt;
  final String updatedAt;

  const BlogPost({
    required this.id,
    required this.title,
    required this.slug,
    required this.excerpt,
    required this.content,
    this.coverImage,
    this.author,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BlogPost.fromJson(Map<String, dynamic> json) {
    return BlogPost(
      id: json['id'] as int,
      title: json['title'] as String,
      slug: json['slug'] as String,
      excerpt: json['excerpt'] as String,
      content: json['content'] as String,
      coverImage: json['coverImage'] as String?,
      author: json['author'] as String?,
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}
