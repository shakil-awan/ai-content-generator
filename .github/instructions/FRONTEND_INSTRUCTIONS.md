# 🎯 FLUTTER FRONTEND INSTRUCTIONS

**Project:** Summarly AI Content Generator  
**Stack:** Flutter + GetX + Go Router + HTTP + Gap  
**Last Updated:** November 26, 2025

---

## 📋 QUICK START (READ THIS FIRST!)

**Before creating any screen:**
1. ✅ Read `lib/core/theme/app_theme.dart` (281 lines) - All colors, spacing, borders
2. ✅ Read `lib/core/constants/font_sizes.dart` (211 lines) - Typography
3. ✅ Use ONLY custom widgets listed below (never use Text(), TextField(), SizedBox() directly)
4. ✅ Use Gap() package for spacing (never SizedBox)
5. ✅ Keep files under 800 lines - split into widgets/ folder if needed

---

## 🧩 CUSTOM WIDGETS (MANDATORY - ALWAYS USE THESE!)

### 📝 Text Widgets (NEVER use Text() directly)
```dart
// Import
import '../../../shared/widgets/custom_text.dart';

// Available widgets
DisplayText('Hero Headline')        // 60px, bold (hero sections)
H1('Page Title')                    // 24px, w600 (page headings)
H2('Section Title')                 // 20px, w600 (section headings)
H3('Subsection')                    // 18px, w600 (subsections)
BodyText('Regular text')            // 16px, normal (default body)
BodyTextLarge('Intro text')         // 18px (large body)
BodyTextSmall('Helper text')        // 14px (small body)
CaptionText('Metadata')             // 13px (captions, hints)

// With parameters
H1('Welcome', color: AppTheme.primary, textAlign: TextAlign.center)
BodyText('Bold text', fontWeight: FontWeight.w600, maxLines: 2)
```

### 📝 Text Input (NEVER use TextField/TextFormField directly)
```dart
// Import
import '../../../shared/widgets/custom_text_field.dart';

// Simple TextField
CustomTextField(
  controller: emailController,
  label: 'Email',
  hint: 'Enter your email',
  prefixIcon: Icons.email,
  keyboardType: TextInputType.emailAddress,
  onChanged: (value) => print(value),
)

// Form TextField with validation
CustomTextFormField(
  controller: passwordController,
  label: 'Password',
  obscureText: true,
  prefixIcon: Icons.lock,
  suffixIcon: Icon(Icons.visibility),
  validator: ValidatorUtils.validatePassword,
  autovalidateMode: AutovalidateMode.onUserInteraction,
)

// Multiline
CustomTextField(
  controller: bioController,
  label: 'Bio',
  maxLines: 5,
  minLines: 3,
)
```

### 🔘 Buttons (NEVER use ElevatedButton/OutlinedButton directly)
```dart
// Import
import '../../../shared/widgets/custom_buttons.dart';

// Primary Button (filled, primary color)
PrimaryButton(
  text: 'Get Started',
  onPressed: () => print('Clicked'),
  icon: Icons.arrow_forward,
  isLoading: false,
  width: double.infinity, // Optional full width
)

// Secondary Button (outlined)
SecondaryButton(
  text: 'Learn More',
  onPressed: () {},
  icon: Icons.info,
)

// Text Button
CustomTextButton(
  text: 'Forgot Password?',
  onPressed: () {},
  icon: Icons.help,
  color: AppTheme.textSecondary,
)
```

### ⚡ Loading Widgets (Platform-aware)
```dart
// Import
import '../../../shared/widgets/adaptive_loading.dart';

// Adaptive Loading (Material on Android/Web, Cupertino on iOS/macOS)
AdaptiveLoading(message: 'Loading content...')
AdaptiveLoading()  // Without message
AdaptiveLoading(size: 50, color: AppTheme.accent)

// Small inline loader (for buttons, cards)
SmallLoader()
SmallLoader(color: Colors.white)

// Full screen overlay
LoadingOverlay(message: 'Generating content...')
```

### 📦 State Widgets
```dart
// Import
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/empty_state_widget.dart';

// Error Widget
ErrorDisplayWidget(
  message: 'Network error occurred',
  onRetry: () => controller.retryLoad(),
)

// Empty State Widget
EmptyStateWidget(
  icon: Icons.inbox,
  title: 'No content yet',
  subtitle: 'Create your first content to get started',
  actionLabel: 'Create Content',
  onAction: () => Get.toNamed('/create'),
)
```

### 📏 Spacing (MANDATORY - Use Gap, NEVER SizedBox!)
```dart
// Import
import 'package:gap/gap.dart';

// ❌ WRONG - Never do this!
SizedBox(height: 16)
SizedBox(width: 24)

// ✅ CORRECT - Always use Gap
Gap(16)   // Vertical gap in Column, Horizontal gap in Row
Gap(24)
Gap(AppTheme.spacing32)

// Example
Column(
  children: [
    H1('Welcome'),
    Gap(16),                    // ✅ Use Gap
    BodyText('Description'),
    Gap(24),                    // ✅ Use Gap
    PrimaryButton(text: 'Continue', onPressed: () {}),
  ],
)

Row(
  children: [
    Icon(Icons.star),
    Gap(8),                     // ✅ Horizontal gap in Row
    BodyText('4.8/5'),
  ],
)
```

---

## 🎨 THEME SYSTEM

### Colors (from AppTheme)
```dart
// Primary colors
AppTheme.primary          // #2563EB Blue (main brand)
AppTheme.secondary        // #10B981 Green (success actions)
AppTheme.accent           // #F59E0B Amber (highlights)

// Semantic colors
AppTheme.success          // #10B981 Green
AppTheme.warning          // #F59E0B Amber
AppTheme.error            // #EF4444 Red

// Text colors
AppTheme.textPrimary      // #1F2937 Dark gray (main text)
AppTheme.textSecondary    // #6B7280 Gray (secondary text)
AppTheme.textOnPrimary    // #FFFFFF White (text on primary button)

// Background colors
AppTheme.bgPrimary        // #FFFFFF White
AppTheme.bgSecondary      // #F9FAFB Light gray

// Neutral shades
AppTheme.neutral100       // Lightest gray
AppTheme.neutral200
AppTheme.neutral300
AppTheme.border           // #E5E7EB Border color
```

### Typography (from FontSizes)
```dart
FontSizes.displayXL       // 60px (Hero headlines)
FontSizes.displayLarge    // 48px
FontSizes.displayMedium   // 36px
FontSizes.h1              // 24px (Page titles)
FontSizes.h2              // 20px (Section titles)
FontSizes.h3              // 18px (Subsections)
FontSizes.h4              // 16px
FontSizes.bodyLarge       // 18px
FontSizes.bodyRegular     // 16px (Default)
FontSizes.bodySmall       // 14px
FontSizes.captionRegular  // 13px
FontSizes.captionSmall    // 12px
FontSizes.buttonRegular   // 16px
FontSizes.buttonSmall     // 14px
```

### Spacing (8px grid)
```dart
AppTheme.spacing4         // 4px
AppTheme.spacing8         // 8px
AppTheme.spacing12        // 12px
AppTheme.spacing16        // 16px (common)
AppTheme.spacing24        // 24px (common)
AppTheme.spacing32        // 32px
AppTheme.spacing48        // 48px
AppTheme.spacing64        // 64px (section gaps)
```

### Border Radius
```dart
AppTheme.borderRadiusSM   // 4px (small elements)
AppTheme.borderRadiusMD   // 8px (buttons, inputs)
AppTheme.borderRadiusLG   // 12px (cards)
AppTheme.borderRadiusXL   // 16px (large cards)
```

---

## 📐 ARCHITECTURE RULES

### Rule 1: 800-Line File Limit (MANDATORY!)
```dart
// ❌ BAD: 1500 lines in one file
class LandingPage extends StatelessWidget {
  // Everything in one file...
}

// ✅ GOOD: Split into widgets
// views/landing_page.dart (~100 lines)
class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            HeroSection(),           // Separate widget file
            Gap(64),
            FeaturesSection(),       // Separate widget file
            Gap(64),
            PricingSection(),        // Separate widget file
          ],
        ),
      ),
    );
  }
}

// widgets/hero_section.dart (~200 lines)
class HeroSection extends StatelessWidget { ... }

// widgets/features_section.dart (~250 lines)
class FeaturesSection extends StatelessWidget { ... }
```

### Rule 2: Feature Folder Structure with Barrel Files
```dart
features/landing/
├── landing.dart                 // 🆕 Feature barrel file (exports all)
├── views/
│   ├── views.dart              // 🆕 Views barrel file
│   └── landing_page.dart       // Main page (<800 lines)
├── controllers/
│   ├── controllers.dart        // 🆕 Controllers barrel file
│   └── landing_controller.dart // GetX state
├── models/
│   ├── models.dart             // 🆕 Models barrel file
│   └── landing_data.dart       // Data models (if needed)
└── widgets/
    ├── widgets.dart            // 🆕 Widgets barrel file
    ├── hero_section.dart       // ~200 lines
    ├── features_section.dart   // ~250 lines
    ├── pricing_section.dart    // ~200 lines
    └── footer_section.dart     // ~150 lines
```

**Barrel File Pattern (MANDATORY):**
```dart
// ✅ Create barrel files in each folder to simplify imports

// widgets/widgets.dart
export 'hero_section.dart';
export 'features_section.dart';
export 'pricing_section.dart';
export 'footer_section.dart';

// controllers/controllers.dart
export 'landing_controller.dart';

// views/views.dart
export 'landing_page.dart';

// landing.dart (feature-level barrel)
export 'controllers/controllers.dart';
export 'views/views.dart';
export 'widgets/widgets.dart';

// ❌ BAD: Multiple individual imports
import '../widgets/hero_section.dart';
import '../widgets/features_section.dart';
import '../widgets/pricing_section.dart';
import '../widgets/footer_section.dart';

// ✅ GOOD: Single barrel file import
import '../widgets/widgets.dart';

// ✅ BEST: Import entire feature from other features
import '../../landing/landing.dart';
```

### Rule 3: GetX Controller Pattern
```dart
// controllers/content_controller.dart
class ContentController extends GetxController {
  final ApiService _api = ApiService();
  
  // Reactive state (use .obs)
  var isLoading = false.obs;
  var content = ''.obs;
  var errorMessage = ''.obs;
  
  // Methods
  Future<void> generateContent(String prompt) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await _api.post('/content', body: {'prompt': prompt});
      content.value = response['content'];
      
      ToastUtils.showSuccess(Get.context!, 'Generated!');
    } catch (e) {
      errorMessage.value = e.toString();
      DialogUtils.showError(context: Get.context!, message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }
  
  @override
  void onInit() {
    super.onInit();
    // Initialize data
  }
}
```

### Rule 4: View Pattern with States
```dart
// views/content_generation_page.dart
class ContentGenerationPage extends StatelessWidget {
  final ContentController controller = Get.put(ContentController());
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: H2('Generate Content')),
      body: Obx(() {
        // Loading state
        if (controller.isLoading.value) {
          return AdaptiveLoading(message: 'Generating...');
        }
        
        // Error state
        if (controller.errorMessage.value.isNotEmpty) {
          return ErrorDisplayWidget(
            message: controller.errorMessage.value,
            onRetry: () => controller.generateContent('retry'),
          );
        }
        
        // Empty state
        if (controller.content.value.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.edit,
            title: 'No content yet',
            subtitle: 'Enter a prompt to generate content',
          );
        }
        
        // Success state
        return _buildContent();
      }),
    );
  }
  
  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.all(AppTheme.spacing16),
      child: Column(
        children: [
          CustomTextFormField(
            label: 'Prompt',
            hint: 'What do you need?',
            maxLines: 3,
            validator: ValidatorUtils.validateRequired,
          ),
          Gap(16),
          PrimaryButton(
            text: 'Generate',
            onPressed: () => controller.generateContent('test'),
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}
```

---

## 📦 MODEL & JSON HANDLING STANDARDS

### Rule 1: No Hardcoded JSON Keys (MANDATORY!)
```dart
// ❌ BAD: Hardcoded strings everywhere
class UserResponse {
  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      uid: json['uid'] as String,              // ❌ Hardcoded
      email: json['email'] as String,          // ❌ Hardcoded
      plan: json['subscription']['plan'],      // ❌ Hardcoded
    );
  }
}

// ✅ GOOD: Static constants for all JSON keys
class AuthJsonKeys {
  // User Keys
  static const String uid = 'uid';
  static const String email = 'email';
  static const String displayName = 'displayName';
  
  // Subscription Keys
  static const String subscription = 'subscription';
  static const String plan = 'plan';
  static const String status = 'status';
  
  // Token Keys
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
}

class UserResponse {
  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      uid: json[AuthJsonKeys.uid] as String,              // ✅ Type-safe
      email: json[AuthJsonKeys.email] as String,          // ✅ Reusable
      plan: json[AuthJsonKeys.subscription][AuthJsonKeys.plan], // ✅ Clear
    );
  }
}
```

### Rule 2: Models Live in Feature's models/ Folder
```dart
// ✅ CORRECT Structure
features/auth/
├── models/
│   ├── models.dart              // 🆕 Barrel file (export all)
│   ├── auth_models.dart         // All auth-related models
│   └── auth_json_keys.dart      // Optional: separate keys file
├── services/
│   └── auth_service.dart        // Uses models from ../models
├── controllers/
│   └── auth_controller.dart     // Uses models from ../models
└── views/
    └── login_page.dart          // Uses models from ../models

// ❌ WRONG: Models in service file
// services/auth_service.dart (DON'T DO THIS!)
class TokenResponse { ... }      // ❌ Model in service file
class UserResponse { ... }       // ❌ Model in service file
class AuthService { ... }

// ✅ CORRECT: Models in dedicated file
// models/auth_models.dart
class AuthJsonKeys { ... }       // ✅ JSON keys class
class TokenResponse { ... }      // ✅ Dedicated model file
class UserResponse { ... }       // ✅ Easy to reuse
class SubscriptionInfo { ... }   // ✅ Nested models

// services/auth_service.dart
import '../models/models.dart';  // ✅ Import from models
class AuthService { ... }        // ✅ Clean service
```

### Rule 3: Group Related Models with JSON Keys
```dart
// models/auth_models.dart
// ==================== JSON KEYS ====================

/// JSON keys for parsing API responses - matches backend schema
class AuthJsonKeys {
  // Token Response Keys
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String tokenType = 'token_type';
  
  // User Keys
  static const String uid = 'uid';
  static const String email = 'email';
  static const String displayName = 'displayName';
  
  // Subscription Keys (nested)
  static const String subscription = 'subscription';
  static const String plan = 'plan';
  static const String status = 'status';
  static const String currentPeriodStart = 'currentPeriodStart';
}

// ==================== MODELS ====================

/// Token Response from backend
class TokenResponse {
  final String accessToken;
  final String refreshToken;
  final UserResponse user;

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json[AuthJsonKeys.accessToken] as String,
      refreshToken: json[AuthJsonKeys.refreshToken] as String,
      user: UserResponse.fromJson(json[AuthJsonKeys.user]),
    );
  }
}

/// User Response from backend
class UserResponse {
  final String uid;
  final String email;
  final SubscriptionInfo subscription;

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      uid: json[AuthJsonKeys.uid] as String,
      email: json[AuthJsonKeys.email] as String,
      subscription: SubscriptionInfo.fromJson(
        json[AuthJsonKeys.subscription],
      ),
    );
  }
}

/// Nested subscription model
class SubscriptionInfo {
  final String plan;
  final String status;

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) {
    return SubscriptionInfo(
      plan: json[AuthJsonKeys.plan] as String? ?? 'free',
      status: json[AuthJsonKeys.status] as String? ?? 'active',
    );
  }
}
```

### Rule 4: Create Barrel Files for Models
```dart
// models/models.dart (Barrel file)
/// Barrel file for auth models
/// 
/// Usage:
/// ```dart
/// import '../models/models.dart';
/// 
/// // Access classes
/// UserResponse user = UserResponse.fromJson(json);
/// TokenResponse token = TokenResponse.fromJson(json);
/// 
/// // Access JSON keys
/// final uid = json[AuthJsonKeys.uid];
/// final email = json[AuthJsonKeys.email];
/// ```

export 'auth_models.dart';

// ❌ BAD: Import full path
import '../models/auth_models.dart';

// ✅ GOOD: Import barrel file
import '../models/models.dart';
```

### Rule 5: Benefits of This Pattern
```dart
// ✅ Type Safety - No typos in JSON keys
json[AuthJsonKeys.email]         // ✅ Autocomplete works
json['emial']                    // ❌ Runtime error

// ✅ Refactoring - Change key once, updates everywhere
class AuthJsonKeys {
  static const String email = 'userEmail';  // Backend changed key
  // All fromJson methods automatically use new key
}

// ✅ Reusability - Other features can import models
import '../../auth/models/models.dart';
UserResponse user = UserResponse.fromJson(json);

// ✅ Maintainability - Single source of truth
// No searching through 10 files to find where 'uid' is used

// ✅ Documentation - Keys are self-documenting
static const String currentPeriodStart = 'currentPeriodStart';
// Clear what backend field name is

// ✅ Testing - Mock data uses same keys
final mockJson = {
  AuthJsonKeys.uid: 'test-123',
  AuthJsonKeys.email: 'test@example.com',
};
```

### Quick Checklist for New Features:
- [ ] Created `models/` folder in feature
- [ ] Created `XJsonKeys` class with all static const keys
- [ ] All model classes use `XJsonKeys` instead of hardcoded strings
- [ ] Created `models/models.dart` barrel file
- [ ] Services import from `../models/models.dart`
- [ ] Controllers import from `../models/models.dart`
- [ ] No hardcoded JSON keys anywhere in the feature

---

## 🔧 UTILITIES (Use These!)

### Dialog Utils
```dart
// Import
import '../../../core/utils/dialog_utils.dart';

// Show dialogs
DialogUtils.showSuccess(
  context: context, 
  title: 'Success', 
  message: 'Content saved!',
);

DialogUtils.showError(
  context: context, 
  message: 'Failed to save',
);

DialogUtils.showConfirmation(
  context: context,
  title: 'Delete Content?',
  message: 'This cannot be undone',
  onConfirm: () => controller.deleteContent(),
);

// Loading dialog
DialogUtils.showLoading(context: context, message: 'Saving...');
DialogUtils.hideLoading(context: context);
```

### Toast Utils
```dart
// Import
import '../../../core/utils/toast_utils.dart';

// Show toasts (non-blocking notifications)
ToastUtils.showSuccess(context, 'Saved successfully!');
ToastUtils.showError(context, 'Network error');
ToastUtils.showWarning(context, 'Check your input');
ToastUtils.showInfo(context, 'New update available');
```

### Validator Utils
```dart
// Import
import '../../../core/utils/validator_utils.dart';

// Use in CustomTextFormField
CustomTextFormField(
  label: 'Email',
  validator: ValidatorUtils.validateEmail,
)

CustomTextFormField(
  label: 'Password',
  validator: ValidatorUtils.validatePassword,  // 8+ chars, uppercase, lowercase, number
)

CustomTextFormField(
  label: 'Phone',
  validator: ValidatorUtils.validatePhone,
)

CustomTextFormField(
  label: 'URL',
  validator: ValidatorUtils.validateUrl,
)

CustomTextFormField(
  label: 'Username',
  validator: (value) => ValidatorUtils.validateMinLength(value, 3),
)
```

### Date Utils
```dart
// Import
import '../../../core/utils/date_utils.dart';

// Format dates
AppDateUtils.formatDate(DateTime.now());         // "Nov 26, 2025"
AppDateUtils.formatTime(DateTime.now());         // "2:30 PM"
AppDateUtils.formatRelative(DateTime.now());     // "2h ago"
AppDateUtils.formatSmartDate(DateTime.now());    // "Today" / "Yesterday"

// Check dates
AppDateUtils.isToday(date);
AppDateUtils.isPast(date);
AppDateUtils.isFuture(date);
```

### API Service
```dart
// Import
import '../../../core/services/api_service.dart';

// In controller
class MyController extends GetxController {
  final ApiService _api = ApiService();
  
  Future<void> fetchData() async {
    try {
      // GET
      final data = await _api.get('/user/profile');
      
      // POST
      final response = await _api.post('/content', body: {
        'prompt': 'Generate text',
        'type': 'article',
      });
      
      // PUT
      await _api.put('/user/profile', body: {'name': 'John'});
      
      // DELETE
      await _api.delete('/content/123');
      
    } catch (e) {
      // Handle error
      ToastUtils.showError(Get.context!, e.toString());
    }
  }
  
  void login(String token) {
    _api.setAuthToken(token);  // Set JWT token
  }
  
  void logout() {
    _api.clearAuthToken();  // Clear token
  }
}
```

---

## ✅ BEST PRACTICES CHECKLIST

**Before submitting any screen:**

### Code Structure
- [ ] Main page file is under 800 lines
- [ ] Complex sections split into widgets/ folder
- [ ] Each widget file is under 800 lines
- [ ] GetX controller created for state management
- [ ] Proper folder structure (views/, controllers/, widgets/, models/)

### Custom Widgets Usage
- [ ] Uses H1, H2, H3, BodyText (NEVER Text())
- [ ] Uses CustomTextField/CustomTextFormField (NEVER TextField())
- [ ] Uses PrimaryButton/SecondaryButton (NEVER ElevatedButton())
- [ ] Uses Gap() for spacing (NEVER SizedBox())
- [ ] Uses AdaptiveLoading for loaders

### Theme & Styling
- [ ] All colors use AppTheme constants (NEVER hardcoded hex)
- [ ] All font sizes use FontSizes constants (NEVER hardcoded numbers)
- [ ] All spacing uses AppTheme.spacing constants
- [ ] All border radius uses AppTheme.borderRadius constants
- [ ] Responsive layout using FontSizes breakpoints (see Responsiveness section below)

### State Management
- [ ] Uses Obx() for reactive UI updates
- [ ] Handles loading state (shows AdaptiveLoading)
- [ ] Handles error state (shows ErrorDisplayWidget)
- [ ] Handles empty state (shows EmptyStateWidget)
- [ ] Handles success state (shows content)

### Utilities
- [ ] Form validation uses ValidatorUtils
- [ ] API calls use ApiService (never http package directly)
- [ ] Dialogs use DialogUtils
- [ ] Toasts use ToastUtils
- [ ] Date formatting uses AppDateUtils

### Quality
- [ ] No console warnings or errors
- [ ] Follows Dart/Flutter linting rules
- [ ] Code is well-commented
- [ ] Variable/function names are descriptive
- [ ] No unused imports or variables

---

## 📱 RESPONSIVENESS (IMPORTANT - Follow This Pattern!)

### Breakpoints (Defined in FontSizes)
```dart
// From lib/core/constants/font_sizes.dart
FontSizes.mobileBreakpoint = 768.0   // < 768px = Mobile
FontSizes.tabletBreakpoint = 1024.0  // 768-1024px = Tablet
FontSizes.desktopBreakpoint = 1440.0 // >= 1024px = Desktop
```

### ✅ RECOMMENDED: Inline Pattern (Used in Landing Page)
```dart
// This is the pattern used throughout the landing page
class MySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < FontSizes.mobileBreakpoint;
    final isTablet = screenWidth >= FontSizes.mobileBreakpoint && 
                     screenWidth < FontSizes.tabletBreakpoint;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppTheme.spacing16 : AppTheme.spacing48,
        vertical: AppTheme.spacing64,
      ),
      child: isMobile 
        ? _buildMobileLayout()
        : _buildDesktopLayout(),
    );
  }
}
```

### ✅ ALTERNATIVE: Responsive Helper Class (Optional)
```dart
// Available in lib/core/utils/responsive.dart
// Use this if you prefer helper methods over inline checks

import '../../../core/utils/responsive.dart';

class MySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: Responsive.padding(context), // Auto padding based on screen
      child: Responsive.isMobile(context)
        ? _buildMobileLayout()
        : _buildDesktopLayout(),
    );
  }
}
```

### Responsive Patterns

**Pattern 1: Mobile vs Desktop Layout**
```dart
final isMobile = screenWidth < FontSizes.mobileBreakpoint;

return isMobile 
  ? Column(children: [...])  // Stack vertically on mobile
  : Row(children: [...]);    // Side by side on desktop
```

**Pattern 2: Mobile, Tablet, Desktop**
```dart
final isMobile = screenWidth < FontSizes.mobileBreakpoint;
final isTablet = screenWidth >= FontSizes.mobileBreakpoint && 
                 screenWidth < FontSizes.tabletBreakpoint;

Widget _buildHeadline() {
  double fontSize;
  if (isMobile) {
    fontSize = 36;
  } else if (isTablet) {
    fontSize = 48;
  } else {
    fontSize = 60;  // Desktop
  }
  
  return DisplayText('Hello', fontSize: fontSize);
}
```

**Pattern 3: Responsive Padding**
```dart
padding: EdgeInsets.symmetric(
  horizontal: isMobile ? AppTheme.spacing16 : AppTheme.spacing48,
  vertical: AppTheme.spacing64,
)
```

**Pattern 4: Responsive Grid Columns**
```dart
Widget _buildGrid(bool isMobile, bool isTablet) {
  int columns;
  if (isMobile) {
    columns = 1;
  } else if (isTablet) {
    columns = 2;
  } else {
    columns = 3;
  }
  
  return GridView.builder(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columns,
      crossAxisSpacing: AppTheme.spacing24,
      mainAxisSpacing: AppTheme.spacing24,
    ),
    itemBuilder: (context, index) => _buildCard(),
  );
}
```

### Rules for Responsiveness

1. **Use Existing Breakpoints**: Always use `FontSizes.mobileBreakpoint` (768px) and `FontSizes.tabletBreakpoint` (1024px)
2. **Inline Checks Preferred**: For consistency with landing page, use inline `isMobile` checks
3. **Responsive Helper Optional**: Use `Responsive` class only if it makes code cleaner
4. **Never Hardcode Breakpoints**: ❌ `screenWidth < 600` ✅ `screenWidth < FontSizes.mobileBreakpoint`
5. **Test All Sizes**: Always test mobile (375px), tablet (768px), and desktop (1440px)

### Common Responsive Values

```dart
// Padding
horizontal: isMobile ? AppTheme.spacing16 : AppTheme.spacing48

// Max Width (for centered content)
maxWidth: isMobile ? double.infinity : 1200

// Font Sizes
fontSize: isMobile ? 36 : 60

// Button Width
width: isMobile ? double.infinity : 200  // Full width on mobile

// Grid Columns
crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 3)
```

---

## 📦 PACKAGES (Already Installed)

```yaml
dependencies:
  flutter:
    sdk: flutter
  get: ^4.6.6           # State management
  go_router: ^14.0.0    # Routing
  http: ^1.2.0          # HTTP client
  gap: ^3.0.1           # Spacing widget
```

---

## 🚀 IMPLEMENTATION FLOW

**When creating a new screen:**

1. **Read Theme Files** (5 min)
   - Read `app_theme.dart` for colors, spacing, borders
   - Read `font_sizes.dart` for typography

2. **Create Folder Structure** (2 min)
   ```
   features/my_feature/
   ├── views/my_feature_page.dart
   ├── controllers/my_feature_controller.dart
   └── widgets/
   ```

3. **Create Controller First** (10 min)
   - Define reactive state variables (.obs)
   - Create methods for data fetching/mutations
   - Handle loading/error states

4. **Create Main Page** (15 min)
   - Set up Scaffold with AppBar
   - Wrap body in Obx() for reactivity
   - Handle loading/error/empty/success states
   - Keep under 800 lines

5. **Create Widget Files** (30 min)
   - Split complex sections into separate widget files
   - Each widget file under 800 lines
   - Use custom widgets (H1, Gap, PrimaryButton, etc.)

6. **Test & Verify** (10 min)
   - Run app and test all states
   - Check responsive layout (mobile, tablet, desktop)
   - Verify no console errors
   - Check against checklist above

---

**🎯 You now have everything needed to build production-ready screens!**

**Remember:** ALWAYS use custom widgets, Gap, AppTheme constants, and keep files under 800 lines!
