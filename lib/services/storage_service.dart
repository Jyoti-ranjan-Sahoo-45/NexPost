import 'package:hive_flutter/hive_flutter.dart';
import '../models/post.dart';

class StorageService {
  static const String _postsBoxName = 'posts';
  static Box<Post>? _postsBox;

  // Initialize Hive and register adapters
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register the Post adapter
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PostAdapter());
    }
    
    // Open the posts box
    _postsBox = await Hive.openBox<Post>(_postsBoxName);
  }

  // Get all posts from storage
  static List<Post> getAllPosts() {
    if (_postsBox == null) {
      throw Exception('Storage not initialized. Call StorageService.init() first.');
    }
    return _postsBox!.values.toList();
  }

  // Save a single post
  static Future<void> savePost(Post post) async {
    if (_postsBox == null) {
      throw Exception('Storage not initialized. Call StorageService.init() first.');
    }
    await _postsBox!.put(post.id, post);
  }

  // Save multiple posts
  static Future<void> savePosts(List<Post> posts) async {
    if (_postsBox == null) {
      throw Exception('Storage not initialized. Call StorageService.init() first.');
    }
    
    final Map<int, Post> postsMap = {};
    for (final post in posts) {
      postsMap[post.id] = post;
    }
    await _postsBox!.putAll(postsMap);
  }

  // Get a specific post by ID
  static Post? getPost(int postId) {
    if (_postsBox == null) {
      throw Exception('Storage not initialized. Call StorageService.init() first.');
    }
    return _postsBox!.get(postId);
  }

  // Update a post's read status
  static Future<void> markPostAsRead(int postId) async {
    if (_postsBox == null) {
      throw Exception('Storage not initialized. Call StorageService.init() first.');
    }
    
    final post = _postsBox!.get(postId);
    if (post != null) {
      final updatedPost = post.copyWith(isRead: true);
      await _postsBox!.put(postId, updatedPost);
    }
  }

  // Update post timer state
  static Future<void> updatePostTimer({
    required int postId,
    int? remainingTime,
    bool? isTimerPaused,
  }) async {
    if (_postsBox == null) {
      throw Exception('Storage not initialized. Call StorageService.init() first.');
    }
    
    final post = _postsBox!.get(postId);
    if (post != null) {
      final updatedPost = post.copyWith(
        remainingTime: remainingTime,
        isTimerPaused: isTimerPaused,
      );
      await _postsBox!.put(postId, updatedPost);
    }
  }

  // Clear all posts
  static Future<void> clearAllPosts() async {
    if (_postsBox == null) {
      throw Exception('Storage not initialized. Call StorageService.init() first.');
    }
    await _postsBox!.clear();
  }

  // Check if posts exist in storage
  static bool hasStoredPosts() {
    if (_postsBox == null) {
      return false;
    }
    return _postsBox!.isNotEmpty;
  }

  // Get posts count
  static int getPostsCount() {
    if (_postsBox == null) {
      return 0;
    }
    return _postsBox!.length;
  }

  // Close storage (call when app is terminating)
  static Future<void> close() async {
    await _postsBox?.close();
    await Hive.close();
  }
}