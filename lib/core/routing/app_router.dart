import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth.dart';
import '../../features/content_generation/bindings/content_generation_binding.dart';
import '../../features/content_generation/views/content_generation_form_page.dart';
import '../../features/content_generation/views/content_results_page.dart';
import '../../features/image_generation/bindings/image_gallery_binding.dart';
import '../../features/image_generation/widgets/my_images_gallery_page.dart';
import '../../features/landing/landing.dart';
import '../../features/legal/views/forgot_password_page.dart';
import '../../features/legal/views/privacy_page.dart';
import '../../features/legal/views/terms_page.dart';

/// App Router Configuration with Deep Linking Support
///
/// Supports direct URL navigation for web deployment
///
/// IMPORTANT - Navigation Pattern for Web:
/// ✅ USE: context.go('/path')    - Replaces current page (web-style, no stacking)
/// ❌ AVOID: context.push('/path') - Stacks pages (mobile-style, creates back stack)
///
/// For professional web applications, always use context.go() to replace pages
/// instead of stacking them. This provides the expected web browsing experience.
class AppRouter {
  static const String landing = '/';
  static const String signIn = '/signin';
  static const String signUp = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String terms = '/terms';
  static const String privacy = '/privacy';
  static const String home = '/home';
  static const String generate = '/generate';
  static const String generateResults = '/generate/results';
  static const String myImages = '/my-images';

  static final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: landing,
    routes: [
      // Landing page route
      GoRoute(
        path: landing,
        name: 'landing',
        pageBuilder: (context, state) =>
            _buildPageWithFadeTransition(context, state, const LandingPage()),
      ),

      // Auth routes with fade transition (web-style)
      GoRoute(
        path: signIn,
        name: 'signIn',
        pageBuilder: (context, state) =>
            _buildPageWithFadeTransition(context, state, const SignInPage()),
      ),
      GoRoute(
        path: signUp,
        name: 'signUp',
        pageBuilder: (context, state) =>
            _buildPageWithFadeTransition(context, state, const SignUpPage()),
      ),
      GoRoute(
        path: forgotPassword,
        name: 'forgotPassword',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context,
          state,
          const ForgotPasswordPage(),
        ),
      ),

      // Legal pages with fade transition
      GoRoute(
        path: terms,
        name: 'terms',
        pageBuilder: (context, state) =>
            _buildPageWithFadeTransition(context, state, const TermsPage()),
      ),
      GoRoute(
        path: privacy,
        name: 'privacy',
        pageBuilder: (context, state) =>
            _buildPageWithFadeTransition(context, state, const PrivacyPage()),
      ),

      // Home/Dashboard route (post-authentication)
      GoRoute(
        path: home,
        name: 'home',
        pageBuilder: (context, state) =>
            _buildPageWithFadeTransition(context, state, const HomePage()),
      ),

      // Content Generation routes
      GoRoute(
        path: generate,
        name: 'generate',
        pageBuilder: (context, state) {
          // Initialize GetX binding for content generation
          ContentGenerationBinding().dependencies();
          return _buildPageWithFadeTransition(
            context,
            state,
            const ContentGenerationFormPage(),
          );
        },
      ),
      GoRoute(
        path: generateResults,
        name: 'generateResults',
        pageBuilder: (context, state) {
          // Binding should already be initialized from generate page
          return _buildPageWithFadeTransition(
            context,
            state,
            const ContentResultsPage(),
          );
        },
      ),

      // My Images Gallery route
      GoRoute(
        path: myImages,
        name: 'myImages',
        pageBuilder: (context, state) {
          // Initialize GetX binding for image gallery
          ImageGalleryBinding().dependencies();
          return _buildPageWithFadeTransition(
            context,
            state,
            const MyImagesGalleryPage(),
          );
        },
      ),
    ],
    errorBuilder: (context, state) => const NotFoundPage(),
  );

  /// Build page with fade transition (professional web-style)
  static CustomTransitionPage _buildPageWithFadeTransition(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Fade transition with slight scale for elegance
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
    );
  }
}

/// Placeholder for Home/Dashboard Page
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home - AI Content Generator'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.dashboard, size: 80, color: Colors.deepPurple),
              const SizedBox(height: 24),
              const Text(
                'Welcome to AI Content Generator',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Select a feature to get started',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 48),

              // Content Generation Button
              SizedBox(
                width: 300,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () => context.go(AppRouter.generate),
                  icon: const Icon(Icons.edit_note, size: 28),
                  label: const Text(
                    'Content Generation',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Generate Blog Posts, Social Media, Emails, Videos & Images',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // My Images Button
              SizedBox(
                width: 300,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () => context.go(AppRouter.myImages),
                  icon: const Icon(Icons.photo_library, size: 28),
                  label: const Text(
                    'My Images Gallery',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'View and manage your generated images',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const SizedBox(height: 48),

              // Quick Info Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Testing Instructions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '1. Click "Content Generation" to test all content types\n'
                      '2. Select "AI Image 🎨" tab to test image generation\n'
                      '3. Select "Video Script 🎬" tab to test video generation\n'
                      '4. Click "My Images Gallery" to view generated images',
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 404 Not Found Page
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '404',
              style: TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Page Not Found', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go(AppRouter.landing),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
