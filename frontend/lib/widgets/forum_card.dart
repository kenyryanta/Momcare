// lib/widgets/forum_card.dart
import 'package:flutter/material.dart';
import '../models/forum_model.dart';

class ForumCard extends StatelessWidget {
  final Forum forum;
  final VoidCallback onTap;
  final VoidCallback? onLike;
  final VoidCallback? onDislike;
  final String Function(String?)? getFullImageUrl;

  const ForumCard({
    Key? key,
    required this.forum,
    required this.onTap,
    this.onLike,
    this.onDislike,
    this.getFullImageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildTitle(context),
            _buildDescription(context),
            if (forum.imagePath != null && forum.imagePath!.isNotEmpty)
              _buildImage(),
            _buildActions(context),
            // Tambahkan Container transparan di akhir stack untuk memastikan
            // seluruh area dapat disentuh, berdasarkan solusi dari hasil pencarian
            Container(color: Colors.transparent),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              forum.username.isNotEmpty
                  ? forum.username.substring(0, 1).toUpperCase()
                  : '?',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  forum.username,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  _formatDate(forum.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        forum.title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        forum.description,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildImage() {
    return Image.network(
      getFullImageUrl != null
          ? getFullImageUrl!(forum.imagePath)
          : forum.imagePath!,
      width: double.infinity,
      height: 200,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('Error loading image: $error for path: ${forum.imagePath}');
        return Container(
          width: double.infinity,
          height: 200,
          color: Colors.grey.shade200,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, size: 50, color: Colors.grey),
                SizedBox(height: 8),
                Text('Image not available',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Perbaikan untuk tombol like - gunakan Material untuk efek ripple dan area sentuh yang lebih besar
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onLike,
              borderRadius: BorderRadius.circular(8),
              // Memperbesar area sentuh
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.thumb_up,
                      size: 20, // Ukuran ikon diperbesar
                      color: forum.userLikeStatus == 'like'
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${forum.likeCount}',
                      style: TextStyle(
                        color: forum.userLikeStatus == 'like'
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                        fontWeight: forum.userLikeStatus == 'like'
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Perbaikan untuk tombol dislike
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onDislike,
              borderRadius: BorderRadius.circular(8),
              // Memperbesar area sentuh
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.thumb_down,
                      size: 20, // Ukuran ikon diperbesar
                      color: forum.userLikeStatus == 'dislike'
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${forum.dislikeCount}',
                      style: TextStyle(
                        color: forum.userLikeStatus == 'dislike'
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                        fontWeight: forum.userLikeStatus == 'dislike'
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Icon(
                Icons.comment,
                size: 18,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                '${forum.commentCount}',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        final minutes = difference.inMinutes;
        return minutes <= 0 ? 'Just now' : '$minutes minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
