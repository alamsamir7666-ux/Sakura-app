import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/blog.dart';
import '../../shared/widgets/common_widgets.dart';

class BlogScreen extends StatelessWidget {
  const BlogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final posts = _getSamplePosts();

    return Scaffold(
      appBar: AppBar(title: const Text('Sakura Blog')),
      body: posts.isEmpty
          ? EmptyState(
              icon: Icons.article_outlined,
              title: 'No posts yet',
              subtitle: 'Skincare tips and news coming soon',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return GestureDetector(
                  onTap: () => context.push('/blog/${post.id}'),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryPink.withOpacity(0.06),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (post.coverImage != null)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16)),
                            child: CachedNetworkImage(
                              imageUrl: post.coverImage!,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) =>
                                  Container(
                                height: 180,
                                color: AppTheme.secondaryPink
                                    .withOpacity(0.2),
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 6,
                                children: post.tags
                                    .map((t) => Chip(
                                          label: Text(t,
                                              style: const TextStyle(
                                                  fontSize: 10)),
                                          materialTapTargetSize:
                                              MaterialTapTargetSize
                                                  .shrinkWrap,
                                          padding:
                                              const EdgeInsets.all(0),
                                          visualDensity:
                                              VisualDensity.compact,
                                        ))
                                    .toList(),
                              ),
                              const SizedBox(height: 8),
                              Text(post.title,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text(post.excerpt,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: AppTheme.warmGray,
                                      fontSize: 13)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      size: 12,
                                      color: AppTheme.warmGray),
                                  const SizedBox(width: 4),
                                  Text(
                                      post.createdAt
                                          .substring(0, 10),
                                      style: const TextStyle(
                                          color: AppTheme.warmGray,
                                          fontSize: 11)),
                                  if (post.author != null) ...[
                                    const SizedBox(width: 16),
                                    const Icon(Icons.person,
                                        size: 12,
                                        color: AppTheme.warmGray),
                                    const SizedBox(width: 4),
                                    Text(post.author!,
                                        style: const TextStyle(
                                            color:
                                                AppTheme.warmGray,
                                            fontSize: 11)),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  List<BlogPost> _getSamplePosts() {
    return [
      BlogPost(
        id: 1,
        title: 'The Ultimate Japanese Skincare Routine',
        slug: 'japanese-skincare-routine',
        excerpt:
            'Discover the secrets of the Japanese skincare routine and how to adapt it for glowing skin.',
        content: '',
        author: 'Sakura Team',
        tags: ['Skincare', 'Routine', 'Tips'],
        createdAt: '2026-06-15T00:00:00Z',
        updatedAt: '2026-06-15T00:00:00Z',
      ),
      BlogPost(
        id: 2,
        title: 'Top 5 Ingredients in Japanese Beauty Products',
        slug: 'top-ingredients',
        excerpt:
            'From rice bran to green tea, explore the natural ingredients that make Japanese skincare so effective.',
        content: '',
        author: 'Sakura Team',
        tags: ['Ingredients', 'Natural', 'Guide'],
        createdAt: '2026-06-10T00:00:00Z',
        updatedAt: '2026-06-10T00:00:00Z',
      ),
      BlogPost(
        id: 3,
        title: 'Seasonal Skincare: Adapting to Summer Humidity',
        slug: 'seasonal-skincare-summer',
        excerpt:
            'How to adjust your skincare routine for the humid summer months with lightweight Japanese products.',
        content: '',
        author: 'Sakura Team',
        tags: ['Seasonal', 'Summer', 'Tips'],
        createdAt: '2026-06-01T00:00:00Z',
        updatedAt: '2026-06-01T00:00:00Z',
      ),
    ];
  }
}
