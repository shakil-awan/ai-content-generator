# 🔐 AUTHENTICATION PAGES - DEVELOPMENT PROMPT

**Copy this entire prompt into a new chat session with GitHub Copilot**

---

## TASK: Build Authentication System (Sign In & Sign Up Pages)

I'm building the **Authentication System** for Summarly AI Content Generator (Flutter web app). This includes Sign In and Sign Up pages with email/password and Google authentication.

### 📚 CONTEXT FILES TO READ FIRST:

**CRITICAL - Read these files before starting:**
1. `.github/instructions/FRONTEND_INSTRUCTIONS.md` - Complete development guide with custom widgets, theme, architecture patterns
2. `lib/core/theme/app_theme.dart` (281 lines) - All colors, spacing, border radius constants
3. `lib/core/constants/font_sizes.dart` (211 lines) - Typography system
4. `backend/README.md` - Backend API documentation for auth endpoints

---

## 🔑 AUTHENTICATION PAGES (2 Total)

Build the following authentication pages:

### Page 1: Sign In Page (`/signin`)

**Layout:** Split screen design (desktop), single column (mobile)

#### Left Side - Branding Panel (Desktop Only):
- **Background**: Primary gradient (blue #2563EB to light blue)
- **Logo**: Summarly logo (white, 48px height)
- **Headline**: "Welcome Back!" (DisplayText, white, 48px)
- **Subheadline**: "Continue creating verified content with AI" (BodyTextLarge, white/90% opacity)
- **Illustration**: Authentication illustration or abstract pattern
- **Testimonial Quote**: "Summarly saves me 10+ hours per week" - User name, role (BodyText, white/80%)
- **Hidden on mobile**: Show only form section

#### Right Side - Sign In Form:
- **Container**: White card, centered, max-width 480px, padding 48px
- **Heading**: "Sign in to your account" (H2, textPrimary)
- **Subheading**: "Don't have an account? [Sign up]" (BodyText with link, primary color)

**Form Fields:**
1. **Email Field**:
   - Label: "Email address" (BodyText, textSecondary)
   - CustomTextField with email icon
   - Validation: Required, valid email format
   - Error message: "Please enter a valid email address"

2. **Password Field**:
   - Label: "Password" (BodyText, textSecondary)
   - CustomTextField with password visibility toggle (eye icon)
   - Validation: Required, min 8 characters
   - Error message: "Password must be at least 8 characters"

3. **Remember Me & Forgot Password**:
   - Checkbox: "Remember me" (left aligned)
   - Link: "Forgot password?" (right aligned, primary color)
   - Row layout with space-between

4. **Sign In Button**:
   - Full-width PrimaryButton
   - Text: "Sign In"
   - Loading state with SmallLoader when submitting
   - Disabled state while loading

5. **Divider**:
   - Horizontal line with "OR" text in center
   - Light gray color (border color from theme)

6. **Google Sign In Button**:
   - Full-width SecondaryButton
   - Google logo icon (20px)
   - Text: "Continue with Google"
   - Opens Google OAuth flow

**Spacing**: Gap(24) between form fields, Gap(16) between smaller elements

**Error Handling**:
- Show ErrorDisplayWidget at top of form if login fails
- Display specific error messages: "Invalid email or password", "Account not found", "Too many attempts, try again later"
- Errors should be dismissible

**Success Flow**:
- Show success toast: "Welcome back!"
- Navigate to dashboard (`/dashboard`)
- Store auth token securely

---

### Page 2: Sign Up Page (`/signup`)

**Layout:** Split screen design (desktop), single column (mobile)

#### Left Side - Branding Panel (Desktop Only):
- **Background**: Primary gradient (blue #2563EB to light blue)
- **Logo**: Summarly logo (white, 48px height)
- **Headline**: "Start Creating Today" (DisplayText, white, 48px)
- **Subheadline**: "Join 5,000+ content creators using AI-powered verified content" (BodyTextLarge, white/90% opacity)
- **Illustration**: Onboarding illustration or dashboard preview
- **Features List**:
  - ✓ "2,000 free words per month" (BodyText, white)
  - ✓ "Instant fact-checking" (BodyText, white)
  - ✓ "AI humanization included" (BodyText, white)
- **Hidden on mobile**: Show only form section

#### Right Side - Sign Up Form:
- **Container**: White card, centered, max-width 480px, padding 48px
- **Heading**: "Create your account" (H2, textPrimary)
- **Subheading**: "Already have an account? [Sign in]" (BodyText with link, primary color)

**Form Fields:**
1. **Full Name Field**:
   - Label: "Full name" (BodyText, textSecondary)
   - CustomTextField with user icon
   - Validation: Required, min 2 characters
   - Error message: "Please enter your full name"

2. **Email Field**:
   - Label: "Email address" (BodyText, textSecondary)
   - CustomTextField with email icon
   - Validation: Required, valid email format
   - Error message: "Please enter a valid email address"

3. **Password Field**:
   - Label: "Password" (BodyText, textSecondary)
   - CustomTextField with password visibility toggle
   - Validation: Required, min 8 characters, must contain uppercase, lowercase, number
   - Error message: Dynamic based on validation failure

4. **Password Strength Indicator**:
   - Visual bar below password field
   - 4 levels: Weak (red), Fair (orange), Good (yellow), Strong (green)
   - Real-time updates as user types
   - Label: "Password strength: [level]" (CaptionText)
   - Calculation:
     - Weak: < 8 characters
     - Fair: 8+ characters
     - Good: 8+ with uppercase + lowercase + numbers
     - Strong: 8+ with uppercase + lowercase + numbers + special characters

5. **Confirm Password Field**:
   - Label: "Confirm password" (BodyText, textSecondary)
   - CustomTextField with password visibility toggle
   - Validation: Required, must match password
   - Error message: "Passwords do not match"

6. **Terms & Privacy Checkbox**:
   - Checkbox (required): "I agree to the [Terms of Service] and [Privacy Policy]"
   - Links in primary color
   - Error message if not checked: "You must agree to continue"

7. **Sign Up Button**:
   - Full-width PrimaryButton
   - Text: "Create Account"
   - Loading state with SmallLoader when submitting
   - Disabled state while loading or terms not accepted

8. **Divider**:
   - Horizontal line with "OR" text in center
   - Light gray color (border color from theme)

9. **Google Sign Up Button**:
   - Full-width SecondaryButton
   - Google logo icon (20px)
   - Text: "Continue with Google"
   - Opens Google OAuth flow

**Spacing**: Gap(24) between form fields, Gap(16) between smaller elements

**Error Handling**:
- Show ErrorDisplayWidget at top of form if signup fails
- Display specific error messages: "Email already exists", "Weak password", "Server error, please try again"
- Field-level validation errors below each input

**Success Flow**:
- Show success toast: "Account created! Please verify your email"
- Navigate to email verification page (`/verify-email`) with email parameter
- Send verification email automatically

---

## 🎯 MANDATORY REQUIREMENTS:

### Custom Widgets (NEVER use standard Flutter widgets):
- ✅ **Text**: H1, H2, H3, DisplayText, BodyText, BodyTextLarge, BodyTextSmall, CaptionText (NEVER Text())
- ✅ **Buttons**: PrimaryButton, SecondaryButton, CustomTextButton (NEVER ElevatedButton/OutlinedButton())
- ✅ **Input**: CustomTextField, CustomTextFormField (NEVER TextField())
- ✅ **Spacing**: Gap(16), Gap(24), Gap(32), Gap(48) (NEVER SizedBox())
- ✅ **Loading**: AdaptiveLoading, SmallLoader (for button loading states)
- ✅ **Error**: ErrorDisplayWidget (for form-level errors)

### Theme Constants (NEVER hardcode):
- ✅ **Colors**: AppTheme.primary, AppTheme.secondary, AppTheme.error, AppTheme.success, AppTheme.warning, AppTheme.textPrimary, AppTheme.textSecondary, AppTheme.border, AppTheme.bgPrimary, AppTheme.bgSecondary
- ✅ **Spacing**: AppTheme.spacing8/16/24/32/48/64
- ✅ **Border Radius**: AppTheme.borderRadiusMD/LG/XL
- ✅ **Fonts**: FontSizes.displayXL/h1/h2/bodyRegular/bodyLarge/bodySmall/captionRegular

### Architecture:
- ✅ **800-line limit per file** - Split into widgets
- ✅ **Folder structure**:
  ```
  features/auth/
  ├── views/
  │   ├── signin_page.dart (~150 lines)
  │   └── signup_page.dart (~150 lines)
  ├── controllers/
  │   └── auth_controller.dart (~300 lines)
  ├── widgets/
  │   ├── auth_split_layout.dart (~150 lines) - Reusable split screen
  │   ├── branding_panel.dart (~100 lines) - Left side branding
  │   ├── signin_form.dart (~250 lines) - Sign in form
  │   ├── signup_form.dart (~350 lines) - Sign up form with strength indicator
  │   ├── password_strength_indicator.dart (~100 lines)
  │   ├── social_auth_button.dart (~80 lines) - Google button
  │   └── form_divider.dart (~50 lines) - "OR" divider
  └── services/
      └── auth_service.dart (~200 lines) - API calls
  ```

### State Management with GetX:
- ✅ Create `AuthController` extending GetxController:
  ```dart
  class AuthController extends GetxController {
    // Observable state
    final isLoading = false.obs;
    final errorMessage = ''.obs;
    final rememberMe = false.obs;
    final agreeToTerms = false.obs;
    final passwordVisible = false.obs;
    final confirmPasswordVisible = false.obs;
    final passwordStrength = 'weak'.obs; // weak, fair, good, strong
    
    // Text controllers
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final nameController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    
    // Form keys
    final signInFormKey = GlobalKey<FormState>();
    final signUpFormKey = GlobalKey<FormState>();
    
    // Methods
    Future<void> signIn() async { /* implementation */ }
    Future<void> signUp() async { /* implementation */ }
    Future<void> signInWithGoogle() async { /* implementation */ }
    void calculatePasswordStrength(String password) { /* implementation */ }
    void togglePasswordVisibility() { /* implementation */ }
    
    @override
    void onClose() {
      emailController.dispose();
      passwordController.dispose();
      nameController.dispose();
      confirmPasswordController.dispose();
      super.onClose();
    }
  }
  ```

### API Integration:
- ✅ **Sign In Endpoint**: `POST /api/auth/signin`
  - Body: `{ "email": "user@example.com", "password": "password123" }`
  - Response: `{ "token": "jwt_token", "user": { "id": "...", "email": "...", "name": "..." } }`
  
- ✅ **Sign Up Endpoint**: `POST /api/auth/signup`
  - Body: `{ "name": "John Doe", "email": "user@example.com", "password": "password123" }`
  - Response: `{ "message": "Account created. Please verify your email.", "userId": "..." }`
  
- ✅ **Google OAuth Endpoint**: `POST /api/auth/google`
  - Body: `{ "idToken": "google_id_token" }`
  - Response: `{ "token": "jwt_token", "user": { ... } }`

- ✅ Use `ApiService` from utilities (already created in FRONTEND_INSTRUCTIONS.md)
- ✅ Store JWT token in secure storage (use `flutter_secure_storage` package)
- ✅ Handle error responses with proper error messages

### Validation Rules:
- ✅ **Email**: 
  - Required
  - Valid email format (use ValidatorUtils.email)
  
- ✅ **Password** (Sign In):
  - Required
  - Min 8 characters
  
- ✅ **Password** (Sign Up):
  - Required
  - Min 8 characters
  - Must contain uppercase letter
  - Must contain lowercase letter
  - Must contain number
  - Recommended: special character (for strong rating)
  
- ✅ **Full Name**:
  - Required
  - Min 2 characters
  - Max 50 characters
  
- ✅ **Confirm Password**:
  - Required
  - Must match password field

### Responsive Design:
- ✅ **Desktop** (> 1024px): 
  - Split screen layout (50/50)
  - Branding panel on left
  - Form on right
  - Form max-width 480px, centered
  
- ✅ **Tablet** (768px - 1024px):
  - Split screen (40% branding, 60% form)
  - Reduce branding panel content
  
- ✅ **Mobile** (< 768px):
  - Single column
  - Hide branding panel
  - Show logo at top of form
  - Full-width form with padding 24px
  - Stack buttons vertically if needed

---

## 🔌 GOOGLE AUTHENTICATION SETUP:

### Required Package:
```yaml
# pubspec.yaml
dependencies:
  google_sign_in: ^6.1.5
  google_sign_in_web: ^0.12.0
```

### Implementation:
```dart
// auth_service.dart
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // User cancelled
      
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;
      
      // Send idToken to backend
      final response = await ApiService.post(
        '/auth/google',
        data: {'idToken': googleAuth.idToken},
      );
      
      // Handle response (save token, navigate)
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }
}
```

---

## 📊 PROGRESS TRACKING:

Create `AUTH_PAGES_PROGRESS.md` based on `SCREEN_PROGRESS_TEMPLATE.md` and update it with:
- ✅ / 🔄 / ⏳ for each file (controller, service, views, widgets)
- Line counts for each file
- API integration status
- Google OAuth setup status
- Any issues or blockers
- Completion percentage

---

## 🚀 IMPLEMENTATION STEPS:

1. **Read Context Files** (5 min):
   - Read FRONTEND_INSTRUCTIONS.md completely
   - Read app_theme.dart for colors/spacing/borders
   - Read font_sizes.dart for typography
   - Review backend API documentation for auth endpoints

2. **Create Folder Structure** (2 min):
   - Create features/auth/views/, controllers/, widgets/, services/ folders

3. **Add Dependencies** (3 min):
   - Add google_sign_in packages to pubspec.yaml
   - Add flutter_secure_storage (if not already added)
   - Run `flutter pub get`

4. **Create Auth Service** (15 min):
   - auth_service.dart with API methods
   - Sign in, sign up, Google OAuth
   - Error handling

5. **Create Auth Controller** (20 min):
   - AuthController with GetX
   - Observable state (isLoading, errorMessage, etc.)
   - Text controllers
   - Form keys
   - Methods (signIn, signUp, signInWithGoogle)
   - Password strength calculator
   - Validation logic

6. **Create Reusable Widgets** (30 min):
   - auth_split_layout.dart (50/50 split)
   - branding_panel.dart (left side content)
   - password_strength_indicator.dart (color bar + label)
   - social_auth_button.dart (Google button with icon)
   - form_divider.dart ("OR" divider)

7. **Create Sign In Form** (25 min):
   - signin_form.dart widget
   - Email field with validation
   - Password field with visibility toggle
   - Remember me checkbox
   - Forgot password link
   - Sign in button with loading state
   - Google button
   - Error display
   - Keep under 250 lines

8. **Create Sign Up Form** (35 min):
   - signup_form.dart widget
   - Name, email, password, confirm password fields
   - Password strength indicator integration
   - Terms & Privacy checkbox
   - Sign up button with loading state
   - Google button
   - Error display
   - Keep under 350 lines

9. **Create Page Views** (20 min):
   - signin_page.dart (~150 lines)
   - signup_page.dart (~150 lines)
   - Use auth_split_layout.dart
   - Integrate forms and branding panels
   - Add GetX bindings

10. **Update Routing** (5 min):
    - Add `/signin` and `/signup` routes to go_router
    - Add navigation from landing page "Get Started" buttons

11. **Create Progress File** (5 min):
    - Copy SCREEN_PROGRESS_TEMPLATE.md to AUTH_PAGES_PROGRESS.md
    - Fill in sections and track completion

12. **Test** (15 min):
    - Test sign in with valid/invalid credentials
    - Test sign up with validation errors
    - Test password strength indicator
    - Test Google OAuth flow
    - Test responsive layouts (resize window)
    - Verify error handling
    - Check navigation flows
    - Verify no console errors

---

## ✅ SUCCESS CRITERIA:

Authentication pages are complete when:
- [ ] Both sign in and sign up pages implemented
- [ ] All files under 800 lines
- [ ] Only custom widgets used (no Text(), SizedBox(), TextField(), ElevatedButton())
- [ ] Only AppTheme constants used (no hardcoded colors/spacing)
- [ ] Form validation working with proper error messages
- [ ] Password strength indicator functional (4 levels, real-time)
- [ ] Loading states working on all buttons
- [ ] Error handling implemented (form-level and field-level)
- [ ] Google OAuth integration working
- [ ] Remember me checkbox saves preference
- [ ] Forgot password link navigates correctly
- [ ] Sign up sends verification email
- [ ] Successful login navigates to dashboard
- [ ] Responsive on all 3 breakpoints (desktop split screen, mobile single column)
- [ ] No console errors or warnings
- [ ] AUTH_PAGES_PROGRESS.md shows 100% completion
- [ ] Code follows FRONTEND_INSTRUCTIONS.md patterns

---

## 🔒 SECURITY NOTES:

- ✅ Never store passwords in plain text
- ✅ Use secure storage for JWT tokens (flutter_secure_storage)
- ✅ Validate all inputs on both frontend and backend
- ✅ Use HTTPS for all API calls
- ✅ Implement rate limiting on backend (handle "too many attempts" errors)
- ✅ Clear sensitive data from memory on page exit
- ✅ Use password visibility toggle (default: hidden)
- ✅ Implement CSRF protection if using cookies

---

**START NOW:** Read FRONTEND_INSTRUCTIONS.md, app_theme.dart, and font_sizes.dart, then begin implementation with dependencies and folder structure.
