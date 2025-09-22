import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'posts_provider.dart';

// Timer state for individual posts
class PostTimer {
  final int postId;
  final int remainingTime;
  final bool isActive;
  final bool isPaused;

  const PostTimer({
    required this.postId,
    required this.remainingTime,
    required this.isActive,
    required this.isPaused,
  });

  PostTimer copyWith({
    int? postId,
    int? remainingTime,
    bool? isActive,
    bool? isPaused,
  }) {
    return PostTimer(
      postId: postId ?? this.postId,
      remainingTime: remainingTime ?? this.remainingTime,
      isActive: isActive ?? this.isActive,
      isPaused: isPaused ?? this.isPaused,
    );
  }
}

// Timer manager to handle multiple post timers
class TimerManager extends StateNotifier<Map<int, PostTimer>> {
  final Ref _ref;
  final Map<int, Timer> _timers = {};

  TimerManager(this._ref) : super({});

  // Start timer for a post
  void startTimer(int postId, int duration) {
    // Cancel existing timer if any
    _timers[postId]?.cancel();

    // Create new timer state
    final newState = Map<int, PostTimer>.from(state);
    newState[postId] = PostTimer(
      postId: postId,
      remainingTime: duration,
      isActive: true,
      isPaused: false,
    );
    state = newState;
    
    if (kDebugMode) {
      debugPrint('Timer started for post $postId with duration $duration');
    }

    // Start the actual timer
    _timers[postId] = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentTimer = state[postId];
      if (currentTimer == null || currentTimer.isPaused) return;

      final newRemainingTime = currentTimer.remainingTime - 1;

      if (newRemainingTime <= 0) {
        // Timer finished
        timer.cancel();
        _timers.remove(postId);
        state = Map.from(state)..remove(postId);
        
        // Update post timer in the posts provider
        _ref.read(postsProvider.notifier).updatePostTimer(
          postId: postId,
          remainingTime: 0,
          isTimerPaused: true,
        );
      } else {
        // Update timer state
        final newState = Map<int, PostTimer>.from(state);
        newState[postId] = currentTimer.copyWith(remainingTime: newRemainingTime);
        state = newState;
        
        if (kDebugMode) {
          debugPrint('Timer update: Post $postId - ${newRemainingTime}s remaining');
        }

        // Update post timer in the posts provider every 5 seconds to reduce storage writes
        if (newRemainingTime % 5 == 0) {
          _ref.read(postsProvider.notifier).updatePostTimer(
            postId: postId,
            remainingTime: newRemainingTime,
          );
        }
      }
    });
  }

  // Pause timer for a post
  void pauseTimer(int postId) {
    final currentTimer = state[postId];
    if (currentTimer != null && currentTimer.isActive) {
      final newState = Map<int, PostTimer>.from(state);
      newState[postId] = currentTimer.copyWith(isPaused: true);
      state = newState;

      // Update post timer in the posts provider
      _ref.read(postsProvider.notifier).updatePostTimer(
        postId: postId,
        remainingTime: currentTimer.remainingTime,
        isTimerPaused: true,
      );
    }
  }

  // Resume timer for a post
  void resumeTimer(int postId) {
    final currentTimer = state[postId];
    if (currentTimer != null && currentTimer.isPaused) {
      final newState = Map<int, PostTimer>.from(state);
      newState[postId] = currentTimer.copyWith(isPaused: false);
      state = newState;

      // Update post timer in the posts provider
      _ref.read(postsProvider.notifier).updatePostTimer(
        postId: postId,
        isTimerPaused: false,
      );
    }
  }

  // Stop timer for a post
  void stopTimer(int postId) {
    _timers[postId]?.cancel();
    _timers.remove(postId);
    state = Map.from(state)..remove(postId);

    // Update post timer in the posts provider
    _ref.read(postsProvider.notifier).updatePostTimer(
      postId: postId,
      isTimerPaused: true,
    );
  }

  // Initialize timer from post state (when loading from storage)
  void initializeTimerFromPost(int postId, int remainingTime, bool isPaused) {
    if (remainingTime > 0 && !isPaused) {
      startTimer(postId, remainingTime);
    } else {
      final newState = Map<int, PostTimer>.from(state);
      newState[postId] = PostTimer(
        postId: postId,
        remainingTime: remainingTime,
        isActive: remainingTime > 0,
        isPaused: isPaused,
      );
      state = newState;
    }
  }

  // Get timer for a specific post
  PostTimer? getTimer(int postId) {
    return state[postId];
  }

  // Check if timer is active for a post
  bool isTimerActive(int postId) {
    final timer = state[postId];
    return timer != null && timer.isActive && !timer.isPaused;
  }

  // Dispose all timers
  @override
  void dispose() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    super.dispose();
  }
}

// Timer manager provider
final timerManagerProvider = StateNotifierProvider<TimerManager, Map<int, PostTimer>>((ref) {
  return TimerManager(ref);
});

// Provider to get timer for a specific post
final postTimerProvider = Provider.family<PostTimer?, int>((ref, postId) {
  final timers = ref.watch(timerManagerProvider);
  return timers[postId];
});

// Provider to check if a post timer is active
final isPostTimerActiveProvider = Provider.family<bool, int>((ref, postId) {
  final timer = ref.watch(postTimerProvider(postId));
  return timer != null && timer.isActive && !timer.isPaused;
});

// Provider to get remaining time for a post
final postRemainingTimeProvider = Provider.family<int, int>((ref, postId) {
  final timer = ref.watch(postTimerProvider(postId));
  return timer?.remainingTime ?? 0;
});