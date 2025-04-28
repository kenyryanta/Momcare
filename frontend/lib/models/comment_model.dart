// lib/models/comment_model.dart
class Comment {
  final int id;
  final String content;
  final int userId;
  final String username;
  final int forumId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Comment({
    required this.id,
    required this.content,
    required this.userId,
    required this.username,
    required this.forumId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      content: json['content'],
      userId: json['user_id'],
      username: json['username'] ?? 'Unknown',
      forumId: json['forum_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'user_id': userId,
      'username': username,
      'forum_id': forumId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class CommentResponse {
  final List<Comment> comments;
  final int total;
  final int pages;
  final int currentPage;

  CommentResponse({
    required this.comments,
    required this.total,
    required this.pages,
    required this.currentPage,
  });

  factory CommentResponse.fromJson(Map<String, dynamic> json) {
    return CommentResponse(
      comments: List<Comment>.from(
        json['comments'].map((comment) => Comment.fromJson(comment)),
      ),
      total: json['total'],
      pages: json['pages'],
      currentPage: json['current_page'],
    );
  }
}
