import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/storage_service.dart';
import 'screens/splash_screen.dart';
import 'screens/posts_list_screen.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Hive storage
    await StorageService.init();
    
    // Run the app
    runApp(const ProviderScope(child: NexPostApp()));
  } catch (e) {
    // If initialization fails, run app without storage
    debugPrint('Failed to initialize storage: $e');
    runApp(const ProviderScope(child: NexPostApp()));
  }
}

class NexPostApp extends StatefulWidget {
  const NexPostApp({super.key});

  @override
  State<NexPostApp> createState() => _NexPostAppState();
}

class _NexPostAppState extends State<NexPostApp> {
  bool _isInitialized = false;

  void _onInitializationComplete() {
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NexPost',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Enhanced color scheme
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        
        // Polished app bar theme
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          toolbarHeight: 64,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        
        // Enhanced card theme
        cardTheme: CardThemeData(
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        ),
        
        // Polished button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: Colors.blue.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 16,
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
        
        // Enhanced text theme with better typography
        textTheme: TextTheme(
          headlineSmall: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 24,
            color: Colors.grey[900],
            letterSpacing: -0.5,
          ),
          titleLarge: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.grey[800],
            letterSpacing: -0.2,
          ),
          titleMedium: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.grey[800],
            letterSpacing: 0.1,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
            height: 1.5,
            letterSpacing: 0.1,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            height: 1.4,
            letterSpacing: 0.2,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
        
        // Background color
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        
        // Use Material 3 design
        useMaterial3: true,
      ),
      
      // Set the home screen based on initialization state
      home: _isInitialized 
        ? const PostsListScreen()
        : SplashScreen(onInitializationComplete: _onInitializationComplete),
    );
  }
}
