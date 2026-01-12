# Project Architecture

## Overview
This project follows **Clean Architecture** and **Feature-First** organization principles for better scalability, maintainability, and team collaboration.

## Folder Structure

```
lib/
├── main.dart                    # App entry point
├── firebase_options.dart        # Firebase configuration
│
├── core/                        # Core functionality (shared across features)
│   ├── constants/              # App-wide constants
│   │   ├── firestore_constants.dart
│   │   └── asset_constants.dart
│   ├── theme/                  # Theme configuration
│   │   ├── app_theme.dart
│   │   └── theme_provider.dart
│   ├── utils/                  # Utility functions
│   │   ├── validators.dart
│   │   └── formatters.dart
│   ├── routes/                 # App routing (future)
│   └── errors/                 # Custom exceptions (future)
│
├── shared/                     # Shared widgets & components
│   ├── widgets/
│   │   ├── buttons/           # Reusable button widgets
│   │   │   └── primary_button.dart
│   │   ├── inputs/            # Reusable input widgets
│   │   │   └── app_text_field.dart
│   │   ├── navigation/        # Navigation components
│   │   │   └── app_drawer.dart
│   │   ├── theme/             # Theme-related widgets
│   │   │   └── theme_toggle_button.dart
│   │   └── loading/           # Loading indicators
│   └── models/                # Shared models (if any)
│
├── features/                   # Feature-based organization
│   │
│   ├── auth/                  # Authentication feature
│   │   ├── data/              # Data layer
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/            # Business logic layer
│   │   │   ├── entities/
│   │   │   └── usecases/
│   │   ├── presentation/      # UI layer
│   │   │   ├── pages/
│   │   │   │   ├── login_page.dart
│   │   │   │   ├── register_page.dart
│   │   │   │   └── password_guidelines_page.dart
│   │   │   ├── widgets/
│   │   │   └── providers/
│   │   └── services/          # Firebase/External services
│   │       ├── auth_service.dart
│   │       ├── auth_gate.dart
│   │       └── login_or_register.dart
│   │
│   ├── chat/                  # Chat/Messaging feature
│   │   ├── data/
│   │   │   └── models/
│   │   │       └── message_model.dart
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   ├── chat_page.dart
│   │   │   │   ├── athlete_messages_page.dart
│   │   │   │   └── coach_messages_page.dart
│   │   │   └── widgets/
│   │   │       └── user_tile.dart
│   │   └── services/
│   │       ├── chat_service.dart
│   │       └── message_listener_service.dart
│   │
│   ├── profile/               # Profile management feature
│   │   ├── data/
│   │   │   └── models/
│   │   │       └── athlete_profile_model.dart
│   │   ├── presentation/
│   │   │   └── pages/
│   │   │       ├── profile_page.dart
│   │   │       ├── profile_edit_page.dart
│   │   │       └── profile_check_page.dart
│   │   └── services/
│   │       └── profile_service.dart
│   │
│   ├── race/                  # Race tracking feature
│   │   ├── data/
│   │   │   └── models/
│   │   │       └── race_model.dart
│   │   ├── presentation/
│   │   │   └── pages/
│   │   │       ├── races_page.dart
│   │   │       ├── athlete_races_page.dart
│   │   │       ├── coach_races_page.dart
│   │   │       └── race_edit_page.dart
│   │   └── services/
│   │       └── race_service.dart
│   │
│   ├── coach/                 # Coach-specific features
│   │   └── presentation/
│   │       └── pages/
│   │           ├── coach_dashboard_page.dart
│   │           ├── coach_athlete_list_page.dart
│   │           └── coach_athlete_detail_page.dart
│   │
│   ├── home/                  # Home/Dashboard
│   │   └── presentation/
│   │       └── pages/
│   │           ├── home_page.dart
│   │           └── settings_page.dart
│   │
│   └── notifications/         # Push notifications
│       └── services/
│           └── notification_service.dart
│
└── config/                    # App configuration (future)
```

## Clean Architecture Layers

### 1. Presentation Layer (`presentation/`)
- **Pages**: Full-screen views
- **Widgets**: Reusable UI components
- **Providers**: State management (Provider, Riverpod, Bloc, etc.)

### 2. Domain Layer (`domain/`)
- **Entities**: Business models
- **Use Cases**: Business logic operations
- Pure Dart, no Flutter dependencies

### 3. Data Layer (`data/`)
- **Models**: Data transfer objects (DTOs)
- **Repositories**: Data source abstraction
- Handles serialization/deserialization

### 4. Services Layer (`services/`)
- External integrations (Firebase, APIs)
- Platform-specific implementations

## Navigation Guide

### Quick Access Patterns

**Need to edit authentication?**
→ `features/auth/presentation/pages/`

**Need to modify chat functionality?**
→ `features/chat/`

**Need to update profile screens?**
→ `features/profile/presentation/pages/`

**Need to add a new reusable button?**
→ `shared/widgets/buttons/`

**Need to change app theme?**
→ `core/theme/`

**Need to add constants?**
→ `core/constants/`

**Need validation utilities?**
→ `core/utils/validators.dart`

## File Naming Conventions

- **Pages**: `*_page.dart` (e.g., `login_page.dart`)
- **Widgets**: Descriptive names (e.g., `message_bubble.dart`)
- **Services**: `*_service.dart` (e.g., `auth_service.dart`)
- **Models**: `*_model.dart` (e.g., `message_model.dart`)
- **Providers**: `*_provider.dart` (e.g., `chat_provider.dart`)
- **Repositories**: `*_repository.dart` (e.g., `user_repository.dart`)

## Import Best Practices

✅ **Good**: Use package imports
```dart
import 'package:andreopoulos_messasing/features/auth/services/auth_service.dart';
import 'package:andreopoulos_messasing/shared/widgets/buttons/primary_button.dart';
```

❌ **Bad**: Avoid relative imports
```dart
import '../../services/auth_service.dart';
import '../../../shared/buttons/primary_button.dart';
```

## Benefits of This Structure

### 1. **Scalability**
- Easy to add new features without affecting existing code
- Clear separation of concerns

### 2. **Maintainability**
- Easy to locate specific functionality
- Consistent organization across features

### 3. **Testability**
- Each layer can be tested independently
- Clear dependencies make mocking easier

### 4. **Team Collaboration**
- Multiple developers can work on different features
- Minimal merge conflicts

### 5. **Code Reusability**
- Shared widgets centralized in one place
- Core utilities available to all features

## Future Improvements

1. **Dependency Injection** (GetIt, Provider, Riverpod)
2. **State Management** (Bloc, Riverpod, or Provider)
3. **Repository Pattern** for data access
4. **Use Cases** for business logic
5. **Routing** (go_router or auto_route)
6. **Environment Configuration** (dev, staging, prod)

## Migration Complete ✅

All files have been successfully reorganized according to this architecture. The app compiles without errors and maintains all existing functionality.

---

**Last Updated**: 2026-01-11
