import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/forum_model.dart';
import '../services/forum_service.dart';
import '../services/auth_service.dart';
import '../widgets/forum_card.dart';
import 'forum_detail_screen.dart';
import 'create_forum_screen.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({Key? key}) : super(key: key);

  @override
  _ForumScreenState createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  bool _isLoading = true;
  List<Forum> _forums = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();
  String _sortBy = 'created_at';
  String _order = 'desc';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      _loadForumsAfterBuild();
    }
  }

  void _loadForumsAfterBuild() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadForums();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _loadMoreForums();
    }
  }

  String _getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';

    if (imagePath.startsWith('http')) return imagePath;

    const String baseUrl = 'http://192.168.0.101:5000';

    if (imagePath.startsWith('/static')) {
      return '$baseUrl$imagePath';
    }

    return '$baseUrl/static/uploads/$imagePath';
  }

  Future<void> _loadForums() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _currentPage = 1;
    });

    try {
      final forumService = Provider.of<ForumService>(context, listen: false);
      final response = await forumService.getForums(
        page: _currentPage,
        perPage: 10,
        sortBy: _sortBy,
        order: _order,
      );

      if (!mounted) return;

      setState(() {
        _forums = response.forums;
        _totalPages = response.pages;
        _hasMore = _currentPage < _totalPages;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showErrorSnackBar('Error loading forums: $e');
    }
  }

  Future<void> _loadMoreForums() async {
    if (_isLoading || !mounted) return;

    setState(() {
      _isLoading = true;
      _currentPage++;
    });

    try {
      final forumService = Provider.of<ForumService>(context, listen: false);
      final response = await forumService.getForums(
        page: _currentPage,
        perPage: 10,
        sortBy: _sortBy,
        order: _order,
      );

      if (!mounted) return;

      setState(() {
        _forums.addAll(response.forums);
        _hasMore = _currentPage < _totalPages;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _currentPage--;
        _isLoading = false;
      });

      _showErrorSnackBar('Error loading more forums: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _refreshForums() async {
    return _loadForums();
  }

  void _changeSorting(String sortBy, String order) {
    setState(() {
      _sortBy = sortBy;
      _order = order;
    });
    _loadForums();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        final isAuthenticated = authService.isAuthenticated;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Forum'),
            elevation: 0,
            actions: [
              PopupMenuButton<Map<String, String>>(
                icon: const Icon(Icons.sort),
                tooltip: 'Sort forums',
                onSelected: (value) {
                  _changeSorting(value['sortBy']!, value['order']!);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: {'sortBy': 'created_at', 'order': 'desc'},
                    child: Row(
                      children: [
                        Icon(Icons.access_time, size: 20),
                        SizedBox(width: 8),
                        Text('Newest First'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: {'sortBy': 'created_at', 'order': 'asc'},
                    child: Row(
                      children: [
                        Icon(Icons.history, size: 20),
                        SizedBox(width: 8),
                        Text('Oldest First'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: {'sortBy': 'likes', 'order': 'desc'},
                    child: Row(
                      children: [
                        Icon(Icons.thumb_up, size: 20),
                        SizedBox(width: 8),
                        Text('Most Liked'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _refreshForums,
            child: _buildForumList(isAuthenticated),
          ),
          floatingActionButton: isAuthenticated
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CreateForumScreen()),
                    ).then((_) => _refreshForums());
                  },
                  child: const Icon(Icons.add),
                  tooltip: 'Create Forum',
                  elevation: 4,
                )
              : null,
        );
      },
    );
  }

  Widget _buildForumList(bool isAuthenticated) {
    if (_isLoading && _forums.isEmpty) {
      return _buildLoadingIndicator();
    }

    if (_forums.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      itemCount: _forums.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _forums.length) {
          return _buildLoadMoreIndicator();
        }

        final forum = _forums[index];
        return ForumCard(
          forum: forum,
          getFullImageUrl: _getFullImageUrl,
          onTap: () => _navigateToForumDetail(forum.id),
          onLike: isAuthenticated ? () => _handleLike(forum.id, true) : null,
          onDislike:
              isAuthenticated ? () => _handleLike(forum.id, false) : null,
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading forums...',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.forum_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No forums available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to create a discussion',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  void _navigateToForumDetail(int forumId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ForumDetailScreen(forumId: forumId),
      ),
    ).then((_) => _refreshForums());
  }

  Future<void> _handleLike(int forumId, bool isLike) async {
    try {
      final forumService = Provider.of<ForumService>(context, listen: false);
      await forumService.toggleLike(forumId, isLike);
      _refreshForums();
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    }
  }
}
