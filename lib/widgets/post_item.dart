import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post.dart';
import '../providers/timer_provider.dart';

class PostItem extends ConsumerWidget {
  final Post post;
  final VoidCallback onTap;

  const PostItem({
    super.key,
    required this.post,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(postTimerProvider(post.id));
    final remainingTime = timer?.remainingTime ?? post.remainingTime;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
      child: Material(
        elevation: 0,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.blue.withValues(alpha: 0.1),
          highlightColor: Colors.blue.withValues(alpha: 0.05),
          child: Container(
            decoration: BoxDecoration(
              color: post.isRead ? Colors.white : Colors.yellow[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: post.isRead ? Colors.grey[200]! : Colors.yellow[200]!,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Post content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Post title
                      Text(
                        post.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[900],
                          height: 1.3,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      // Post body preview
                      Text(
                        post.body,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                          height: 1.5,
                          letterSpacing: 0.1,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      // Post metadata
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'User ${post.userId}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600],
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.tag,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '#${post.id}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600],
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!post.isRead) ...[
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue[500]!,
                                    Colors.blue[600]!,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'NEW',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Timer section
                _TimerWidget(
                  remainingTime: remainingTime,
                  isActive: timer?.isActive ?? false,
                  isPaused: timer?.isPaused ?? post.isTimerPaused,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TimerWidget extends StatelessWidget {
  final int remainingTime;
  final bool isActive;
  final bool isPaused;

  const _TimerWidget({
    required this.remainingTime,
    required this.isActive,
    required this.isPaused,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Timer icon
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _getTimerGradient(),
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _getTimerColor().withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.7),
                blurRadius: 2,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: Icon(
            Icons.timer,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(height: 10),
        // Timer text
        Text(
          _formatTime(remainingTime),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _getTimerColor(),
            letterSpacing: 0.5,
          ),
        ),
        // Timer status
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: _getTimerColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            _getStatusText(),
            style: TextStyle(
              fontSize: 9,
              color: _getTimerColor(),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ],
    );
  }

  Color _getTimerColor() {
    if (remainingTime <= 0) {
      return Colors.green[600]!;
    } else if (isPaused) {
      return Colors.orange[600]!;
    } else if (isActive) {
      return Colors.blue[600]!;
    } else {
      return Colors.grey[500]!;
    }
  }

  List<Color> _getTimerGradient() {
    if (remainingTime <= 0) {
      return [Colors.green[400]!, Colors.green[700]!];
    } else if (isPaused) {
      return [Colors.orange[400]!, Colors.orange[700]!];
    } else if (isActive) {
      return [Colors.blue[400]!, Colors.blue[700]!];
    } else {
      return [Colors.grey[400]!, Colors.grey[600]!];
    }
  }

  String _getStatusText() {
    if (remainingTime <= 0) {
      return 'DONE';
    } else if (isPaused) {
      return 'PAUSED';
    } else if (isActive) {
      return 'RUNNING';
    } else {
      return 'WAITING';
    }
  }

  String _formatTime(int seconds) {
    if (seconds <= 0) return '00:00';
    
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}