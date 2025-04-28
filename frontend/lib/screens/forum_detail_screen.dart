import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/forum_model.dart';
import '../models/comment_model.dart';
import '../services/auth_service.dart';
import '../services/forum_service.dart';

class ForumDetailScreen extends StatefulWidget {
  final int forumId;

  const ForumDetailScreen({
    Key? key,
    required this.forumId,
  }) : super(key: key);

  @override
  _ForumDetailScreenState createState() => _ForumDetailScreenState();
}

class _ForumDetailScreenState extends State<ForumDetailScreen> {
  bool _isLoading = true;
  Forum? _forum;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmittingComment = false;

  @override
  void initState() {
    super.initState();
    // Gunakan addPostFrameCallback untuk memastikan widget sudah dibangun
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadForumDetails();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // Fungsi untuk mendapatkan URL gambar lengkap
  String _getFullImageUrl(String? imagePath) {
    if (imagePath == null) return '';

    // Jika imagePath sudah berupa URL lengkap, gunakan apa adanya
    if (imagePath.startsWith('http')) return imagePath;

    // Jika tidak, tambahkan baseUrl
    const String baseUrl = 'http://192.168.0.103:5000';

    // Jika imagePath dimulai dengan '/static', tambahkan baseUrl saja
    if (imagePath.startsWith('/static')) {
      return '$baseUrl$imagePath';
    }

    // Jika imagePath hanya nama file, tambahkan path lengkap
    return '$baseUrl/static/uploads/$imagePath';
  }

  Future<void> _loadForumDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final forumService = Provider.of<ForumService>(context, listen: false);
      final forum = await forumService.getForumDetails(widget.forumId);

      setState(() {
        _forum = forum;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading forum details: $e')),
      );
    }
  }

  Future<void> _submitComment() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) return;

    setState(() {
      _isSubmittingComment = true;
    });

    try {
      final forumService = Provider.of<ForumService>(context, listen: false);
      await forumService.addComment(widget.forumId, comment);

      _commentController.clear();
      await _loadForumDetails();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding comment: $e')),
      );
    } finally {
      setState(() {
        _isSubmittingComment = false;
      });
    }
  }

  Future<void> _toggleLike(bool isLike) async {
    try {
      final forumService = Provider.of<ForumService>(context, listen: false);
      await forumService.toggleLike(widget.forumId, isLike);
      await _loadForumDetails();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _deleteForum() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Forum'),
        content: const Text('Are you sure you want to delete this forum?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final forumService = Provider.of<ForumService>(context, listen: false);
        await forumService.deleteForum(widget.forumId);
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting forum: $e')),
        );
      }
    }
  }

  void _navigateToEditScreen() {
    // Implementasi navigasi ke layar edit
    if (_forum == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditForumScreen(forum: _forum!),
      ),
    ).then((result) {
      if (result == true) {
        _loadForumDetails();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final isAuthenticated = authService.isAuthenticated;
    final currentUser = authService.currentUser;
    final isOwner = _forum != null &&
        currentUser != null &&
        _forum!.userId == currentUser.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forum Detail'),
        actions: [
          if (isOwner)
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
              onSelected: (value) async {
                if (value == 'edit') {
                  _navigateToEditScreen();
                } else if (value == 'delete') {
                  _deleteForum();
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _forum == null
              ? const Center(child: Text('Forum not found'))
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Forum content
                            Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          child: Text(_forum!.username
                                              .substring(0, 1)
                                              .toUpperCase()),
                                        ),
                                        const SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _forum!.username,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              _formatDate(_forum!.createdAt),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _forum!.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(_forum!.description),
                                    if (_forum!.imagePath != null) ...[
                                      const SizedBox(height: 16),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          _getFullImageUrl(_forum!.imagePath),
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            print(
                                                'Error loading image: $error');
                                            return Container(
                                              width: double.infinity,
                                              height: 200,
                                              color: Colors.grey.shade200,
                                              child: const Icon(
                                                  Icons.broken_image,
                                                  size: 50),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        if (isAuthenticated) ...[
                                          IconButton(
                                            icon: Icon(
                                              Icons.thumb_up,
                                              color: _forum!.userLikeStatus ==
                                                      'like'
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                  : Colors.grey,
                                            ),
                                            onPressed: () => _toggleLike(true),
                                          ),
                                          Text('${_forum!.likeCount}'),
                                          const SizedBox(width: 16),
                                          IconButton(
                                            icon: Icon(
                                              Icons.thumb_down,
                                              color: _forum!.userLikeStatus ==
                                                      'dislike'
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                  : Colors.grey,
                                            ),
                                            onPressed: () => _toggleLike(false),
                                          ),
                                          Text('${_forum!.dislikeCount}'),
                                        ] else ...[
                                          const Icon(Icons.thumb_up,
                                              color: Colors.grey),
                                          Text(' ${_forum!.likeCount}'),
                                          const SizedBox(width: 16),
                                          const Icon(Icons.thumb_down,
                                              color: Colors.grey),
                                          Text(' ${_forum!.dislikeCount}'),
                                        ],
                                        const Spacer(),
                                        const Icon(Icons.comment,
                                            color: Colors.grey),
                                        Text(' ${_forum!.comments.length}'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Comments section
                            Text(
                              'Comments',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            if (_forum!.comments.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child: Center(child: Text('No comments yet')),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _forum!.comments.length,
                                itemBuilder: (context, index) {
                                  final comment = _forum!.comments[index];
                                  return CommentCard(
                                    comment: comment,
                                    currentUserId: currentUser?.id,
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (isAuthenticated)
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _commentController,
                                decoration: const InputDecoration(
                                  hintText: 'Add a comment...',
                                  border: InputBorder.none,
                                ),
                                maxLines: null,
                              ),
                            ),
                            IconButton(
                              icon: _isSubmittingComment
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : Icon(
                                      Icons.send,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                              onPressed:
                                  _isSubmittingComment ? null : _submitComment,
                            ),
                          ],
                        ),
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
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

// Tambahkan class CommentCard yang sebelumnya tidak didefinisikan
class CommentCard extends StatelessWidget {
  final Comment comment;
  final int? currentUserId;

  const CommentCard({
    Key? key,
    required this.comment,
    this.currentUserId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isOwner = currentUserId != null && comment.userId == currentUserId;

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(comment.username.substring(0, 1).toUpperCase()),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.username,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _formatDate(comment.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (isOwner)
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: () {
                      // Implementasi hapus komentar
                      _showDeleteCommentDialog(context);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(comment.content),
          ],
        ),
      ),
    );
  }

  void _showDeleteCommentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Implementasi hapus komentar
              Navigator.pop(context);
              // Tambahkan kode untuk menghapus komentar
            },
            child: const Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
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
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

// Tambahkan class EditForumScreen untuk implementasi _navigateToEditScreen
class EditForumScreen extends StatefulWidget {
  final Forum forum;

  const EditForumScreen({Key? key, required this.forum}) : super(key: key);

  @override
  _EditForumScreenState createState() => _EditForumScreenState();
}

class _EditForumScreenState extends State<EditForumScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.forum.title);
    _descriptionController =
        TextEditingController(text: widget.forum.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _updateForum() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final forumService = Provider.of<ForumService>(context, listen: false);
      await forumService.updateForum(
        forumId: widget.forum.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Forum updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating forum: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Forum'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _updateForum,
                    child: const Text('Update Forum'),
                  ),
                ],
              ),
            ),
    );
  }
}
