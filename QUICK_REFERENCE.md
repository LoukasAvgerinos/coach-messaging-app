# Quick Reference Guide

## Common Tasks & Where to Find Files

### 🔐 Authentication
| Task | Location |
|------|----------|
| Login UI | `features/auth/presentation/pages/login_page.dart` |
| Register UI | `features/auth/presentation/pages/register_page.dart` |
| Password Guidelines | `features/auth/presentation/pages/password_guidelines_page.dart` |
| Auth Logic | `features/auth/services/auth_service.dart` |
| Auth Gate | `features/auth/services/auth_gate.dart` |

### 💬 Chat & Messaging
| Task | Location |
|------|----------|
| Chat Page | `features/chat/presentation/pages/chat_page.dart` |
| Athlete Messages | `features/chat/presentation/pages/athlete_messages_page.dart` |
| Coach Messages | `features/chat/presentation/pages/coach_messages_page.dart` |
| User Tile Widget | `features/chat/presentation/widgets/user_tile.dart` |
| Chat Service | `features/chat/services/chat_service.dart` |
| Message Listener | `features/chat/services/message_listener_service.dart` |
| Message Model | `features/chat/data/models/message_model.dart` |

### 👤 Profile Management
| Task | Location |
|------|----------|
| Profile View | `features/profile/presentation/pages/profile_page.dart` |
| Profile Edit | `features/profile/presentation/pages/profile_edit_page.dart` |
| Profile Check | `features/profile/presentation/pages/profile_check_page.dart` |
| Profile Service | `features/profile/services/profile_service.dart` |
| Profile Model | `features/profile/data/models/athlete_profile_model.dart` |

### 🏃 Race Tracking
| Task | Location |
|------|----------|
| Races Page | `features/race/presentation/pages/races_page.dart` |
| Athlete Races | `features/race/presentation/pages/athlete_races_page.dart` |
| Coach Races | `features/race/presentation/pages/coach_races_page.dart` |
| Race Edit | `features/race/presentation/pages/race_edit_page.dart` |
| Race Service | `features/race/services/race_service.dart` |
| Race Model | `features/race/data/models/race_model.dart` |

### 👨‍🏫 Coach Features
| Task | Location |
|------|----------|
| Coach Dashboard | `features/coach/presentation/pages/coach_dashboard_page.dart` |
| Athlete List | `features/coach/presentation/pages/coach_athlete_list_page.dart` |
| Athlete Detail | `features/coach/presentation/pages/coach_athlete_detail_page.dart` |

### 🏠 Home & Settings
| Task | Location |
|------|----------|
| Home Page | `features/home/presentation/pages/home_page.dart` |
| Settings | `features/home/presentation/pages/settings_page.dart` |

### 🔔 Notifications
| Task | Location |
|------|----------|
| Notification Service | `features/notifications/services/notification_service.dart` |

### 🎨 Theme & Styling
| Task | Location |
|------|----------|
| Theme Definition | `core/theme/app_theme.dart` |
| Theme Provider | `core/theme/theme_provider.dart` |
| Theme Toggle | `shared/widgets/theme/theme_toggle_button.dart` |

### 🧩 Shared Components
| Task | Location |
|------|----------|
| Primary Button | `shared/widgets/buttons/primary_button.dart` |
| Text Field | `shared/widgets/inputs/app_text_field.dart` |
| App Drawer | `shared/widgets/navigation/app_drawer.dart` |

### 🛠️ Utilities & Constants
| Task | Location |
|------|----------|
| Input Validators | `core/utils/validators.dart` |
| Date/Text Formatters | `core/utils/formatters.dart` |
| Firestore Constants | `core/constants/firestore_constants.dart` |
| Asset Paths | `core/constants/asset_constants.dart` |

## 📁 Directory Shortcuts

```bash
# Authentication
cd lib/features/auth/

# Chat
cd lib/features/chat/

# Profile
cd lib/features/profile/

# Races
cd lib/features/race/

# Coach
cd lib/features/coach/

# Shared Widgets
cd lib/shared/widgets/

# Core Utilities
cd lib/core/
```

## 🔍 Search Tips

### Find a specific feature
```bash
# Example: Find all chat-related files
find lib/features/chat -name "*.dart"

# Example: Find all pages
find lib -name "*_page.dart"

# Example: Find all services
find lib -name "*_service.dart"
```

### Search for imports
```bash
# Find files importing auth_service
grep -r "auth_service.dart" lib/

# Find files using ChatService
grep -r "ChatService" lib/
```

## 🎯 Common Patterns

### Adding a New Feature
1. Create folder: `lib/features/my_feature/`
2. Add subdirectories:
   - `data/models/`
   - `presentation/pages/`
   - `presentation/widgets/`
   - `services/`
3. Create files following naming conventions
4. Use package imports

### Adding a New Page
1. Location: `features/{feature}/presentation/pages/`
2. Name: `my_new_page.dart`
3. Import: `import 'package:andreopoulos_messasing/features/{feature}/presentation/pages/my_new_page.dart';`

### Adding a Shared Widget
1. Location: `shared/widgets/{category}/`
2. Name: Descriptive (e.g., `custom_card.dart`)
3. Make it reusable across features

## 💡 Best Practices

✅ Use feature folders for feature-specific code
✅ Use shared folder for reusable components
✅ Use core folder for app-wide utilities
✅ Use package imports (not relative)
✅ Follow naming conventions
✅ Keep related files together

❌ Don't put feature-specific code in shared
❌ Don't use relative imports
❌ Don't mix concerns (UI + business logic)
❌ Don't create circular dependencies

## 🚀 Next Steps

1. **Add State Management** (Riverpod/Bloc)
2. **Implement Repository Pattern**
3. **Add Use Cases for business logic**
4. **Set up proper routing** (go_router)
5. **Add unit tests** for each layer
6. **Add integration tests**

---

**Pro Tip**: Keep this file bookmarked for quick navigation!
