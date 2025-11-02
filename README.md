# Cardy - Business Card Manager

A professional Flutter application for managing multiple business cards with a modern, responsive interface.

## 🌟 Features

### Core Functionality
- **📱 Multi-Card Management**: Create, edit, and store unlimited business cards
- **🎯 Smart App Initialization**: Intelligently routes based on existing cards
- **⭐ Default Card System**: Quick access to your primary business card
- **🔍 Real-Time Search**: Filter cards by name, company, or email
- **💾 Local Storage**: Persistent data storage using SharedPreferences

### User Experience
- **📱 Responsive Design**: Adaptive layout for mobile, tablet, and desktop
- **🎨 Modern UI**: Material 3 design with smooth animations
- **🔄 Pull-to-Refresh**: Update content with gesture-based refresh
- **✨ Enhanced Interactions**: Animated buttons and smooth page transitions

### Card Management
- **📝 Full CRUD Operations**: Create, read, update, and delete cards
- **👁️ Card Viewing**: Clean, detailed card display interface
- **✏️ In-Place Editing**: Update card information with form validation
- **🗑️ Safe Deletion**: Confirmation dialogs for card removal

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>= 3.0.0)
- Dart SDK (>= 3.0.0)

### Installation
1. Clone the repository:
```bash
git clone <repository-url>
cd cardy
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run
```

### Build for Production
```bash
# Web
flutter build web

# Android
flutter build apk

# iOS
flutter build ios
```

## 📱 App Structure

```
lib/
├── main.dart                 # App entry point and routing
├── models/
│   └── business_card.dart     # Data model with JSON serialization
├── services/
│   └── card_service.dart     # Storage layer with caching
└── screens/
    ├── gallery_screen.dart     # Card gallery with search/filter
    ├── card_screen.dart       # Individual card viewing
    └── edit_card_screen.dart # Card creation and editing
```

## 🎯 Smart Routing Logic

The app intelligently determines the initial screen based on data state:

- **No Cards**: Directs to edit screen for first card creation
- **Has Default Card**: Opens default card directly for quick access
- **Has Cards (No Default)**: Shows gallery for card selection

## 🔍 Search & Filtering

- **Real-time search** across name, company, and email fields
- **Case-insensitive** matching for better user experience
- **Clear search** functionality with dedicated button
- **No results state** with helpful messaging

## 📱 Responsive Design

### Layout Breakpoints
- **Mobile (< 600px)**: Single column list view
- **Tablet (600-800px)**: Two-column grid layout
- **Desktop (800-1200px)**: Three-column grid layout
- **Large Desktop (> 1200px)**: Four-column grid layout

### Adaptive Features
- **Touch-friendly** buttons and interactions on mobile
- **Hover states** and enhanced spacing on desktop
- **Optimized typography** for different screen sizes

## 🎨 UI/UX Features

### Animations
- **Staggered grid** animations when cards load
- **Button press** animations with scale effects
- **Smooth page** transitions
- **Pull-to-refresh** indicators

### Empty States
- **Onboarding flow** for new users
- **Search results** messaging
- **Clear call-to-action** buttons

## 💾 Data Management

### Storage
- **SharedPreferences** for local data persistence
- **JSON serialization** for structured data storage
- **In-memory caching** for performance optimization
- **Automatic cleanup** of corrupted data

### Card Fields
- **Name** (required)
- **Email** (required)
- **Phone** (required)
- **Company** (optional)
- **Title** (optional)
- **Website** (optional)
- **Default flag** for quick access

## 🧪 Testing

### Test Coverage
- **Unit Tests**: Model and service layer validation
- **Widget Tests**: UI component testing
- **Integration Tests**: End-to-end user flows

### Running Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test_simple.dart

# Generate coverage report
flutter test --coverage
```

## 🚀 Performance Optimizations

### Caching Strategy
- **In-memory cache** for frequently accessed data
- **Lazy loading** of card data
- **Optimized filtering** with pre-computed lowercase values
- **Efficient state management** with minimal rebuilds

### Build Optimizations
- **Tree shaking** for unused code elimination
- **Asset optimization** for fonts and images
- **WASM compilation** for improved web performance

## 🔧 Development

### Code Style
- **Dart/Flutter conventions** throughout
- **Material 3 design system** compliance
- **Type safety** with null safety features
- **Clean architecture** with separation of concerns

### Key Dependencies
- `shared_preferences`: Local data storage
- `uuid`: Unique identifier generation
- `flutter/material.dart`: UI framework

## 📱 Platform Support

- **Android**: API 21+ (Android 5.0+)
- **iOS**: iOS 11.0+
- **Web**: Modern browsers (Chrome, Safari, Firefox, Edge)
- **Desktop**: Windows, macOS, Linux (experimental)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Run the test suite
6. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🔗 Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Material 3 Design](https://m3.material.io/)
- [Dart Language Guide](https://dart.dev/guides/language/language-tour)

---

**Cardy** - Your professional business card companion 📇✨