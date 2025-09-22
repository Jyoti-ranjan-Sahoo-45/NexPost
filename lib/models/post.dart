import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'post.g.dart';

@HiveType(typeId: 0)
class Post extends Equatable {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String body;

  @HiveField(3)
  final int userId;

  @HiveField(4)
  final bool isRead;

  @HiveField(5)
  final int timerDuration; // in seconds (10, 20, or 25)

  @HiveField(6)
  final int remainingTime; // current countdown value

  @HiveField(7)
  final bool isTimerPaused;

  const Post({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
    this.isRead = false,
    this.timerDuration = 10,
    int? remainingTime,
    this.isTimerPaused = false,
  }) : remainingTime = remainingTime ?? timerDuration;

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      userId: json['userId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'userId': userId,
    };
  }

  Post copyWith({
    int? id,
    String? title,
    String? body,
    int? userId,
    bool? isRead,
    int? timerDuration,
    int? remainingTime,
    bool? isTimerPaused,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      userId: userId ?? this.userId,
      isRead: isRead ?? this.isRead,
      timerDuration: timerDuration ?? this.timerDuration,
      remainingTime: remainingTime ?? this.remainingTime,
      isTimerPaused: isTimerPaused ?? this.isTimerPaused,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        body,
        userId,
        isRead,
        timerDuration,
        remainingTime,
        isTimerPaused,
      ];

  @override
  String toString() {
    return 'Post(id: $id, title: $title, body: $body, userId: $userId, '
        'isRead: $isRead, timerDuration: $timerDuration, '
        'remainingTime: $remainingTime, isTimerPaused: $isTimerPaused)';
  }
}