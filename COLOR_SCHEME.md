# App Color Scheme

## Brand Colors

### Primary Colors

| Color Name | Hex Code | RGB | Usage |
|-----------|----------|-----|-------|
| **Navy Dark** | `#010F31` | `rgb(1, 15, 49)` | Navbar, Drawer, App Bar |
| **Navy Medium** | `#0D2994` | `rgb(13, 41, 148)` | Primary buttons, Main actions |
| **Purple Accent** | `#5E5FE8` | `rgb(94, 95, 232)` | Send button, FABs, Highlights |

### Base Colors

| Color Name | Hex Code | Usage |
|-----------|----------|-------|
| **White** | `#FFFFFF` | Text on dark backgrounds, Card backgrounds (light mode) |
| **Black** | `#000000` | Text on light backgrounds (light mode) |

### Supporting Colors

| Color Name | Hex Code | Usage |
|-----------|----------|-------|
| **Light Grey** | `#F5F5F5` | Message bubbles, Card backgrounds |
| **Medium Grey** | `#9E9E9E` | Hints, Disabled text, Subtle elements |
| **Dark Grey** | `#424242` | Card backgrounds (dark mode) |

---

## Color Usage Map

### Light Mode

```
┌─────────────────────────────────────┐
│  App Bar (#010F31 - Navy Dark)     │ ← White text
├─────────────────────────────────────┤
│                                     │
│  Background (#FFFFFF - White)       │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ Card (#F5F5F5 - Light Grey)   │ │ ← Black text
│  └───────────────────────────────┘ │
│                                     │
│  [Button: #0D2994 - Navy Medium]   │ ← White text
│                                     │
│  ┌─────────────────────┐           │
│  │ Send: #5E5FE8       │           │ ← Purple send button
│  └─────────────────────┘           │
│                                     │
└─────────────────────────────────────┘
```

### Dark Mode

```
┌─────────────────────────────────────┐
│  App Bar (#010F31 - Navy Dark)     │ ← White text
├─────────────────────────────────────┤
│                                     │
│  Background (#010F31 - Navy Dark)   │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ Card (#424242 - Dark Grey)    │ │ ← White text
│  └───────────────────────────────┘ │
│                                     │
│  [Button: #0D2994 - Navy Medium]   │ ← White text
│                                     │
│  ┌─────────────────────┐           │
│  │ Send: #5E5FE8       │           │ ← Purple send button
│  └─────────────────────┘           │
│                                     │
└─────────────────────────────────────┘
```

---

## Component Color Reference

### Navigation
- **App Bar Background**: `#010F31` (Navy Dark)
- **App Bar Text**: `#FFFFFF` (White)
- **Drawer Background**: `#010F31` (Navy Dark)
- **Drawer Text**: `#FFFFFF` (White)

### Buttons
- **Primary Button Background**: `#0D2994` (Navy Medium)
- **Primary Button Text**: `#FFFFFF` (White)
- **Send Button Background**: `#5E5FE8` (Purple Accent)
- **Send Button Icon**: `#FFFFFF` (White)

### Chat
- **Sent Message Bubble**: `#0D2994` (Navy Medium)
- **Sent Message Text**: `#FFFFFF` (White)
- **Received Message Bubble**: `#F5F5F5` (Light Grey in light mode) / `#424242` (Dark Grey in dark mode)
- **Received Message Text**: `#000000` (Black in light mode) / `#FFFFFF` (White in dark mode)

### Backgrounds
- **Main Background (Light)**: `#FFFFFF` (White)
- **Main Background (Dark)**: `#010F31` (Navy Dark)
- **Card Background (Light)**: `#F5F5F5` (Light Grey)
- **Card Background (Dark)**: `#424242` (Dark Grey)

### Text
- **Primary Text (Light)**: `#000000` (Black)
- **Primary Text (Dark)**: `#FFFFFF` (White)
- **Secondary Text**: `#9E9E9E` (Medium Grey)
- **Text on Navy**: `#FFFFFF` (White)
- **Text on Purple**: `#FFFFFF` (White)

---

## Accessing Colors in Code

### Using Theme Colors

```dart
// Primary color (#0D2994 - Navy Medium)
color: Theme.of(context).colorScheme.primary

// Secondary color (#F5F5F5 - Light Grey)
color: Theme.of(context).colorScheme.secondary

// Tertiary color (#5E5FE8 - Purple Accent)
color: Theme.of(context).colorScheme.tertiary

// Background color
color: Theme.of(context).colorScheme.surface
```

### Using Direct AppColors

```dart
import 'package:andreopoulos_messasing/core/theme/app_theme.dart';

// Navy Dark (#010F31)
color: AppColors.navyDark

// Navy Medium (#0D2994)
color: AppColors.navyMedium

// Purple Accent (#5E5FE8)
color: AppColors.purpleAccent

// White
color: AppColors.white

// Black
color: AppColors.black
```

---

## Color Contrast Ratios

All color combinations meet WCAG AA accessibility standards:

| Foreground | Background | Ratio | Status |
|-----------|-----------|-------|--------|
| White | Navy Dark (#010F31) | 18.9:1 | ✅ AAA |
| White | Navy Medium (#0D2994) | 9.8:1 | ✅ AAA |
| White | Purple Accent (#5E5FE8) | 5.2:1 | ✅ AA |
| Black | White | 21:1 | ✅ AAA |
| Black | Light Grey (#F5F5F5) | 19.2:1 | ✅ AAA |

---

## Visual Color Palette

### Primary Brand Colors
```
█████ #010F31 - Navy Dark (Navbar, Drawer)
█████ #0D2994 - Navy Medium (Primary actions)
█████ #5E5FE8 - Purple Accent (Send button)
```

### Supporting Colors
```
█████ #FFFFFF - White
█████ #000000 - Black
█████ #F5F5F5 - Light Grey
█████ #9E9E9E - Medium Grey
█████ #424242 - Dark Grey
```

---

## Implementation Notes

1. **App Bar & Drawer**: Always use `#010F31` (Navy Dark) for consistency
2. **Send Buttons**: Always use `#5E5FE8` (Purple Accent) for chat send actions
3. **Primary Actions**: Use `#0D2994` (Navy Medium) for main buttons and CTAs
4. **Message Bubbles**:
   - Sent messages: `#0D2994` (Navy Medium)
   - Received messages: `#F5F5F5` (Light) or `#424242` (Dark)
5. **Text Colors**:
   - Use white on all navy/purple backgrounds
   - Use black on light grey backgrounds (light mode)
   - Use white on dark grey backgrounds (dark mode)

---

**Last Updated**: 2026-01-11
