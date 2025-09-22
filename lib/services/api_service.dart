import 'dart:math';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../models/post.dart';

class ApiService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'NexPost-Flutter-Mobile/1.0.0 (Android)',
        'Accept-Encoding': 'gzip, deflate',
        'Connection': 'keep-alive',
        'Cache-Control': 'no-cache',
      },
      validateStatus: (status) {
        return status! < 500; // Accept any status code less than 500
      },
    ));

    // Configure HTTP adapter for all platforms
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      client.connectionTimeout = const Duration(seconds: 15);
      client.idleTimeout = const Duration(seconds: 15);
      return client;
    };

    // Add interceptors for logging and error handling
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: true,
      logPrint: (obj) {
        // Only print in debug mode
        if (const bool.fromEnvironment('dart.vm.product') == false) {
          debugPrint(obj.toString());
        }
      },
    ));
  }

  // Fetch all posts from the API
  Future<List<Post>> fetchPosts() async {
    try {
      final response = await _dio.get('/posts');
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = response.data;
        final List<Post> posts = jsonData.map((json) {
          final post = Post.fromJson(json);
          // Assign random timer duration (10s, 20s, or 25s)
          final timerDuration = _getRandomTimerDuration();
          return post.copyWith(
            timerDuration: timerDuration,
            remainingTime: timerDuration,
          );
        }).toList();
        
        return posts;
      } else {
        throw ApiException(
          'Failed to fetch posts',
          response.statusCode ?? 0,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ApiException('Unexpected error occurred: $e', 0);
    }
  }

  // Fetch a specific post by ID
  Future<Post> fetchPostById(int postId) async {
    try {
      final response = await _dio.get('/posts/$postId');
      
      if (response.statusCode == 200) {
        final post = Post.fromJson(response.data);
        // Assign random timer duration
        final timerDuration = _getRandomTimerDuration();
        return post.copyWith(
          timerDuration: timerDuration,
          remainingTime: timerDuration,
        );
      } else {
        throw ApiException(
          'Failed to fetch post with ID: $postId',
          response.statusCode ?? 0,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ApiException('Unexpected error occurred: $e', 0);
    }
  }

  // Get random timer duration (10, 20, or 25 seconds)
  int _getRandomTimerDuration() {
    final durations = [10, 20, 25];
    final random = Random();
    return durations[random.nextInt(durations.length)];
  }

  // Handle Dio exceptions and convert them to ApiException
  ApiException _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException('Connection timeout. Please try again.', 408);
      
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        final message = _getErrorMessageFromStatusCode(statusCode);
        return ApiException(message, statusCode);
      
      case DioExceptionType.cancel:
        return ApiException('Request cancelled', 0);
      
      case DioExceptionType.connectionError:
        return ApiException(
          'No internet connection. Please check your connection and try again.',
          0,
        );
      
      case DioExceptionType.badCertificate:
        return ApiException('Certificate verification failed', 0);
      
      case DioExceptionType.unknown:
        return ApiException(
          'Network error occurred. Please try again later.',
          0,
        );
    }
  }

  // Get user-friendly error messages based on status codes
  String _getErrorMessageFromStatusCode(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please try again.';
      case 401:
        return 'Unauthorized access.';
      case 403:
        return 'Access forbidden.';
      case 404:
        return 'Posts not found.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
        return 'Bad gateway. Server is temporarily unavailable.';
      case 503:
        return 'Service unavailable. Please try again later.';
    }
    return 'Something went wrong. Please try again.';
  }

  // Dispose method to clean up resources
  void dispose() {
    _dio.close();
  }
}

// Custom exception class for API errors
class ApiException implements Exception {
  final String message;
  final int statusCode;

  const ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException: $message (Status Code: $statusCode)';

  // Check if the error is due to network connectivity
  bool get isNetworkError => statusCode == 0;

  // Check if the error is a server error (5xx)
  bool get isServerError => statusCode >= 500 && statusCode < 600;

  // Check if the error is a client error (4xx)
  bool get isClientError => statusCode >= 400 && statusCode < 500;
}