# iWitnez

> Stay Connected. Stay Protected.

A personal safety and witness mobile application built with Flutter, featuring live location sharing with trusted contacts and emergency protection capabilities.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
  - [Pattern & Structure](#pattern--structure)
  - [State Management](#state-management)
  - [Navigation](#navigation)
  - [Theming & Design](#theming--design)
- [Directory Structure](#directory-structure)
- [Feature Modules](#feature-modules)
  - [Splash](#splash)
  - [Onboarding](#onboarding)
  - [Auth](#auth)
- [Core Layer](#core-layer)
  - [Constants](#constants)
  - [Utils](#utils)
  - [Widgets](#widgets)
- [Assets](#assets)
- [Getting Started](#getting-started)
- [Notable Design Patterns](#notable-design-patterns)
- [Current Status & Roadmap](#current-status--roadmap)

---

## Project Overview

**iWitnez** is a Flutter-based mobile application focused on personal safety. The app enables users to:

- Share live location with trusted circles in real-time
- Record, share, and request help during emergencies
- Ensure loved ones are protected with witness-style safety features

The app ships with a **dual-role architecture** with two independent user experiences**:

1. **Main User** — the protected person using the app for personal safety (shares live location, records emergencies, manages trusted contacts). Color palette: purple → blue.
2. **Trusted Contact** — the loved one who watches over the Main User (monitors location, stays updated, receives alerts). Color palette: blue → teal green.

The current build covers:
  - Complete onboarding + authentication flow (splash, onboarding, login, create account, forgot password, email verification)
  - **Role selection cards** on Login and Create Account screens
  - **Two independent shell routes** (MainUser shell + TrustedContact shell) with a floating bottom navigation bar, each with Home / Chat / Calls / Profile screens
  - 8 placehodler pages with large gradient "screen text" dummy content for the navigation flows (until real features are implemented.

---

## Tech Stack

| Category         | Package / Tool                          | Version   | Usage                                     |
| ---------------- | --------------------------------------- | --------- | ----------------------------------------- |
| **Framework**    | Flutter                                 | SDK ^3.12 | Cross-platform mobile UI framework        |
| **Language**     | Dart                                    | 3.12+     | Application language                      |
| **State Mgmt**   | `flutter_riverpod`                      | ^3.4.3    | Reactive state (Notifier / NotifierProvider) |
| **Navigation**   | `go_router`                             | ^18.0.1   | Declarative routing with Provider integration |
| **Responsive UI**| `flutter_screenutil`                    | ^5.9.3    | Adaptive sizing (design: 390 x 844)       |
| **Fonts**        | `google_fonts`                          | ^8.2.1    | Inter + future Philosopher support        |
| **Icons**        | `cupertino_icons`                       | ^1.0.8    | iOS-style icon set                        |
| **SVG**          | `flutter_svg`                           | ^2.3.0    | Vector icon rendering (email/lock/person) |
| **Networking**   | `dio`                                   | ^5.11.1   | HTTP client (**declared, not yet wired**) |
| **Launcher**     | `flutter_launcher_icons`                | ^0.14.4   | App icon generation (Android + iOS)       |
| **Lints**        | `flutter_lints`                         | ^6.0.0    | Static analysis rules                     |

> **Note:** The `dio` package is listed in dependencies but no networking layer, service classes, repository classes, or API endpoints have been implemented yet. `shared_preferences` is also **not yet added** to the project.

---

## Architecture

### Pattern & Structure

The project follows a **feature-based MVC-inspired architecture** using Riverpod for reactive state:

```
lib/
├── core/          ← Shared utilities, constants, reusable widgets, theme
├── feature/       ← Self-contained feature modules (splash, onboarding, auth)
│   └── <feature>/
│       ├── model/       ← Data models & immutable state classes
│       ├── provider/    ← Riverpod Notifiers (business logic / state)
│       ├── controller/  ← Animation controllers (extracted for separation)
│       ├── screen/      ← UI / Pages (View layer)
│       └── widget/      ← Feature-specific reusable widgets
├── router/        ← GoRouter configuration + route names
└── main.dart      ← App bootstrap, ProviderScope, ScreenUtil, MaterialApp.router
```

Each feature is encapsulated within its own folder. Cross-feature dependencies flow **upward** through `core/` (never feature → feature directly).

### State Management

The app uses **Riverpod 3.x** with the `Notifier` / `NotifierProvider` API:

| Provider | File | Purpose |
| -------- | ---- | ------- |
| `themeModeProvider` | [theme_mode_provider.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/core/constants/theme/theme_mode_provider.dart) | Global light/dark theme toggle |
| `appPages` | [app_pages.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/router/app_pages.dart) | Global GoRouter instance |
| `onboardingProvider` | [onboarding_provider.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/feature/onboarding/provider/onboarding_provider.dart) | Onboarding page index tracking |
| `userRoleProvider` | [user_role.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/core/constants/user_role/user_role.dart) | Global `UserRole` (mainUser / trustedContact) selector Notifier — autoDispose |
| `createAccountProvider` | [create_account_provider.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/feature/auth/create_account/provider/create_account_provider.dart) | Password visibility + T&C checkbox + **selected role** (autoDispose) |
| `loginProvider` | [login_provider.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/feature/auth/login/provider/login_provider.dart) | Login password visibility toggle + **selected role** (autoDispose) |

State classes are **immutable** with `copyWith()` (e.g., [CreateAccountState](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/feature/auth/create_account/model/create_account_state.dart) now carries a `UserRole role` field, defaulting to `UserRole.mainUser`).

### Navigation

**GoRouter** is wired as a Riverpod provider (`appPages`) and consumed via `MaterialApp.router` in [main.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/main.dart).

Route definitions are split into two files:
- [app_route_names.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/router/app_route_names.dart) → Centralized route path constants (includes 10 new role-based paths: `/mainUser/*` and `/trustedContact/*`)
- [app_pages.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/router/app_pages.dart) → Route builders + GoRouter config

#### Shell Routing with Floating Bottom NavBar

The authenticated app uses **two independent `StatefulShellRoute.indexedStack` instances** (one per role). Each shell owns 4 `StatefulShellBranch` instances that maintain a **separate per-tab navigation stack** (Home / Chat / Calls / Profile). Tapping the same tab twice resets to that branch's initial route.

The shell scaffold (`AppShellScaffold` in [app_shell_scaffold.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/core/widgets/app_shell_scaffold.dart)) wraps the branches and provides a custom **floating pill-shaped bottom navigation bar** (`_FloatingNavBar`): 70h height, white container with double soft shadows, 4 items in a Row. Active tab gets a gradient pill (purple→blue for Main User, blue→teal for Trusted Contact) with label text; inactive tabs show gray icon only. Uses `StatefulNavigationShell.goBranch(index, initialLocation: index == currentIndex)` for correct tab-state preservation.

Current navigation flow:
```
Splash (3s) → Onboarding Start → Onboarding Pages (3)
                ↓ (Skip)                  ↓ (Get Start)
              Login ←────────── Create Account (Terms checkbox)
                │ (choose role)             │ (choose role)
                │                           │
                │   ┌─────────────── Main User Shell ───────────────┐
                └──▶│  Home  |  Chat  |  Calls  |  Profile          │
                    │  (/mainUser/home...)                           │
                    └───────────────────────────────────────────────┘
                    ┌─────────── Trusted Contact Shell ─────────────┐
              ┌────▶│  Home  |  Chat  |  Calls  |  Profile          │
              │     │  (/trustedContact/home...)                     │
              │     └───────────────────────────────────────────────┘
         Forgot Password → Verification (OTP placeholder)
```

### Theming & Design

- **Theme class:** [AppTheme](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/core/constants/theme/app_theme.dart) — Material 3, light/dark variants, preconfigured `InputDecorationTheme`
- **Palette:** [AppColors](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/core/constants/colors/app_colors.dart) — Purple/Blue gradient primary (`#9124FF → #1A73E8`), red accent for emergency, grayscale text hierarchy
- **Typography:** [CustomTextStyle](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/core/constants/text_style/custom_text_style.dart) — Google Fonts **Inter**, 4 preset sizes (regular/semibold 14/16, bold 30/32) with gradient-text support via `Paint.shader`
- **Responsive design:** All widgets use `.h`, `.w`, `.r`, `.sp` extensions from `flutter_screenutil` with `designSize: Size(390, 844)` (iPhone 14 dimensions)

---

## Directory Structure

```
iWitnez/
├── android/                          # Android native config (Kotlin)
│   └── app/src/main/
│       ├── kotlin/com/example/iwitnez/MainActivity.kt
│       └── res/                      # Launcher icons, colors, styles
├── assets/
│   ├── images/                       # PNG assets
│   │   ├── main_logo.png             # App shield/camera logo
│   │   ├── logo_text.png             # "iWitnez" wordmark (dark)
│   │   ├── logo_text_white.png       # "iWitnez" wordmark (light)
│   │   ├── wave_bg.png               # Bottom wave decorative shape
│   │   └── onboarding[1-3].png       # 3 onboarding illustrations
│   └── svg/
│       ├── person.svg                # Person icon (text field prefix)
│       ├── email.svg                 # Email icon
│       └── lock.svg                  # Password icon
├── ios/                              # iOS native config (Swift)
│   ├── Runner/
│   │   ├── AppDelegate.swift
│   │   ├── Info.plist
│   │   └── Assets.xcassets/          # AppIcon & LaunchImage
│   └── Runner.xcworkspace/
├── lib/
│   ├── main.dart                     # App entry point (ProviderScope + GoRouter + Theme)
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_string/app_string.dart      # All UI copy / strings (incl role labels, 4 screen titles × 2 roles)
│   │   │   ├── colors/app_colors.dart          # Color palette + gradients
│   │   │   ├── image_assets/image_assets.dart  # Asset path constants
│   │   │   ├── text_style/custom_text_style.dart # Typography presets
│   │   │   ├── user_role/user_role.dart        # ⭐ NEW UserRole enum (mainUser/trustedContact) + label/subtitle extension + Riverpod UserRoleProvider Notifier
│   │   │   └── theme/
│   │   │       ├── app_theme.dart              # Light/Dark ThemeData
│   │   │       └── theme_mode_provider.dart    # Riverpod theme mode notifier
│   │   ├── utils/
│   │   │   └── app_validator.dart              # Form validators (name, email, password)
│   │   └── widgets/
│   │       ├── app_shell_scaffold.dart         # ⭐ NEW Shell scaffold + custom floating pill-shaped Bottom NavBar (4 tabs)
│   │       ├── custom_button.dart              # Gradient CTA button (loading/enabled states)
│   │       ├── pulse_circle.dart               # Signal/pulse ripple animation (splash + onboarding)
│   │       ├── role_selector.dart              # ⭐ NEW Reusable 2-card role selector (MainUser purple / TrustedContact gray) matching the UI mockup
│   │       └── textfield_hint_text.dart        # Text field label helper
│   ├── feature/
│   │   ├── splash/
│   │   │   └── screen/splash_screen.dart       # Animated splash with pulse logo + 3s timer
│   │   ├── onboarding/
│   │   │   ├── controller/start_animations.dart # Reusable entrance + pulse controller class
│   │   │   ├── model/onboarding_screen_model.dart # Onboarding page data model + list
│   │   │   ├── provider/onboarding_provider.dart  # Page index + nextPage logic
│   │   │   ├── screen/onboarding_screen.dart      # PageView with dots + Skip/Next
│   │   │   ├── widget/onboarding_widget.dart      # Single onboarding slide
│   │   │   └── onboarding_start_screen.dart       # Hero animated start screen
│   │   └── auth/
│   │       ├── create_account/
│   │       │   ├── model/create_account_state.dart # Immutable form state
│   │       │   ├── provider/create_account_provider.dart # State mutations (password toggle, T&C)
│   │       │   └── screen/create_account_screen.dart    # 4-field form + T&C + CTA
│   │       ├── login/
│   │       │   ├── provider/login_provider.dart    # Password visibility toggle
│   │       │   └── screen/login_screen.dart        # Email + password + forgot link
│   │       ├── fotgot_password/                    # (note: typo "fotgot" in folder name)
│   │       │   └── screen/forgot_password_screen.dart # Email recovery form
│   │       └── verification/
│   │           └── screen/verification_screen.dart  # OTP placeholder screen
│   │   ├── main_user/                        # ⭐ NEW Main User role feature (purple palette)
│   │   │   ├── Home_section/
│   │   │   │   └── Home/
│   │   │   │       ├── model/home_model.dart     # (scaffold stub, add real models here)
│   │   │   │       ├── provider/home_provider.dart
│   │   │   │       ├── controller/home_controller.dart
│   │   │   │       ├── screen/home_screen.dart   # ⭐ main UI
│   │   │   │       └── widget/                   # Home-specific widgets go here
│   │   │   ├── Chat_section/Chat/
│   │   │   │   ├── model/, provider/, controller/, screen/chat_screen.dart, widget/
│   │   │   ├── Calls_section/Calls/
│   │   │   │   ├── model/, provider/, controller/, screen/calls_screen.dart, widget/
│   │   │   └── Profile_section/Profile/
│   │   │       ├── model/, provider/, controller/, screen/profile_screen.dart, widget/
│   │   └── trusted_contact/                  # ⭐ NEW Trusted Contact role feature (blue→teal palette)
│   │       ├── Home_section/Home/
│   │       │   ├── model/, provider/, controller/, screen/home_screen.dart, widget/
│   │       ├── Chat_section/Chat/
│   │       │   ├── model/, provider/, controller/, screen/chat_screen.dart, widget/
│   │       ├── Calls_section/Calls/
│   │       │   ├── model/, provider/, controller/, screen/calls_screen.dart, widget/
│   │       └── Profile_section/Profile/
│   │           ├── model/, provider/, controller/, screen/profile_screen.dart, widget/
│   └── router/
│       ├── app_pages.dart                # GoRouter routes + error page
│       └── app_route_names.dart          # Route path string constants
├── analysis_options.yaml                 # Dart linting config
├── devtools_options.yaml
├── pubspec.yaml                          # Dependencies + asset declarations
├── pubspec.lock
└── README.md
```

---

## Feature Modules

### Splash

| File | Description |
| ---- | ----------- |
| [splash_screen.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/feature/splash/screen/splash_screen.dart) | Full-screen animated splash. Features stacked `PulseCircle` signal ripples behind the logo, staggered entrance animations (scale + fade + slide), gradient accent line with pulsing red recording dot, and a `Timer(3s)` auto-navigation to Onboarding Start. Uses `RepaintBoundary` for 60+ FPS isolation of the pulse layer. Hero tag `app_main_logo` shared with Onboarding Start. |

### Onboarding

| File | Role |
| ---- | ---- |
| [onboarding_start_screen.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/feature/onboarding/onboarding_start_screen.dart) | Animated intro screen reusing `StartAnimations` controller. Hero transition from splash logo. Single "Get Start" CTA → navigates to Onboarding PageView. |
| [onboarding_screen.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/feature/onboarding/screen/onboarding_screen.dart) | 3-page `PageView.builder` driven by `onboardingProvider`. Animated dot indicators, Skip button (jumps to Login), Next button advancing pages → final page goes to Create Account. |
| [onboarding_widget.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/feature/onboarding/widget/onboarding_widget.dart) | Individual slide: RichText gradient title + description + illustration. Staggers its own entrance animation per-slide using `StartAnimations`. |
| [onboarding_provider.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/feature/onboarding/provider/onboarding_provider.dart) | `Notifier<int>` tracking current page index. `changeIndex()` + `nextPage()` with smooth 300ms `animateToPage`. |
| [onboarding_screen_model.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/feature/onboarding/model/onboarding_screen_model.dart) | Data model `OnboardingScreenModel` (image, title, impText, subTitle, description) + 3-item `onboardingScreens` list covering "Share Live Location" and "Emergency Protection". |
| [start_animations.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/feature/onboarding/controller/start_animations.dart) | **Reusable animation controller class.** Encapsulates 1400ms entrance (fade + slide up with `Curves.easeOutCubic`) and 3s repeating pulse ripple. Exposes `textTransition()`, `taglineTransition()`, `buttonTransition()` wrapper methods, plus `reassemble()` hot-reload recovery and `dispose()`. Used by Onboarding Start, Onboarding Widget, Login, Create Account, Forgot Password, and Verification screens. |

### Auth

The auth subfolder contains 4 screens. Create Account and Login have dedicated Riverpod providers; Forgot Password and Verification are UI-only at this stage. Both Login and Create Account now expose a "Login as" / role selector above their first form field, matching the two-card UI mockup (purple Main User card and gray-outline Trusted Contact card with animated selection).

| Sub-feature | Files | Details |
| ----------- | ----- | ------- |
| **Create Account** | [create_account_screen.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/feature/auth/create_account/screen/create_account_screen.dart) · [create_account_provider.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/feature/auth/create_account/provider/create_account_provider.dart) · [create_account_state.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/feature/auth/create_account/model/create_account_state.dart) | 4-field form (Name, Email, Password, Confirm Password). Role selector (`RoleSelector`) placed **above "Your Name"** field as per UI mockup. SVG prefix icons, password visibility toggles (2), animated custom T&C checkbox. CTA disabled until T&C checked. On valid submit → navigates to selected role's shell using `context.go(AppRouteNames.mainUserHome)` or `AppRouteNames.trustedHome`. Validators from `AppValidator`. State is immutable `CreateAccountState` with `copyWith()` (carries `UserRole role` defaulting to `UserRole.mainUser`). Provider is `autoDispose`. |
| **Login** | [login_screen.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/feature/auth/login/screen/login_screen.dart) · [login_provider.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/feature/auth/login/provider/login_provider.dart) | Role selector (`RoleSelector`) placed **above "Email Address"** field as per UI mockup. Email + Password form, password visibility toggle, "Forgot Password?" link → Forgot Password screen. Rich text footer linking to Create Account. On valid submit → navigates to the selected role shell (same route logic as Create Account). Reuses `CreateAccountState` model for password boolean + role. |
| **Forgot Password** | [forgot_password_screen.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/feature/auth/fotgot_password/screen/forgot_password_screen.dart) | Email-only form. "Send" button navigates to Verification screen on valid input. |
| **Verification** | [verification_screen.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/feature/auth/verification/screen/verification_screen.dart) | OTP / Email verification placeholder screen (form + OTP input not yet implemented; button logic stubbed). |

> **⚠ Folder name typo:** `fotgot_password/` should be `forgot_password/` (missing 'r'). All imports use the existing name, so renaming requires a find-and-replace across the codebase.

### Role System

The role system is defined in [user_role.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/core/constants/user_role/user_role.dart):

- **`enum UserRole { mainUser, trustedContact }`** — the two possible roles
- **`extension UserRoleX`** — exposes `.label` and `.subtitle` getters (pulled from `AppString`), used by UI cards
- **`class UserRoleProvider extends Notifier<UserRole>`** + `userRoleProvider` — globally-accessible role Notifier (autoDispose)

Role selection is surfaced via the reusable **`RoleSelector`** widget in [role_selector.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/core/widgets/role_selector.dart). It renders a "Login as" heading followed by two side-by-side pill cards in a `Row`:
- **Main User card (selected):** 44.w purple circle with person icon + title "Main User" + subtitle "Manage your safety" — 4% purple bg, purple border 45%, purple icon circle filled
- **Trusted Contact card (unselected):** Gray 55% circle with group icon + title "Trusted Contact" + subtitle "View & stay updated" — transparent bg, gray border
- Uses `AnimatedContainer` (220ms) for smooth selection transitions. Card tap calls `onChanged(UserRole)` callback wired to each form provider's `setRole()` method.

### Main User Feature (`feature/main_user/`)

Four placeholder screens rendered inside the MainUser shell at routes `/mainUser/home`, `/mainUser/chat`, `/mainUser/calls`, `/mainUser/profile`. Color palette: purple → blue primary gradient.

| Screen | File | Layout |
| ------ | ---- | ------ |
| Home | [home_screen.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/feature/main_user/Home_section/Home/screen/home_screen.dart) | Logo row + role badge, gradient info card (purple→blue with title/description), huge 40sp gradient "Home Screen" text + placeholder paragraph |
| Chat | [chat_screen.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/feature/main_user/Chat_section/Chat/screen/chat_screen.dart) | "Chat" heading, role badge subtitle, gradient "Main User — Chat" 40sp title, 1-line description |
| Calls | [calls_screen.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/feature/main_user/Calls_section/Calls/screen/calls_screen.dart) | Same pattern as Chat with "Calls" heading |
| Profile | [profile_screen.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/feature/main_user/Profile_section/Profile/screen/profile_screen.dart) | Same pattern as Chat with "Profile" heading |

Each section is wrapped in two levels: `<Section>_section/` (e.g. `Home_section/`) then a PascalCase folder named after the section itself (e.g. `Home/`), and inside every section folder you will find **all 5 standard sub-layers**: `model/` (data/DTOs), `provider/` (Riverpod state), `controller/` (business logic orchestration), `screen/` (UI entrypoint — the actual screen lives here, e.g. `screen/home_screen.dart`), and `widget/` (section-specific reusable widgets). This matches the standard sub-layers used by the rest of the codebase (compare with `feature/auth/create_account/` which has `model/`, `provider/`, `screen/`, `widget/`). The primary screen lives at `<Section>_section/<Section>/screen/<section>_screen.dart`; you can later drop additional sibling screens into the same `screen/` folder (e.g. `Home_section/Home/screen/live_location_screen.dart`) or place reusable components in `widget/`. All 8 role screens are stateless placeholders using `flutter_screenutil` and are ready to be replaced with real features.

### Trusted Contact Feature (`feature/trusted_contact/`)

Four placeholder screens inside the TrustedContact shell at routes `/trustedContact/home`, `/trustedContact/chat`, `/trustedContact/calls`, `/trustedContact/profile`. Color palette: blue → teal green (0xFF12B886) to visually distinguish from the Main User experience. Directory naming uses the same **section-by-section** pattern as main_user.

| Screen | File | Layout |
| ------ | ---- | ------ |
| Home | [home_screen.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/feature/trusted_contact/Home_section/Home/screen/home_screen.dart) | Logo row + role badge, gradient info card (blue→teal), huge 40sp gradient "Home Screen" text |
| Chat | [chat_screen.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/feature/trusted_contact/Chat_section/Chat/screen/chat_screen.dart) | "Chat" heading + role badge + gradient "Trusted Contact — Chat" title |
| Calls | [calls_screen.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/feature/trusted_contact/Calls_section/Calls/screen/calls_screen.dart) | "Calls" heading + same pattern |
| Profile | [profile_screen.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/feature/trusted_contact/Profile_section/Profile/screen/profile_screen.dart) | "Profile" heading + same pattern |

---

## Core Layer

### Constants

| File | What it holds |
| ---- | ------------- |
| [app_string.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/core/constants/app_string/app_string.dart) | All user-facing strings — splash tagline, onboarding copy, auth titles, T&C labels, **role labels** (Login as / Main User / Trusted Contact / subtitles), **nav titles** (Home / Chat / Calls / Profile), and 8 role-specific screen titles + descriptions. |
| [app_colors.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/core/constants/colors/app_colors.dart) | Palette: primary purple `#5A32FA`, purple `#8E24AA`, blue `#1A73E8`, red accent `#FF2424`, grays, and the `onboardingGradient` (`#9124FF → #1A73E8`) used on titles + buttons. Trusted Contact shells add custom teal `0xFF12B886` via inline `Color()`. |
| [image_assets.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/core/constants/image_assets/image_assets.dart) | Typed paths for `assets/images/*` and `assets/svg/*` (no string literals scattered in UI code). |
| [custom_text_style.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/core/constants/text_style/custom_text_style.dart) | Inter font presets: `semiBold14`, `regular14/16`, `bold30`, `bold32(Color|Gradient)` with shader-based gradient text used extensively on screen placeholders and Home "Home Screen" headers. |
| [app_theme.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/core/constants/theme/app_theme.dart) | Light + Dark Material 3 `ThemeData` with configured `AppBarTheme` and `InputDecorationTheme` (focused/error borders, hint, prefix icon color). |
| [theme_mode_provider.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/core/constants/theme/theme_mode_provider.dart) | Global `Notifier<ThemeMode>` — `set()` + `toggleTheme()` methods. Consumed in `MyApp` to switch `themeMode:`. |
| [user_role.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/core/constants/user_role/user_role.dart) | **Role system single source of truth.** `enum UserRole { mainUser, trustedContact }` + `UserRoleX` extension (`.label`, `.subtitle`) + `class UserRoleProvider extends Notifier<UserRole>` + globally-exported `userRoleProvider`. Import in any widget that needs to know the user's role. |

### Utils

| File | Purpose |
| ---- | ------- |
| [app_validator.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/core/utils/app_validator.dart) | Static `AppValidator` methods: `validateName`, `validateEmail` (regex RFC-ish), `validatePassword` (min 8 chars), `validateConfirmPassword`, `validateRequired`. |

### Widgets

| File | Purpose |
| ---- | ------- |
| [app_shell_scaffold.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/core/widgets/app_shell_scaffold.dart) | **Shell scaffold with floating bottom navbar.** Takes `StatefulNavigationShell` + `UserRole`, renders the child `navigationShell` as body and a custom `_FloatingNavBar` as bottomNavigationBar. Navbar: 70h pill-shaped white container with double soft shadows, 4 _NavItems in a Row. Active item wraps icon + label in an `AnimatedContainer` gradient pill colored per role (purple→blue for mainUser, blue→teal for trustedContact). Inactive items show gray icon only. Uses `StatefulNavigationShell.goBranch(index, initialLocation: index == currentIndex)` so same-tab-twice resets the branch stack. |
| [custom_button.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/core/widgets/custom_button.dart) | Primary CTA: gradient background (purple → blue), 56h height, 30r border, animated 250ms. Supports `isLoading` (spinner replaces text+icon), `isEnabled` (gray disabled gradient), optional trailing `Icon`, custom width/height/radius/gradient/textStyle. Used on every screen. |
| [pulse_circle.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/core/widgets/pulse_circle.dart) | Animated signal ripple used behind the app logo. Takes an `Animation<double>` + phase `delay` for stacking multiple waves. Uses `Curves.easeOutCubic` for growth, power-curve fade-out, dynamic border width, and subtle radial gradient + box shadow glow. |
| [role_selector.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/core/widgets/role_selector.dart) | **Reusable role-picker matching the UI mockup.** `RoleSelector(selectedRole, onChanged)` renders "Login as" heading + 2 `_RoleCard` widgets side-by-side inside an Expanded Row. Each card: AnimatedContainer (220ms) with 44.w circular icon on the left + title/subtitle. Selected card = 8% purple bg, 45% purple border, white icon on filled-purple circle. Unselected = transparent bg, gray border, gray icon on gray 55% circle. Consumed by Login and Create Account screens above their first form fields. |
| [textfield_hint_text.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/core/widgets/textfield_hint_text.dart) | Padding-wrapped Text widget serving as the label that sits above each `TextFormField`. Uses `CustomTextStyle.regular14` with bold weight. |

---

## Assets

```
assets/
├── images/          (834 KB total approx)
│   ├── main_logo.png                 ← 145x145 shield/camera logo
│   ├── logo_text.png                 ← Brand wordmark (colored)
│   ├── logo_text_white.png           ← Brand wordmark (dark mode)
│   ├── wave_bg.png                   ← Decorative bottom curve
│   └── onboarding[1-3].png           ← Concept illustrations
└── svg/
    ├── person.svg                    ← Human silhouette icon
    ├── email.svg                     ← Envelope icon
    └── lock.svg                      ← Padlock icon
```

Declared in `pubspec.yaml` under `flutter.assets:` with top-level folder prefixes (`assets/images/`, `assets/svg/`). References are centralized in `ImageAssets`.

---

## Getting Started

### Prerequisites

- Flutter SDK **3.12.1 or higher** (`flutter --version`)
- Android Studio / Xcode for native builds
- A connected device or emulator (physical device recommended for testing)

### Installation

```bash
# 1. Clone / open the project
cd iWitnez

# 2. Fetch dependencies
flutter pub get

# 3. Generate launcher icons (one-time after adding/changing main_logo.png)
dart run flutter_launcher_icons

# 4. Run on a connected device
flutter run
```

### Design Size Reference

`ScreenUtilInit` is configured with `designSize: const Size(390, 844)` — match Figma designs to this canvas. Use `.h` / `.w` for dimensions, `.r` for radii, `.sp` for font sizes.

---

## Notable Design Patterns

1. **Animation Controller Extraction** — Rather than bloating screens with dozens of Animation fields, the `StartAnimations` class encapsulates entrance + pulse logic and exposes composable transition wrappers. Screens mix in `TickerProviderStateMixin` and pass `this` to the animation class. `reassemble()` overrides ensure hot reload doesn't freeze animations.

2. **Immutable State with copyWith** — `CreateAccountState` and other state holders are immutable. Providers return a new instance on every mutation, enabling safe Riverpod equality checks and predictable rebuilds.

3. **autoDispose Providers** — `createAccountProvider`, `loginProvider`, and `userRoleProvider` are `.autoDispose`, ensuring their state (password booleans, T&C, temporary role choice) resets when the user navigates away instead of leaking across sessions.

4. **RepaintBoundary Isolation** — The pulse circle layer and accent line in `SplashScreen` are wrapped in `RepaintBoundary` so the constant ripple animation only repaints its own subtree, keeping the main column static at 60 FPS.

5. **Hero Transition for Brand Continuity** — The logo in [splash_screen.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/feature/splash/screen/splash_screen.dart#L228-L237) shares the tag `'app_main_logo'` with [onboarding_start_screen.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/feature/onboarding/onboarding_start_screen.dart#L104-L112), producing a smooth cross-screen animation during the splash → start handoff.

6. **Centralized Strings & Assets** — No hard-coded strings or asset paths in UI code. All routed through `AppString` and `ImageAssets` so copy/asset changes require edits in exactly one place.

7. **Dual Independent Shell Routes** — Instead of a single shell with a mutable role prop, GoRouter declares **two separate `StatefulShellRoute.indexedStack`** trees (MainUser + TrustedContact). Shell switching is purely URL-based via `context.go(AppRouteNames.*Home)`, eliminating any shared mutable state at the routing layer and guaranteeing that a MainUser and a TrustedContact have no way to accidentally share tab stacks.

8. **Floating NavBar via AnimatedContainer Gradient Pills** — The bottom navbar in `AppShellScaffold` is a custom Container-based floating pill (not `NavigationBar`/`BottomNavigationBar`) — active tabs expand into a gradient pill using `AnimatedContainer`, visually matching the UI mockup while remaining fully declarative and role-color-aware.

9. **Role Selection Via Reusable Widget** — The `RoleSelector` 2-card UI is implemented once and reused in both Login and Create Account screens. Cards communicate role choice via a `ValueChanged<UserRole>` callback, keeping them fully decoupled from any particular form provider.

---

## Current Status & Roadmap

### ✅ Implemented

- Full splash animation (pulse waves, staggered entrance, 3s auto-route)
- Onboarding start + 3-page PageView with indicators, Skip, and Next
- Create account: 4-field form, validators, password toggles, T&C checkbox
- Login: email/password form + forgot link
- Forgot password: email input → verification navigation
- Verification: placeholder shell
- Theme system (light/dark + runtime toggle provider)
- Responsive sizing via ScreenUtil
- Reusable widgets (CustomButton, PulseCircle, TextFieldHintText)
- GoRouter navigation with typed route names
- App icons (Android + iOS adaptive)
- **⭐ Role system** — `UserRole` enum + global `userRoleProvider` + `RoleSelector` animated 2-card widget matching UI mockup
- **⭐ Role selectors on auth screens** — RoleSelector inserted above Email (Login) and above Your Name (Create Account)
- **⭐ Role-aware provider state** — `CreateAccountState` carries `UserRole role`; both `loginProvider` and `createAccountProvider` expose `setRole()`
- **⭐ Role-based navigation** — Login/CreateAccount CTAs use `context.go(AppRouteNames.mainUserHome)` or `.trustedHome` based on chosen role (cannot go back to unauthenticated flow with back button)
- **⭐ Two shell routes** — `StatefulShellRoute.indexedStack` for MainUser shell and TrustedContact shell, each with 4 `StatefulShellBranch` (Home/Chat/Calls/Profile) preserving per-tab stacks
- **⭐ Floating pill bottom navbar** — `_FloatingNavBar` inside AppShellScaffold with shadows, role-colored gradient pills for active tab, tab-reset on double-tap
- **⭐ 8 placeholder screens** with dummy "Home Screen" gradient text + descriptive placeholder copy for both roles × 4 tabs

### 🚧 Not Yet Implemented

- **Networking layer** — `dio` is a dependency but no `ApiService`, `Endpoints`, `Dio` config, interceptors, or repositories exist yet
- **Local storage** — `shared_preferences` package is **not added**; onboarding-first-run flag, auth token persistence, theme persistence, and **role choice persistence** are missing
- **Authentication backend integration** — Login/Create Account buttons currently navigate directly to shell (stubbed); real auth should call a repository, persist token, and then navigate
- **Verification (OTP) input UI** — [verification_screen.dart](file:///d:/Mir_FlutterDev/Collaborators_project/iWitnez/lib/feature/auth/verification/screen/verification_screen.dart) currently has no OTP pin field
- **Role persistence across launches** — Once `shared_preferences` is added, role choice should be persisted and restored so user doesn't re-pick role on every login
- **Single-source-of-truth role wiring** — Shell scaffold currently picks colors based on role passed by constructor (from shell route declaration), not by reading `userRoleProvider`. Could unify.
- **Real feature content in 8 role screens** — Currently dummy text. Pending: Location share UI, Emergency recording, Chat threads, Call logs, Edit profile, Contact lists, etc.
- **Forgot password folder rename** — `fotgot_password/` → `forgot_password/` (typo)
- **Tests** — No unit/widget/integration tests exist yet (test folder empty)
- **Error handling / snackbars / loaders** — API error states, themed snackbars, and form-submission loaders are not wired (CustomButton supports `isLoading` but no screen uses it)
- **GoogleFonts Philosopher** — User profile specifies Philosopher font; currently only Inter is used

---

*This README was auto-generated from a full codebase analysis of commit-time source. Regenerate after major architectural changes.*
