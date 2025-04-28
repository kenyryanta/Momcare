import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/forum_model.dart';
import '../models/comment_model.dart';

class ForumService {
  static const String baseUrl = 'http://192.168.1.10:5000/api';
  final Map<String, String> headers;

  ForumService({required this.headers});

  Future<ForumResponse> getForums({
    int page = 1,
    int perPage = 10,
    String sortBy = 'created_at',
    String order = 'desc',
    int? userId,
  }) async {
    String url =
        '$baseUrl/forums?page=$page&per_page=$perPage&sort_by=$sortBy&order=$order';
    if (userId != null) {
      url += '&user_id=$userId';
    }
    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return ForumResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load forums');
    }
  }

  Future<Forum> getForumDetails(int forumId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/forums/$forumId'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return Forum.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load forum details');
    }
  }

  Future<Forum> createForum({
    required String title,
    required String description,
    File? image,
  }) async {
    if (image != null) {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/forums'),
      );
      request.headers.addAll({
        'Authorization': headers['Authorization'] ?? '',
        'Accept': 'application/json',
      });
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Forum.fromJson(data['forum']);
      } else {
        throw Exception('Failed to create forum: ${response.body}');
      }
    } else {
      final response = await http.post(
        Uri.parse('$baseUrl/forums'),
        headers: headers,
        body: json.encode({
          'title': title,
          'description': description,
        }),
      );
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Forum.fromJson(data['forum']);
      } else {
        throw Exception('Failed to create forum');
      }
    }
  }

  Future<void> updateForum({
    required int forumId,
    required String title,
    required String description,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/forums/$forumId'),
      headers: headers,
      body: json.encode({
        'title': title,
        'description': description,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update forum');
    }
  }

  Future<void> deleteForum(int forumId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/forums/$forumId'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete forum');
    }
  }

  Future<Comment> addComment(int forumId, String content) async {
    final response = await http.post(
      Uri.parse('$baseUrl/forums/$forumId/comments'),
      headers: headers,
      body: json.encode({'content': content}),
    );
    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return Comment.fromJson(data['comment']);
    } else {
      throw Exception('Failed to add comment');
    }
  }

  Future<CommentResponse> getComments(int forumId,
      {int page = 1, int perPage = 10}) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/forums/$forumId/comments?page=$page&per_page=$perPage'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return CommentResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load comments');
    }
  }

  Future<Map<String, dynamic>> toggleLike(int forumId, bool isLike) async {
    final response = await http.post(
      Uri.parse('$baseUrl/forums/$forumId/like'),
      headers: headers,
      body: json.encode({'is_like': isLike}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to process like/dislike');
    }
  }
}
