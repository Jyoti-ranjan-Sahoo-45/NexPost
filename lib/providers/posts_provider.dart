import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

// API service provider
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// Posts state class
class PostsState {
  final List<Post> posts;
  final bool isLoading;
  final String? error;
  final bool isRefreshing;

  const PostsState({
    this.posts = const [],
    this.isLoading = false,
    this.error,
    this.isRefreshing = false,
  });

  PostsState copyWith({
    List<Post>? posts,
    bool? isLoading,
    String? error,
    bool? isRefreshing,
  }) {
    return PostsState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

// Posts notifier
class PostsNotifier extends StateNotifier<PostsState> {
  final ApiService _apiService;

  PostsNotifier(this._apiService) : super(const PostsState()) {
    _loadInitialData();
  }

  // Load initial data (from storage first, then API)
  Future<void> _loadInitialData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // First, try to load from storage
      final storedPosts = StorageService.getAllPosts();
      
      if (storedPosts.isNotEmpty) {
        state = state.copyWith(posts: storedPosts, isLoading: false);
        // Fetch fresh data in background
        _refreshPostsInBackground();
      } else {
        // No stored data, fetch from API
        await _fetchPostsFromApi();
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load posts: ${e.toString()}',
      );
    }
  }

  // Fetch posts from API
  Future<void> _fetchPostsFromApi() async {
    try {
      final apiPosts = await _apiService.fetchPosts();
      
      // Merge with existing posts to preserve read states and timer states
      final List<Post> updatedPosts = _mergePosts(state.posts, apiPosts);
      
      // Save to storage
      await StorageService.savePosts(updatedPosts);
      
      state = state.copyWith(
        posts: updatedPosts,
        isLoading: false,
        isRefreshing: false,
        error: null,
      );
    } catch (e) {
      String errorMessage;
      if (e is ApiException) {
        errorMessage = e.message;
      } else {
        errorMessage = 'Failed to fetch posts: ${e.toString()}';
      }
      
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        error: errorMessage,
      );
    }
  }

  // Refresh posts in background
  Future<void> _refreshPostsInBackground() async {
    state = state.copyWith(isRefreshing: true);
    await _fetchPostsFromApi();
  }

  // Public method to refresh posts
  Future<void> refreshPosts() async {
    await _refreshPostsInBackground();
  }

  // Retry loading posts
  Future<void> retry() async {
    await _loadInitialData();
  }

  // Mark post as read
  Future<void> markPostAsRead(int postId) async {
    try {
      final updatedPosts = state.posts.map((post) {
        if (post.id == postId) {
          return post.copyWith(isRead: true);
        }
        return post;
      }).toList();

      state = state.copyWith(posts: updatedPosts);
      
      // Update in storage
      await StorageService.markPostAsRead(postId);
    } catch (e) {
      // Handle error but don't show to user as this is a background operation
      debugPrint('Error marking post as read: $e');
    }
  }

  // Update post timer
  Future<void> updatePostTimer({
    required int postId,
    int? remainingTime,
    bool? isTimerPaused,
  }) async {
    try {
      final updatedPosts = state.posts.map((post) {
        if (post.id == postId) {
          return post.copyWith(
            remainingTime: remainingTime ?? post.remainingTime,
            isTimerPaused: isTimerPaused ?? post.isTimerPaused,
          );
        }
        return post;
      }).toList();

      state = state.copyWith(posts: updatedPosts);
      
      // Update in storage
      await StorageService.updatePostTimer(
        postId: postId,
        remainingTime: remainingTime,
        isTimerPaused: isTimerPaused,
      );
    } catch (e) {
      // Handle error but don't show to user as this is a background operation
      debugPrint('Error updating post timer: $e');
    }
  }

  // Merge API posts with existing posts to preserve local state
  List<Post> _mergePosts(List<Post> existingPosts, List<Post> apiPosts) {
    final Map<int, Post> existingPostsMap = {
      for (final post in existingPosts) post.id: post
    };

    return apiPosts.map((apiPost) {
      final existingPost = existingPostsMap[apiPost.id];
      if (existingPost != null) {
        // Preserve local state (isRead, timer states) but update content
        return existingPost.copyWith(
          title: apiPost.title,
          body: apiPost.body,
          userId: apiPost.userId,
          // Keep existing timerDuration if it exists, otherwise use API post's
          timerDuration: existingPost.timerDuration != 10 ? 
                          existingPost.timerDuration : apiPost.timerDuration,
        );
      } else {
        // New post from API
        return apiPost;
      }
    }).toList();
  }

  // Get post by ID
  Post? getPostById(int postId) {
    try {
      return state.posts.firstWhere((post) => post.id == postId);
    } catch (e) {
      return null;
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Posts provider
final postsProvider = StateNotifierProvider<PostsNotifier, PostsState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return PostsNotifier(apiService);
});

// Individual post provider
final postProvider = Provider.family<Post?, int>((ref, postId) {
  final postsState = ref.watch(postsProvider);
  return postsState.posts.where((post) => post.id == postId).firstOrNull;
});

// Provider to get unread posts count
final unreadPostsCountProvider = Provider<int>((ref) {
  final postsState = ref.watch(postsProvider);
  return postsState.posts.where((post) => !post.isRead).length;
});

// Provider to check if posts are loading
final isLoadingProvider = Provider<bool>((ref) {
  final postsState = ref.watch(postsProvider);
  return postsState.isLoading;
});

// Provider to check if posts are refreshing
final isRefreshingProvider = Provider<bool>((ref) {
  final postsState = ref.watch(postsProvider);
  return postsState.isRefreshing;
});

// Provider to get error message
final errorProvider = Provider<String?>((ref) {
  final postsState = ref.watch(postsProvider);
  return postsState.error;
});