import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../models/post.dart';
import '../providers/posts_provider.dart';
import '../providers/timer_provider.dart';
import '../widgets/post_item.dart';
import 'post_detail_screen.dart';

class PostsListScreen extends ConsumerStatefulWidget {
  const PostsListScreen({super.key});

  @override
  ConsumerState<PostsListScreen> createState() => _PostsListScreenState();
}

class _PostsListScreenState extends ConsumerState<PostsListScreen> {
  @override
  Widget build(BuildContext context) {
    final postsState = ref.watch(postsProvider);
    final isRefreshing = ref.watch(isRefreshingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'NexPost',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          if (isRefreshing)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(postsState),
    );
  }

  Widget _buildBody(PostsState postsState) {
    if (postsState.isLoading && postsState.posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.blue[600],
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            Text(
              'Loading posts...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Fetching the latest content for you',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    if (postsState.error != null && postsState.posts.isEmpty) {
      return _buildErrorState(postsState.error!);
    }

    if (postsState.posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.post_add_rounded,
                size: 60,
                color: Colors.blue[300],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No posts available',
              style: TextStyle(
                fontSize: 22,
                color: Colors.grey[700],
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Pull down to refresh and load posts',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue[600],
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Pull to refresh',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(postsProvider.notifier).refreshPosts();
      },
      color: Colors.blue[600],
      backgroundColor: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        itemCount: postsState.posts.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final post = postsState.posts[index];
          return _buildPostItem(post, index);
        },
      ),
    );
  }

  Widget _buildPostItem(Post post, int index) {
    return VisibilityDetector(
      key: Key('post_${post.id}'),
      onVisibilityChanged: (info) {
        _handlePostVisibility(post.id, info.visibleFraction);
      },
      child: PostItem(
        post: post,
        onTap: () => _navigateToPostDetail(post),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(postsProvider.notifier).retry();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePostVisibility(int postId, double visibleFraction) {
    final timerManager = ref.read(timerManagerProvider.notifier);
    final post = ref.read(postProvider(postId));
    
    if (kDebugMode) {
      debugPrint('Visibility: Post $postId - ${(visibleFraction * 100).toInt()}% visible');
    }
    
    if (post == null) {
      if (kDebugMode) {
        debugPrint('Post $postId is null, returning');
      }
      return;
    }

    // Start timer when post becomes visible (threshold: 50%)
    if (visibleFraction >= 0.5) {
      if (kDebugMode) {
        debugPrint('Post $postId is visible (>= 50%)');
      }
      final existingTimer = timerManager.getTimer(postId);
      if (kDebugMode) {
        debugPrint('Existing timer for post $postId: $existingTimer');
      }
      
      if (existingTimer == null) {
        if (kDebugMode) {
          debugPrint('No existing timer. Post data - remainingTime: ${post.remainingTime}, timerDuration: ${post.timerDuration}, isPaused: ${post.isTimerPaused}');
        }
        // Initialize timer from post state or start new one
        if (post.remainingTime > 0 && !post.isTimerPaused) {
          if (kDebugMode) {
            debugPrint('Starting timer with remaining time: ${post.remainingTime}');
          }
          timerManager.startTimer(postId, post.remainingTime);
        } else if (post.remainingTime > 0 && post.isTimerPaused) {
          if (kDebugMode) {
            debugPrint('Initializing paused timer');
          }
          timerManager.initializeTimerFromPost(
            postId,
            post.remainingTime,
            post.isTimerPaused,
          );
        } else if (post.remainingTime == post.timerDuration) {
          if (kDebugMode) {
            debugPrint('Fresh post, starting timer with duration: ${post.timerDuration}');
          }
          timerManager.startTimer(postId, post.timerDuration);
        }
      } else if (existingTimer.isPaused && post.remainingTime > 0) {
        if (kDebugMode) {
          debugPrint('Resuming paused timer');
        }
        timerManager.resumeTimer(postId);
      }
    } else if (visibleFraction < 0.5) {
      if (kDebugMode) {
        debugPrint('Post $postId is not visible (< 50%)');
      }
      final existingTimer = timerManager.getTimer(postId);
      if (existingTimer != null && existingTimer.isActive && !existingTimer.isPaused) {
        if (kDebugMode) {
          debugPrint('Pausing timer for post $postId');
        }
        timerManager.pauseTimer(postId);
      }
    }
  }

  void _navigateToPostDetail(Post post) {
    // Pause timer when navigating to detail
    final timerManager = ref.read(timerManagerProvider.notifier);
    timerManager.pauseTimer(post.id);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(postId: post.id),
      ),
    ).then((_) {
      // Resume timer when coming back from detail (if post is still visible)
      // The visibility detector will handle this automatically
    });
  }
}