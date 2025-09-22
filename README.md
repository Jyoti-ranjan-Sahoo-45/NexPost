# 📱 NexPost

**A Modern Posts Reading App with Timer Management**

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white)

---

## 🌟 Overview

NexPost is a sophisticated Flutter application that provides a modern posts reading experience with intelligent timer management. Built with clean architecture and state-of-the-art UI/UX design, it offers users an engaging way to browse and read posts with automatic time tracking.

## ✨ Features

### 🎬 **Beautiful Splash Screen**
- **Lottie Animation**: Custom animated splash using LottieFiles
- **Elegant Transitions**: Smooth fade-in effects and slide animations
- **Gradient Background**: Professional blue gradient design
- **Loading States**: Clean progress indicators with status text

### 📖 **Posts Management**
- **API Integration**: Fetches posts from JSONPlaceholder API
- **Rich Content Display**: Beautifully formatted post cards
- **Detailed View**: Full post content with optimized typography
- **Error Handling**: Graceful error states with retry functionality

### ⏱️ **Smart Timer System**
- **Visibility Detection**: Automatic timer start/pause based on post visibility
- **Persistent Storage**: Timer states saved locally using Hive
- **Real-time Updates**: Live countdown display with second precision
- **Multi-post Management**: Independent timers for multiple posts
- **Resume Capability**: Timers resume from saved state on app restart

### 🎨 **Modern UI/UX**
- **Material Design 3**: Latest Material Design principles
- **Responsive Layout**: Optimized for all screen sizes
- **Dark/Light Support**: Adaptive theming (future enhancement)
- **Smooth Animations**: 60fps transitions and micro-interactions
- **Custom Icons**: Professional app icons for all platforms

## 🏗️ **Architecture & Design Patterns**

### **Clean Architecture Implementation**
NexPost follows Clean Architecture principles with clear separation of concerns:

```
┌─────────────────────────────────────────┐
│               Presentation Layer         │
│  ┌─────────────┐  ┌─────────────────┐   │
│  │   Screens   │  │     Widgets     │   │
│  └─────────────┘  └─────────────────┘   │
└─────────────────────────────────────────┘
                    │
┌─────────────────────────────────────────┐
│               Business Layer            │
│  ┌─────────────┐  ┌─────────────────┐   │
│  │  Providers  │  │     Models      │   │
│  └─────────────┘  └─────────────────┘   │
└─────────────────────────────────────────┘
                    │
┌─────────────────────────────────────────┐
│                Data Layer               │
│  ┌─────────────┐  ┌─────────────────┐   │
│  │  Services   │  │  Local Storage  │   │
│  └─────────────┘  └─────────────────┘   │
└─────────────────────────────────────────┘
```

### **State Management Architecture**
- **Riverpod**: Chosen for its compile-time safety and testing capabilities
- **Provider Pattern**: Each feature has dedicated providers (PostsProvider, TimerProvider)
- **Immutable State**: All state objects are immutable using Equatable
- **Error Boundaries**: Comprehensive error handling with AsyncError states

### **Data Flow Architecture**
1. **UI Layer** → Consumes state via Consumer widgets
2. **Provider Layer** → Manages business logic and state transformations
3. **Service Layer** → Handles data fetching and persistence
4. **Repository Pattern** → Abstracts data sources (API + Local Storage)

## 🛠️ Technical Stack

### **Core Technologies**
- **Flutter**: `3.35.4` - Cross-platform UI framework
- **Dart**: `3.9.2+` - Programming language
- **Flutter Riverpod**: `2.4.9` - State management solution

### **Third-Party Libraries & Architectural Decisions**

#### **Core Dependencies**
```yaml
dependencies:
  # State Management
  flutter_riverpod: ^2.4.9          # Reactive state management
  
  # Networking & HTTP
  dio: ^5.4.0                        # HTTP client with interceptors
  
  # Local Storage & Persistence
  hive: ^2.2.3                       # NoSQL local database
  hive_flutter: ^1.1.0              # Flutter-specific Hive integration
  
  # UI & Animation
  lottie: ^3.1.2                     # Vector animations from After Effects
  visibility_detector: ^0.4.0+2      # Widget visibility tracking
  
  # Utilities
  equatable: ^2.0.5                  # Value object equality
  cupertino_icons: ^1.0.8            # iOS-style icons
  
dev_dependencies:
  # Code Generation & Build Tools
  build_runner: ^2.4.7               # Build system for code generation
  hive_generator: ^2.0.1             # Generates TypeAdapters for Hive
  
  # Asset Generation
  flutter_launcher_icons: ^0.13.1    # Multi-platform app icon generation
  
  # Testing & Quality
  flutter_test: sdk: flutter         # Flutter testing framework
  flutter_lints: ^5.0.0              # Official Flutter linting rules
```

#### **Library Selection Rationale**

**🔄 State Management - Flutter Riverpod**
- **Why Chosen**: Compile-time safety, excellent testing support, no BuildContext dependency
- **Alternatives Considered**: Provider, BLoC, GetX
- **Benefits**: Auto-disposal, family providers for parameterized state, AsyncValue for loading states

**🌐 HTTP Client - Dio**
- **Why Chosen**: Rich feature set, interceptors, request/response transformation
- **Alternatives Considered**: http package, Chopper
- **Benefits**: Built-in error handling, timeout configuration, request cancellation

**💾 Local Storage - Hive**
- **Why Chosen**: Fast, lightweight, type-safe, no native dependencies
- **Alternatives Considered**: SQLite, SharedPreferences, Isar
- **Benefits**: No SQL overhead, automatic encryption support, lazy box loading

**🎬 Animations - Lottie**
- **Why Chosen**: Professional animations, small file sizes, cross-platform consistency
- **Alternatives Considered**: Rive, custom Flutter animations
- **Benefits**: After Effects integration, JSON format, interactive animations

**👁️ Visibility Detection - visibility_detector**
- **Why Chosen**: Precise visibility tracking, minimal performance impact
- **Alternatives Considered**: Custom scroll listeners, IntersectionObserver pattern
- **Benefits**: Callback-based API, configurable thresholds, memory efficient

### **Platform Support**
- ✅ **Android**: API level 21+
- ✅ **iOS**: iOS 12+
- ✅ **Web**: Modern browsers
- ✅ **Windows**: Windows 10+
- ✅ **macOS**: macOS 10.14+
- ✅ **Linux**: Ubuntu 20.04+

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/
│   ├── post.dart               # Post data model
│   └── post.g.dart             # Generated Hive adapter
├── providers/
│   ├── posts_provider.dart     # Posts state management
│   └── timer_provider.dart     # Timer state management
├── screens/
│   ├── splash_screen.dart      # Lottie splash screen
│   ├── posts_list_screen.dart  # Main posts listing
│   └── post_detail_screen.dart # Individual post view
├── services/
│   ├── api_service.dart        # REST API integration
│   └── storage_service.dart    # Local storage service
└── widgets/
    └── post_item.dart          # Reusable post card widget

assets/
├── lottie_splash.json          # Lottie animation file
└── icon/
    ├── app_icon.png           # App icon source
    └── icon.jpg               # Original icon file
```

## 🚀 Getting Started

### **Prerequisites**
- **Flutter SDK**: 3.9.2 or higher ([Installation Guide](https://docs.flutter.dev/get-started/install))
- **Dart SDK**: 3.9.2 or higher (comes with Flutter)
- **IDE**: Android Studio, VS Code, or IntelliJ with Flutter/Dart plugins
- **Git**: For version control
- **Device/Emulator**: Physical device or emulator for testing

### **Environment Setup**

#### **1. Verify Flutter Installation**
```bash
flutter doctor
```
Ensure all checkmarks are green or resolve any issues shown.

#### **2. Check Available Devices**
```bash
flutter devices
```
This should show connected devices or running emulators.

### **Installation & Setup**

#### **1. Clone the Repository**
```bash
git clone <repository-url>
cd knovator
```

#### **2. Install Dependencies**
```bash
flutter pub get
```

#### **3. Generate Required Code**
Generate Hive type adapters and other build artifacts:
```bash
dart run build_runner build --delete-conflicting-outputs
```

#### **4. Verify Installation**
Check for any issues:
```bash
flutter analyze
```

### **Running the Application**

#### **Development Mode (Debug)**
```bash
# Run on default device
flutter run

# Run on specific device
flutter run -d <device-id>

# Run with hot reload enabled (default in debug)
flutter run --hot
```

#### **Platform-Specific Runs**
```bash
# Android
flutter run -d android

# iOS (macOS only)
flutter run -d ios

# Web
flutter run -d web-server --web-port 8080

# Windows (Windows only)
flutter run -d windows

# macOS (macOS only)
flutter run -d macos

# Linux (Linux only)
flutter run -d linux
```

#### **Profile Mode (Performance Testing)**
```bash
flutter run --profile
```

#### **Release Mode (Production-like)**
```bash
flutter run --release
```

### **Building for Production**

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle:**
```bash
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web --release
```

## 🎯 Key Features Explained

### **Timer Management System**
- **Visibility-Based**: Timers automatically start when posts are 50%+ visible
- **Pause on Navigation**: Timers pause when navigating to detail screens
- **Persistent State**: Timer progress saved to local storage every 5 seconds
- **Resume Logic**: Timers resume from exact position on app restart

### **Data Flow Architecture**
1. **API Layer**: Dio HTTP client fetches posts from JSONPlaceholder
2. **State Layer**: Riverpod providers manage app state
3. **Storage Layer**: Hive database persists timer states locally
4. **UI Layer**: Widgets consume state via Riverpod consumers

### **Performance Optimizations**
- **Lazy Loading**: Posts loaded on-demand with proper pagination support
- **Memory Management**: Proper disposal of animation controllers and timers
- **Efficient Rendering**: Optimized widget rebuilds using Riverpod
- **Background Processing**: Timer updates don't block UI thread

## 🎨 **Detailed Architectural Decisions**

### **Design Patterns Implemented**

#### **1. Repository Pattern**
```dart
abstract class PostsRepository {
  Future<List<Post>> getPosts();
  Future<void> savePost(Post post);
}

class PostsRepositoryImpl implements PostsRepository {
  final ApiService _apiService;
  final StorageService _storageService;
  
  // Implementation combines API and local storage
}
```

#### **2. Provider Pattern (Riverpod)**
```dart
// Family providers for parameterized state
final postProvider = Provider.family<Post?, int>((ref, postId) {
  final posts = ref.watch(postsProvider);
  return posts.posts.where((p) => p.id == postId).firstOrNull;
});

// AsyncNotifier for complex state management
class PostsNotifier extends AsyncNotifier<PostsState> {
  @override
  FutureOr<PostsState> build() => _loadPosts();
}
```

#### **3. State Management Pattern**
```dart
@freezed
class PostsState with _$PostsState {
  const factory PostsState({
    required List<Post> posts,
    required bool isLoading,
    String? error,
  }) = _PostsState;
}
```

### **Key Architectural Decisions**

#### **📁 File Organization**
- **Feature-based structure**: Each feature has its own folder
- **Separation of concerns**: Models, providers, services, and UI are separate
- **Barrel exports**: Easy imports with index.dart files

#### **🔄 State Management Strategy**
- **Single source of truth**: All app state managed by Riverpod providers
- **Immutable state objects**: Using Freezed for immutable data classes
- **Reactive programming**: UI automatically updates when state changes

#### **💾 Storage Strategy**
- **Hybrid approach**: API for fresh data, Hive for persistence
- **Selective persistence**: Only timer states and user preferences stored locally
- **Type safety**: Code-generated TypeAdapters for Hive objects

#### **🎬 Animation Strategy**
- **Lottie for complex animations**: Professional splash screen
- **Flutter animations for interactions**: Smooth page transitions
- **Performance-conscious**: Animations only when beneficial to UX

#### **🐛 Error Handling Strategy**
```dart
// Centralized error handling
class AppError {
  final String message;
  final String? code;
  final StackTrace? stackTrace;
}

// Provider-level error handling
AsyncValue<PostsState> when(
  data: (data) => SuccessWidget(data),
  loading: () => LoadingWidget(),
  error: (error, stack) => ErrorWidget(error),
)
```

### **Testing Strategy**
- **Unit tests**: For business logic and utilities
- **Widget tests**: For individual components
- **Integration tests**: For complete user flows
- **Golden tests**: For visual regression testing

### **Code Quality Measures**
- **Static analysis**: flutter_lints with custom rules
- **Code generation**: Reduces boilerplate and errors
- **Type safety**: Strict typing throughout the application
- **Documentation**: Comprehensive inline documentation

## 🧪 Testing

**Run all tests:**
```bash
flutter test
```

**Run with coverage:**
```bash
flutter test --coverage
```

**Widget tests:**
```bash
flutter test test/widget_test.dart
```

## 📦 Build Assets

**Generate app icons:**
```bash
flutter pub run flutter_launcher_icons
```

**Generate splash screens:**
```bash
dart run flutter_native_splash:create
```

## 🔧 Configuration

### **API Configuration**
The app uses JSONPlaceholder API:
- **Base URL**: `https://jsonplaceholder.typicode.com`
- **Posts Endpoint**: `/posts`
- **Users Endpoint**: `/users`

### **Timer Configuration**
- **Default Duration**: 30 seconds per post
- **Visibility Threshold**: 50% of post visible
- **Storage Interval**: Every 5 seconds
- **Auto-pause**: On navigation or app backgrounding

## 🎨 Customization

### **Theme Colors**
- **Primary**: `#1976D2` (Blue)
- **Secondary**: `#1565C0` (Darker Blue)
- **Background**: `#F8FAFC` (Light Gray)
- **Surface**: `#FFFFFF` (White)

### **Typography**
- **Heading**: Roboto Bold, 24px
- **Body**: Roboto Regular, 16px
- **Caption**: Roboto Light, 14px

## 🐛 Troubleshooting

### **Common Issues**

**Build errors:**
```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

**Timer not working:**
- Ensure visibility_detector is properly configured
- Check that Hive is initialized in main.dart
- Verify timer provider is not disposed prematurely

**Lottie animation not showing:**
- Confirm `lottie_splash.json` exists in `assets/`
- Check that assets are properly declared in `pubspec.yaml`
- Verify Lottie file is valid JSON from LottieFiles

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is created for interview purposes. All rights reserved.

## 📞 Support

For questions or support, please reach out to the development team.

---

**Built with ❤️ using Flutter**
