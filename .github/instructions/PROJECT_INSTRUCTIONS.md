# 🛠️ PROJECT INSTRUCTIONS - FLUTTER/DART DEVELOPMENT STANDARDS

**Project:** Summarly - AI Content Generator  
**Framework:** Flutter 3.x  
**Language:** Dart 3.x  
**Last Updated:** November 21, 2025  

---

## 📋 TABLE OF CONTENTS

1. Project Structure
2. Coding Standards
3. Custom Widgets Library
4. Deprecated Methods & Alternatives
5. Logging Standards
6. State Management
7. Navigation
8. Error Handling
9. Testing Standards
10. Performance Best Practices
11. Security Guidelines
12. Git Workflow
13. FastAPI Backend Quick Start Guide
14. Backend Architecture & Best Practices (NEW)

---

## 1. 📁 PROJECT STRUCTURE

```
lib/
├── main.dart                          # Entry point
├── app.dart                           # App widget with theme & routing
│
├── core/
│   ├── constants/
│   │   ├── app_constants.dart         # App-wide constants
│   │   ├── api_constants.dart         # API URLs, endpoints
│   │   └── asset_constants.dart       # Asset paths
│   ├── theme/
│   │   ├── app_colors.dart            # Color palette
│   │   ├── app_text_styles.dart       # Text styles
│   │   └── app_theme.dart             # Theme data
│   ├── utils/
│   │   ├── logger.dart                # Logging utility
│   │   ├── validators.dart            # Input validators
│   │   └── helpers.dart               # Helper functions
│   └── errors/
│       ├── exceptions.dart            # Custom exceptions
│       └── failures.dart              # Failure classes
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/               # Data models
│   │   │   ├── datasources/          # API clients
│   │   │   └── repositories/         # Repository implementations
│   │   ├── domain/
│   │   │   ├── entities/             # Business objects
│   │   │   ├── repositories/         # Repository interfaces
│   │   │   └── usecases/             # Business logic
│   │   └── presentation/
│   │       ├── pages/                # Screen widgets
│   │       ├── widgets/              # Feature-specific widgets
│   │       └── providers/            # State management (Riverpod/Bloc)
│   │
│   ├── content_generation/
│   ├── content_library/
│   ├── billing/
│   └── settings/
│
├── shared/
│   ├── widgets/
│   │   ├── buttons/
│   │   ├── inputs/
│   │   ├── cards/
│   │   ├── dialogs/
│   │   └── loading/
│   ├── models/
│   └── services/
│       ├── api_service.dart
│       ├── firebase_service.dart
│       └── storage_service.dart
│
└── config/
    ├── routes.dart                    # Route definitions
    └── environment.dart               # Environment config
```

---

## 2. 📝 CODING STANDARDS

### File Naming
- **Files:** `snake_case.dart`
- **Classes:** `PascalCase`
- **Variables/Functions:** `camelCase`
- **Constants:** `UPPER_SNAKE_CASE` or `kCamelCase`

```dart
// ✅ GOOD
class UserProfile {}
const kPrimaryColor = Color(0xFF2563EB);
String userName = 'John';

// ❌ BAD
class user_profile {}
const PRIMARY_COLOR = Color(0xFF2563EB);  // Use k prefix
String UserName = 'John';
```

### Imports
- Sort imports: Dart SDK → Flutter SDK → Third-party → Local
- Use relative imports for local files
- Avoid barrel exports for performance

```dart
// ✅ GOOD
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:riverpod/riverpod.dart';
import 'package:dio/dio.dart';

import '../../../core/utils/logger.dart';
import '../../domain/entities/user.dart';

// ❌ BAD
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/logger.dart';
import 'dart:async';
```

### Code Comments
- Use `///` for documentation comments
- Use `//` for inline comments
- Explain WHY, not WHAT

```dart
// ✅ GOOD
/// Validates email format and checks if domain exists.
/// Returns error message if invalid, null if valid.
String? validateEmail(String email) {
  // Check format first to avoid unnecessary API calls
  if (!email.contains('@')) return 'Invalid email format';
  
  // Verify domain exists (prevents typos like @gmial.com)
  return _verifyDomain(email);
}

// ❌ BAD
// Function to validate email
String? validateEmail(String email) {
  // Check if email contains @
  if (!email.contains('@')) return 'Invalid email format';
  return _verifyDomain(email);
}
```

---

## 3. 🎨 CUSTOM WIDGETS LIBRARY

### CustomTextField

**DO NOT USE:** Standard `TextField` directly  
**USE:** Our custom `CustomTextField` wrapper

```dart
// shared/widgets/inputs/custom_text_field.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? maxLines;
  final bool enabled;
  final bool readOnly;
  final AutovalidateMode? autovalidateMode;

  const CustomTextField({
    Key? key,
    this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.enabled = true,
    this.readOnly = false,
    this.autovalidateMode,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: _obscureText,
          validator: widget.validator,
          onChanged: widget.onChanged,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          autovalidateMode: widget.autovalidateMode,
          decoration: InputDecoration(
            hintText: widget.hint,
            errorText: widget.errorText,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : widget.suffixIcon,
            filled: true,
            fillColor: AppColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}

// USAGE:
CustomTextField(
  label: 'Email',
  hint: 'Enter your email',
  keyboardType: TextInputType.emailAddress,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    return null;
  },
)
```

### CustomButton

```dart
// shared/widgets/buttons/custom_button.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum ButtonType { primary, secondary, outlined, text }
enum ButtonSize { small, medium, large }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final Widget? icon;
  final bool fullWidth;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.fullWidth = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonHeight = _getHeight();
    final buttonPadding = _getPadding();
    final textStyle = _getTextStyle(context);

    return SizedBox(
      height: buttonHeight,
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getBackgroundColor(),
          foregroundColor: _getForegroundColor(),
          elevation: type == ButtonType.outlined || type == ButtonType.text ? 0 : 2,
          padding: buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: type == ButtonType.outlined
                ? BorderSide(color: AppColors.primary)
                : BorderSide.none,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    type == ButtonType.primary
                        ? Colors.white
                        : AppColors.primary,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: 8),
                  ],
                  Text(text, style: textStyle),
                ],
              ),
      ),
    );
  }

  double _getHeight() {
    switch (size) {
      case ButtonSize.small:
        return 32;
      case ButtonSize.medium:
        return 40;
      case ButtonSize.large:
        return 48;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24);
    }
  }

  Color _getBackgroundColor() {
    if (type == ButtonType.primary) return AppColors.primary;
    if (type == ButtonType.secondary) return AppColors.secondary;
    return Colors.transparent;
  }

  Color _getForegroundColor() {
    if (type == ButtonType.primary) return Colors.white;
    return AppColors.primary;
  }

  TextStyle? _getTextStyle(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.labelLarge;
    return baseStyle?.copyWith(fontWeight: FontWeight.w600);
  }
}

// USAGE:
CustomButton(
  text: 'Sign In',
  type: ButtonType.primary,
  size: ButtonSize.large,
  fullWidth: true,
  isLoading: isLoading,
  onPressed: () => _handleSignIn(),
)
```

### CustomCard

```dart
// shared/widgets/cards/custom_card.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final double? elevation;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const CustomCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.onTap,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final card = Card(
      elevation: elevation ?? 2,
      color: backgroundColor ?? Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      margin: margin ?? EdgeInsets.zero,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: card,
      );
    }

    return card;
  }
}
```

### LoadingIndicator

```dart
// shared/widgets/loading/loading_indicator.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final String? message;

  const LoadingIndicator({
    Key? key,
    this.size = 40,
    this.color,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppColors.primary,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
```

---

## 4. ⚠️ DEPRECATED METHODS & ALTERNATIVES

### NEVER USE DEPRECATED METHODS

```dart
// ❌ DEPRECATED - DO NOT USE
Opacity(opacity: 0.5, child: widget)

// ✅ USE INSTEAD
widget.withOpacity(0.5)  // Extension method
// OR
Container(
  color: Colors.black.withOpacity(0.5),
  child: widget,
)

// ===============================================

// ❌ DEPRECATED - DO NOT USE
FlatButton()
RaisedButton()
OutlineButton()

// ✅ USE INSTEAD
TextButton()
ElevatedButton()
OutlinedButton()

// ===============================================

// ❌ DEPRECATED - DO NOT USE
FloatingActionButtonLocation.endDocked

// ✅ USE INSTEAD
FloatingActionButtonLocation.endFloat

// ===============================================

// ❌ DEPRECATED - DO NOT USE
Theme.of(context).accentColor

// ✅ USE INSTEAD
Theme.of(context).colorScheme.secondary

// ===============================================

// ❌ DEPRECATED - DO NOT USE
primaryColor (in ThemeData)
accentColor (in ThemeData)

// ✅ USE INSTEAD - Use ColorScheme
ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
  ),
)

// ===============================================

// ❌ DEPRECATED - DO NOT USE
textTheme: TextTheme(
  headline1: TextStyle(...),
  headline2: TextStyle(...),
)

// ✅ USE INSTEAD
textTheme: TextTheme(
  displayLarge: TextStyle(...),   // was headline1
  displayMedium: TextStyle(...),  // was headline2
  displaySmall: TextStyle(...),   // was headline3
  headlineLarge: TextStyle(...),  // was headline4
  headlineMedium: TextStyle(...), // was headline5
  headlineSmall: TextStyle(...),  // was headline6
  bodyLarge: TextStyle(...),      // was bodyText1
  bodyMedium: TextStyle(...),     // was bodyText2
)
```

### Widget Lifecycle Methods

```dart
// ❌ DEPRECATED - DO NOT USE
@override
void initState() {
  super.initState();
  // Synchronous work only
}

// ✅ CORRECT - For async work
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // Async work here
    _loadData();
  });
}
```

---

## 5. 📊 LOGGING STANDARDS

### DO NOT USE print()

**NEVER USE:**
```dart
print('User logged in');  // ❌ BAD
print('Error: $error');    // ❌ BAD
```

**ALWAYS USE:** `developer.log()` from `dart:developer`

```dart
// core/utils/logger.dart

import 'dart:developer' as developer;

class AppLogger {
  static const String _name = 'Summarly';

  /// Log debug information (development only)
  static void debug(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: _name,
      level: 500,  // Debug level
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log general information
  static void info(String message) {
    developer.log(
      message,
      name: _name,
      level: 800,  // Info level
    );
  }

  /// Log warnings
  static void warning(String message, {Object? error}) {
    developer.log(
      message,
      name: _name,
      level: 900,  // Warning level
      error: error,
    );
  }

  /// Log errors
  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: _name,
      level: 1000,  // Error level
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log API calls
  static void api(String endpoint, {Map<String, dynamic>? data}) {
    developer.log(
      'API Call: $endpoint',
      name: _name,
      level: 800,
      error: data,
    );
  }
}

// USAGE:
import '../../../core/utils/logger.dart';

// Development debugging
AppLogger.debug('User clicked generate button');

// General information
AppLogger.info('Content generation started');

// Warnings
AppLogger.warning('API rate limit approaching', error: {'remaining': 10});

// Errors
try {
  await generateContent();
} catch (e, stackTrace) {
  AppLogger.error('Content generation failed', error: e, stackTrace: stackTrace);
}

// API calls
AppLogger.api('/api/v1/generate', data: {'type': 'blog'});
```

### Production Logging with Sentry

```dart
// main.dart

import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = 'YOUR_SENTRY_DSN';
      options.environment = kReleaseMode ? 'production' : 'development';
      options.tracesSampleRate = 0.1;  // 10% of transactions
    },
    appRunner: () => runApp(MyApp()),
  );
}

// Capture errors
try {
  await riskyOperation();
} catch (error, stackTrace) {
  await Sentry.captureException(
    error,
    stackTrace: stackTrace,
    hint: Hint.withMap({'user_action': 'content_generation'}),
  );
  AppLogger.error('Operation failed', error: error, stackTrace: stackTrace);
}
```

---

## 6. 🔄 STATE MANAGEMENT

### Use Riverpod 2.0

```dart
// DO NOT USE: Provider (outdated)
// DO NOT USE: setState for complex state
// USE: Riverpod for all state management

// Example: Auth State Provider
// features/auth/presentation/providers/auth_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/user.dart';

part 'auth_provider.g.dart';

@riverpod
class AuthState extends _$AuthState {
  @override
  AsyncValue<User?> build() {
    return const AsyncValue.loading();
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = await ref.read(authRepositoryProvider).signIn(email, password);
      return user;
    });
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    await ref.read(authRepositoryProvider).signOut();
    state = const AsyncValue.data(null);
  }
}

// USAGE in Widget:
class LoginPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) => user != null ? DashboardPage() : LoginForm(),
      loading: () => LoadingIndicator(),
      error: (error, stack) => ErrorWidget(error: error.toString()),
    );
  }
}
```

---

## 7. 🧭 NAVIGATION

### Use GoRouter

```dart
// config/routes.dart

import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardPage(),
      routes: [
        GoRoute(
          path: 'generate',
          builder: (context, state) => const GeneratorPage(),
        ),
        GoRoute(
          path: 'library',
          builder: (context, state) => const LibraryPage(),
        ),
      ],
    ),
  ],
  redirect: (context, state) {
    // Auth guard
    final isLoggedIn = /* check auth state */;
    final isLoginRoute = state.location == '/login';

    if (!isLoggedIn && !isLoginRoute) {
      return '/login';
    }
    return null;
  },
);

// USAGE:
context.go('/dashboard');
context.push('/dashboard/generate');
context.pop();
```

---

## 8. ⚠️ ERROR HANDLING

### Consistent Error Handling

```dart
// core/errors/failures.dart

abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('No internet connection');
}

class AuthFailure extends Failure {
  const AuthFailure(String message) : super(message);
}

// USAGE in Repository:
Future<Either<Failure, User>> signIn(String email, String password) async {
  try {
    final response = await _apiService.post('/auth/login', {
      'email': email,
      'password': password,
    });
    return Right(User.fromJson(response.data));
  } on DioException catch (e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      return const Left(NetworkFailure());
    }
    return Left(ServerFailure(e.message ?? 'Unknown error'));
  } catch (e) {
    return Left(ServerFailure(e.toString()));
  }
}
```

---

## 9. 🧪 TESTING STANDARDS

### Write Tests for All Features

```dart
// features/auth/domain/usecases/sign_in_usecase_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignInUseCase useCase;
  late MockAuthRepository repository;

  setUp(() {
    repository = MockAuthRepository();
    useCase = SignInUseCase(repository);
  });

  group('SignInUseCase', () {
    const email = 'test@example.com';
    const password = 'password123';
    final user = User(id: '1', email: email);

    test('should return user when credentials are valid', () async {
      // Arrange
      when(() => repository.signIn(email, password))
          .thenAnswer((_) async => Right(user));

      // Act
      final result = await useCase(email, password);

      // Assert
      expect(result, Right(user));
      verify(() => repository.signIn(email, password)).called(1);
    });

    test('should return failure when credentials are invalid', () async {
      // Arrange
      when(() => repository.signIn(email, password))
          .thenAnswer((_) async => const Left(AuthFailure('Invalid credentials')));

      // Act
      final result = await useCase(email, password);

      // Assert
      expect(result, const Left(AuthFailure('Invalid credentials')));
    });
  });
}
```

### Widget Testing

```dart
// features/auth/presentation/pages/login_page_test.dart

import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('LoginPage should display email and password fields', (tester) async {
    // Arrange
    await tester.pumpWidget(
      MaterialApp(
        home: LoginPage(),
      ),
    );

    // Assert
    expect(find.byType(CustomTextField), findsNWidgets(2));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.byType(CustomButton), findsOneWidget);
  });
}
```

---

## 10. ⚡ PERFORMANCE BEST PRACTICES

### Use const Constructors

```dart
// ✅ GOOD - Use const when possible
const Text('Hello')
const SizedBox(height: 16)
const Icon(Icons.check)

// ❌ BAD - Unnecessary rebuilds
Text('Hello')
SizedBox(height: 16)
Icon(Icons.check)
```

### Avoid Expensive Operations in build()

```dart
// ❌ BAD - Computed every build
@override
Widget build(BuildContext context) {
  final processedData = expensiveComputation(data);  // DON'T DO THIS
  return Text(processedData);
}

// ✅ GOOD - Computed once
late final String processedData;

@override
void initState() {
  super.initState();
  processedData = expensiveComputation(data);
}

@override
Widget build(BuildContext context) {
  return Text(processedData);
}
```

### Use ListView.builder for Long Lists

```dart
// ❌ BAD - All items created at once
ListView(
  children: items.map((item) => ItemWidget(item)).toList(),
)

// ✅ GOOD - Items created on-demand
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
)
```

---

## 11. 🔒 SECURITY GUIDELINES

### Never Store Secrets in Code

```dart
// ❌ BAD
const String apiKey = 'sum_live_xxxxxxxxxxxxx';  // DON'T DO THIS

// ✅ GOOD - Use environment variables
class Environment {
  static const String apiKey = String.fromEnvironment('API_KEY');
  static const String stripeKey = String.fromEnvironment('STRIPE_KEY');
}

// Run with:
// flutter run --dart-define=API_KEY=xxx --dart-define=STRIPE_KEY=xxx
```

### Validate All User Inputs

```dart
// Always validate and sanitize
String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email is required';
  }
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(value)) {
    return 'Invalid email format';
  }
  return null;
}
```

---

## 12. 🔀 GIT WORKFLOW

### Branch Naming

```
feature/auth-screen
bugfix/login-crash
hotfix/payment-error
refactor/api-service
```

### Commit Messages

```
feat: add login screen
fix: resolve payment processing error
refactor: improve API service structure
docs: update README with setup instructions
test: add unit tests for auth service
```

### Before Committing

```bash
# Run these commands:
flutter analyze
flutter test
dart format .
```

---

## 📚 ADDITIONAL RESOURCES

- [Flutter Documentation](https://docs.flutter.dev/)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Riverpod Documentation](https://riverpod.dev/)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)

---

## 13. 🐍 FASTAPI BACKEND - QUICK START GUIDE

### ⚠️ CRITICAL RULE FOR AI ASSISTANTS
**NEVER create new .md files for implementation guides or technical decisions.**  
**ALL backend documentation goes in this file or existing documentation files.**

---

### 📦 Installation & Setup

#### Step 1: Navigate to Backend Directory
```bash
cd backend
```

#### Step 2: Create Virtual Environment
```bash
python3 -m venv .venv
```

#### Step 3: Activate Virtual Environment
```bash
# On macOS/Linux:
source .venv/bin/activate

# On Windows:
.venv\Scripts\activate
```
**You should see `(.venv)` in your terminal prompt**

#### Step 4: Install FastAPI with Standard Dependencies
```bash
pip install "fastapi[standard]"
```

**What gets installed:**
- FastAPI framework
- Uvicorn (ASGI server)
- Pydantic (data validation)
- Starlette (web framework base)
- uvloop (high-performance event loop)
- httpx (HTTP client for testing)
- jinja2 (templates)
- python-multipart (form parsing)

#### Step 5: Install Project-Specific Dependencies
```bash
pip install -r requirements.txt
```

**Additional packages for this project:**
- Firebase Admin SDK
- OpenAI, Anthropic, Google Gemini APIs
- Stripe (payments)
- Redis (caching & rate limiting)
- JWT authentication libraries

---

### 🚀 Create Your First FastAPI Endpoint

#### Minimal Example (backend/app/main.py already created):
```python
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"Hello": "World"}

@app.get("/items/{item_id}")
def read_item(item_id: int, q: str | None = None):
    return {"item_id": item_id, "q": q}
```

#### Run Development Server:
```bash
# From backend/ directory:
uvicorn app.main:app --reload

# Or use fastapi CLI:
fastapi dev app/main.py
```

**You should see:**
```
INFO:     Uvicorn running on http://127.0.0.1:8000
INFO:     Application startup complete.
```

---

### 🔍 Testing Your API

#### 1. Open Browser - Interactive Docs:
- **Swagger UI:** http://localhost:8000/docs
- **ReDoc:** http://localhost:8000/redoc

#### 2. Test Endpoints:
- Health check: http://localhost:8000/health
- Root: http://localhost:8000/

#### 3. Try a Query:
```
http://localhost:8000/items/5?q=somequery
```
**Response:**
```json
{"item_id": 5, "q": "somequery"}
```

---

### 📝 Adding Request Body (Pydantic Models)

#### Example: PUT Request with Body
```python
from pydantic import BaseModel
from fastapi import FastAPI

app = FastAPI()

class Item(BaseModel):
    name: str
    price: float
    is_offer: bool | None = None

@app.put("/items/{item_id}")
def update_item(item_id: int, item: Item):
    return {"item_name": item.name, "item_id": item_id}
```

**The server auto-reloads!** Go to http://localhost:8000/docs and you'll see:
- Automatic validation
- Interactive "Try it out" button
- Request/response schemas

---

### 🏗️ Project Structure (Already Created)

```
backend/
├── app/
│   ├── main.py              # FastAPI app entry point
│   ├── config.py            # Environment variables
│   ├── dependencies.py      # Dependency injection (auth)
│   │
│   ├── api/                 # API endpoints
│   │   ├── auth.py         # POST /api/v1/auth/login, /register
│   │   ├── generate.py     # POST /api/v1/generate/blog, /social
│   │   ├── billing.py      # POST /api/v1/billing/webhook
│   │   └── user.py         # GET /api/v1/user/profile, /usage
│   │
│   ├── services/            # Business logic
│   │   ├── firebase_service.py
│   │   ├── openai_service.py
│   │   ├── stripe_service.py
│   │   └── factcheck_service.py
│   │
│   ├── schemas/             # Pydantic models
│   ├── models/              # Firestore structures
│   ├── middleware/          # Rate limiting, security
│   ├── utils/               # Helpers
│   └── exceptions/          # Custom exceptions
│
├── tests/
├── requirements.txt
├── .env.example
└── README.md
```

---

### 🔐 Environment Variables Setup

#### Step 1: Copy Template
```bash
cp .env.example .env
```

#### Step 2: Edit with Your Keys
```bash
# Open in editor
nano .env
# or
code .env
```

#### Required Keys (Minimum):
```bash
OPENAI_API_KEY=sk-your-openai-key
FIREBASE_PROJECT_ID=your-project-id
STRIPE_SECRET_KEY=sk_test_your-stripe-key
```

---

### ⚡ Common Commands

#### Activate Environment (Every Session)
```bash
cd backend
source .venv/bin/activate
```

#### Run Server
```bash
uvicorn app.main:app --reload
```

#### Install New Package
```bash
pip install package-name
pip freeze > requirements.txt  # Save to requirements
```

#### Run Tests
```bash
pytest
```

#### Code Formatting
```bash
black app/
```

#### Type Checking
```bash
mypy app/
```

---

### 🎯 Key FastAPI Features Used in This Project

#### 1. **Automatic Data Validation (Pydantic)**
```python
from pydantic import BaseModel, EmailStr

class UserRegister(BaseModel):
    email: EmailStr  # Validates email format
    password: str
    displayName: str

@app.post("/register")
def register(data: UserRegister):
    # data is already validated!
    return {"email": data.email}
```

#### 2. **Dependency Injection (Authentication)**
```python
from fastapi import Depends
from app.dependencies import get_current_user

@app.get("/protected")
def protected_route(current_user: dict = Depends(get_current_user)):
    # User is authenticated here
    return {"user": current_user}
```

#### 3. **Automatic API Documentation**
- Just define your endpoints
- Swagger UI generated automatically at `/docs`
- ReDoc generated at `/redoc`

#### 4. **Async Support**
```python
@app.get("/async-example")
async def async_endpoint():
    result = await some_async_function()
    return result
```

#### 5. **Exception Handling**
```python
from fastapi import HTTPException

@app.get("/user/{user_id}")
def get_user(user_id: str):
    if not user_exists(user_id):
        raise HTTPException(status_code=404, detail="User not found")
    return {"user_id": user_id}
```

---

### 🐛 Troubleshooting

#### Issue: "Import could not be resolved"
**Solution:** Packages not installed
```bash
source .venv/bin/activate
pip install -r requirements.txt
```

#### Issue: "Port 8000 already in use"
**Solution:** Kill existing process or use different port
```bash
lsof -ti:8000 | xargs kill -9
# Or
uvicorn app.main:app --reload --port 8001
```

#### Issue: "Module 'app' not found"
**Solution:** Wrong directory
```bash
cd backend
uvicorn app.main:app --reload
```

---

### 📚 FastAPI Learning Resources

- **Official Tutorial:** https://fastapi.tiangolo.com/tutorial/
- **Pydantic Docs:** https://docs.pydantic.dev/
- **Deployment Guide:** https://fastapi.tiangolo.com/deployment/
- **Testing:** https://fastapi.tiangolo.com/tutorial/testing/

---

### 🔑 Technical Decisions (Key Points)

#### 1. **Database: JSON-Compatible Firestore**
- Easy migration to AWS/MongoDB/PostgreSQL
- All data stored in JSON format
- See: `.github/instructions/TECHNICAL_DECISIONS.md`

#### 2. **Rate Limiting: Redis + Firestore**
- Redis: Real-time (fast)
- Firestore: Persistent tracking
- Limits per tier (free/hobby/pro/enterprise)

#### 3. **Payment Failures: 3-Strike System**
- 1st: Email reminder, retry 3 days
- 2nd: Downgrade to free tier
- 3rd: Cancel, keep data 30 days

#### 4. **Security: Multi-Layer Protection**
- Environment variables only
- Pydantic models exclude sensitive fields
- Audit logging
- Request size limits

#### 5. **Authentication: FastAPI-Only**
- All auth through backend (no client-side Firebase SDK)
- JWT tokens managed by backend
- Centralized security

---

### ✅ Verification Checklist

After setup, verify:
- [ ] Virtual environment activated (`(.venv)` in prompt)
- [ ] All packages installed (no import errors)
- [ ] `.env` file created with API keys
- [ ] Server starts: `uvicorn app.main:app --reload`
- [ ] http://localhost:8000/docs loads
- [ ] Health check returns healthy: http://localhost:8000/health

---

## 14. 🏗️ BACKEND ARCHITECTURE & BEST PRACTICES

### 14.1 Constants-Driven Development

**RULE:** Never hardcode strings - always use constants from `app/constants.py`

#### ✅ CORRECT:
```python
from app.constants import Collections, SubscriptionPlan

# Firestore operations
user_ref = db.collection(Collections.USERS).document(user_id)

# Setting subscription
user_data = {
    'subscription': {
        'plan': SubscriptionPlan.FREE,
        'status': SubscriptionStatus.ACTIVE
    }
}
```

#### ❌ WRONG:
```python
# Hardcoded strings - DON'T DO THIS
user_ref = db.collection('users').document(user_id)
user_data = {'subscription': {'plan': 'free', 'status': 'active'}}
```

#### Benefits:
- **Type safety**: IDE autocomplete catches typos
- **Refactoring**: Change once in constants.py, updates everywhere
- **Consistency**: No "users" vs "user" vs "Users" confusion
- **Documentation**: Constants file serves as single source of truth

---

### 14.2 Pydantic Models as Data Classes

**PHILOSOPHY:** Use Pydantic models like Dart data classes for type-safe data handling

#### Pattern: Input → Validation → Processing → Output

```python
from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from datetime import datetime

# 1. Define Pydantic model (like Dart class)
class UserCreate(BaseModel):
    """User registration input"""
    email: EmailStr
    password: str = Field(min_length=8)
    display_name: Optional[str] = None
    
    class Config:
        json_schema_extra = {
            "example": {
                "email": "user@example.com",
                "password": "secure123",
                "display_name": "John Doe"
            }
        }

class UserResponse(BaseModel):
    """User data returned to client"""
    uid: str
    email: str
    display_name: str
    created_at: datetime
    subscription_plan: str
    
    class Config:
        from_attributes = True  # Allow creating from ORM/dict

# 2. Use in API endpoint
@router.post("/register", response_model=UserResponse)
async def register(user_data: UserCreate):
    # Pydantic automatically validates input
    
    # Convert to dict for Firestore
    user_dict = user_data.model_dump()
    
    # Process
    result = await firebase_service.create_user(user_dict)
    
    # Return validated response
    return UserResponse(**result)
```

#### Comparison: Python (Pydantic) vs Dart

**Dart:**
```dart
class User {
  final String uid;
  final String email;
  final String displayName;
  
  User({required this.uid, required this.email, required this.displayName});
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'],
      email: json['email'],
      displayName: json['displayName'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {'uid': uid, 'email': email, 'displayName': displayName};
  }
}
```

**Python (Pydantic):**
```python
class User(BaseModel):
    uid: str
    email: EmailStr
    display_name: str
    
    # .model_dump() = toJson()
    # User(**json_data) = fromJson()
```

#### Key Pydantic Features:

**1. Automatic Validation:**
```python
class ContentRequest(BaseModel):
    topic: str = Field(min_length=3, max_length=200)
    word_count: int = Field(gt=0, le=5000)
    tone: str = Field(pattern="^(professional|casual|friendly)$")
    
# Invalid data raises ValidationError automatically
```

**2. Type Coercion:**
```python
class Settings(BaseModel):
    max_results: int
    
# Accepts "10" and converts to 10
settings = Settings(max_results="10")  # ✅ Works
```

**3. Default Values:**
```python
class GenerateRequest(BaseModel):
    topic: str
    tone: str = "professional"  # Default
    include_images: bool = False  # Default
```

**4. Custom Validators:**
```python
from pydantic import field_validator

class UserCreate(BaseModel):
    email: str
    password: str
    
    @field_validator('password')
    def validate_password(cls, v):
        if len(v) < 8:
            raise ValueError('Password must be at least 8 characters')
        if not any(char.isdigit() for char in v):
            raise ValueError('Password must contain a number')
        return v
```

**5. Nested Models:**
```python
class Address(BaseModel):
    street: str
    city: str
    zip_code: str

class User(BaseModel):
    name: str
    address: Address  # Nested validation
```

---

### 14.3 Service Layer Pattern

**STRUCTURE:** Controllers (API) → Services (Business Logic) → Database

```
app/
├── api/              # API endpoints (thin controllers)
│   ├── auth.py       # Routes: /register, /login
│   └── user.py       # Routes: /profile, /usage
│
├── services/         # Business logic (fat services)
│   ├── firebase_service.py   # Database operations
│   ├── openai_service.py     # AI generation logic
│   └── auth_service.py       # Authentication logic
│
├── schemas/          # Pydantic models (data validation)
│   ├── user.py       # UserCreate, UserResponse, etc.
│   └── auth.py       # LoginRequest, TokenResponse
│
└── constants.py      # All constants
```

#### Example Flow:

**1. API Layer (auth.py):**
```python
from fastapi import APIRouter, Depends, HTTPException
from app.schemas.auth import LoginRequest, TokenResponse
from app.services.auth_service import auth_service

router = APIRouter()

@router.post("/login", response_model=TokenResponse)
async def login(credentials: LoginRequest):
    """Login endpoint - handles HTTP request"""
    try:
        # Delegate to service
        token = await auth_service.authenticate(
            email=credentials.email,
            password=credentials.password
        )
        return TokenResponse(access_token=token, token_type="bearer")
    except Exception as e:
        raise HTTPException(status_code=401, detail="Invalid credentials")
```

**2. Service Layer (auth_service.py):**
```python
from app.services.firebase_service import firebase_service
from app.constants import Collections, StatusCode
import bcrypt
import jwt

class AuthService:
    """Business logic for authentication"""
    
    async def authenticate(self, email: str, password: str) -> str:
        """Validate credentials and return JWT token"""
        # Get user from database
        user = await firebase_service.get_user_by_email(email)
        
        if not user:
            raise ValueError("User not found")
        
        # Verify password
        if not bcrypt.checkpw(password.encode(), user['password_hash'].encode()):
            raise ValueError("Invalid password")
        
        # Generate JWT token
        token = jwt.encode({'uid': user['uid']}, settings.JWT_SECRET_KEY)
        
        return token
    
    async def register(self, email: str, password: str) -> dict:
        """Create new user account"""
        # Hash password
        password_hash = bcrypt.hashpw(password.encode(), bcrypt.gensalt())
        
        # Create user
        user_data = {
            'email': email,
            'password_hash': password_hash.decode()
        }
        
        return await firebase_service.create_user(user_data)

auth_service = AuthService()
```

**3. Schema Layer (auth.py):**
```python
from pydantic import BaseModel, EmailStr, Field

class LoginRequest(BaseModel):
    """Login request payload"""
    email: EmailStr
    password: str = Field(min_length=8)

class TokenResponse(BaseModel):
    """JWT token response"""
    access_token: str
    token_type: str = "bearer"
    expires_in: int = 86400  # 24 hours

class RegisterRequest(BaseModel):
    """Registration request payload"""
    email: EmailStr
    password: str = Field(min_length=8)
    display_name: str = Field(min_length=2, max_length=50)
```

---

### 14.4 Error Handling Strategy

**Use custom exceptions + FastAPI exception handlers**

#### 1. Define Custom Exceptions:
```python
# app/exceptions/handlers.py
from fastapi import HTTPException, Request
from fastapi.responses import JSONResponse
from app.constants import ErrorMessage, StatusCode

class UsageLimitExceeded(Exception):
    """User exceeded generation limit"""
    pass

class SubscriptionExpired(Exception):
    """User subscription expired"""
    pass

# Global exception handler
async def usage_limit_handler(request: Request, exc: UsageLimitExceeded):
    return JSONResponse(
        status_code=StatusCode.TOO_MANY_REQUESTS,
        content={
            "error": ErrorMessage.USAGE_LIMIT_EXCEEDED,
            "detail": str(exc),
            "code": "USAGE_LIMIT_EXCEEDED"
        }
    )
```

#### 2. Register Handlers in main.py:
```python
from app.exceptions.handlers import UsageLimitExceeded, usage_limit_handler

app.add_exception_handler(UsageLimitExceeded, usage_limit_handler)
```

#### 3. Use in Services:
```python
from app.exceptions.handlers import UsageLimitExceeded

async def generate_content(user_id: str, prompt: str):
    # Check usage
    can_generate = await firebase_service.check_usage_limit(user_id)
    
    if not can_generate:
        raise UsageLimitExceeded(
            f"User {user_id} exceeded monthly generation limit"
        )
    
    # Continue with generation...
```

---

### 14.5 Dependency Injection Pattern

**Use FastAPI's Depends() for reusable logic**

```python
from fastapi import Depends, HTTPException, Header
from typing import Optional
import jwt

# Reusable dependency
async def get_current_user(authorization: Optional[str] = Header(None)) -> dict:
    """Extract and verify JWT token from Authorization header"""
    if not authorization:
        raise HTTPException(status_code=401, detail="Missing authorization")
    
    try:
        token = authorization.replace("Bearer ", "")
        payload = jwt.decode(token, settings.JWT_SECRET_KEY, algorithms=["HS256"])
        user = await firebase_service.get_user(payload['uid'])
        return user
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")

# Use in endpoints
@router.get("/profile")
async def get_profile(current_user: dict = Depends(get_current_user)):
    """Protected route - requires authentication"""
    return {
        "email": current_user['email'],
        "plan": current_user['subscription']['plan']
    }

@router.post("/generate")
async def generate(
    request: GenerateRequest,
    current_user: dict = Depends(get_current_user)
):
    """Generate content for authenticated user"""
    # current_user is automatically injected
    result = await openai_service.generate_blog_post(
        topic=request.topic,
        user_id=current_user['uid']
    )
    return result
```

---

### 14.6 Testing Pattern

**Structure:** Unit tests (services) + Integration tests (API endpoints)

```python
# tests/test_auth_service.py
import pytest
from app.services.auth_service import auth_service

@pytest.mark.asyncio
async def test_register_user():
    """Test user registration"""
    result = await auth_service.register(
        email="test@example.com",
        password="secure123"
    )
    
    assert result['email'] == "test@example.com"
    assert 'uid' in result
    assert 'password_hash' not in result  # Password never returned

@pytest.mark.asyncio
async def test_authenticate_invalid_password():
    """Test login with wrong password"""
    with pytest.raises(ValueError, match="Invalid password"):
        await auth_service.authenticate(
            email="test@example.com",
            password="wrong_password"
        )
```

---

### 14.7 Quick Reference Checklist

**For every new feature:**

- [ ] Define constants in `app/constants.py`
- [ ] Create Pydantic schemas in `app/schemas/`
- [ ] Implement business logic in `app/services/`
- [ ] Create API endpoints in `app/api/`
- [ ] Add exception handlers in `app/exceptions/`
- [ ] Write tests in `tests/`
- [ ] Update this documentation

**Code Review Checklist:**

- [ ] No hardcoded strings (use constants)
- [ ] All inputs validated with Pydantic
- [ ] Services return Pydantic models (not raw dicts)
- [ ] Errors raised as custom exceptions (not generic Exception)
- [ ] Type hints on all functions
- [ ] Docstrings on all public methods
- [ ] Async/await used correctly (don't block event loop)

---

**Last Updated:** November 24, 2025  
**Maintainer:** Development Team  
**Questions?** Check the blueprint or create an issue in the repo
