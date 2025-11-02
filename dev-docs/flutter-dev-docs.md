# Flutter Development Documentation

## Architecture Patterns & Design

### MVVM Architecture with ChangeNotifier

Flutter's recommended architecture pattern using `ChangeNotifier` for state management:

```dart
class HomeViewModel extends ChangeNotifier {
  User? get user => // ...
  
  late final Command load;
  
  HomeViewModel() {
    load = Command(_load)..execute();
  }
  
  Future<void> _load() async {
    // load user data
  }
}
```

### Dependency Injection Pattern

Inject dependencies through constructors for testability:

```dart
class MyRepository {
  MyRepository({required MyService myService})
          : _myService = myService;
  
  late final MyService _myService;
}
```

### Command Pattern for Actions

Encapsulate async operations with state management:

```dart
class Command extends ChangeNotifier {
  bool _running = false;
  bool get running => _running;
  
  Future<void> execute() async {
    if (_running) return;
    
    _running = true;
    notifyListeners();
    
    try {
      await _action();
      _completed = true;
    } on Exception catch (error) {
      _error = error;
    } finally {
      _running = false;
      notifyListeners();
    }
  }
}
```

## Project Structure Templates

### Standard Flutter Project Structure

```
lib/
├── main.dart              # App entry point
├── models/                 # Data models
│   └── business_card.dart
├── screens/                # UI screens
│   ├── edit_screen.dart
│   ├── card_screen.dart
│   └── gallery_screen.dart
├── services/               # Business logic & data layer
│   └── card_service.dart
└── utils/                  # Utilities
    └── brightness.dart
```

### Data Layer Patterns

#### Repository Pattern

```dart
abstract class CardRepository {
  Future<List<BusinessCard>> getCards();
  Future<void> saveCard(BusinessCard card);
  Future<void> deleteCard(String id);
  Stream<String?> observeDefaultCardId();
}
```

#### Service Layer

```dart
class CardService {
  CardService(this._repository);
  
  final CardRepository _repository;
  
  Future<List<BusinessCard>> getCards() async {
    return await _repository.getCards();
  }
}
```

## UI Development Patterns

### ListenableBuilder for Reactive UI

```dart
ListenableBuilder(
  listenable: viewModel,
  builder: (context, _) {
    if (viewModel.running) {
      return const Center(child: CircularProgressIndicator());
    }
    return YourContent();
  },
)
```

### Responsive Design

```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 600) {
      return TabletLayout();
    }
    return MobileLayout();
  },
)
```

## State Management

### SharedPreferences for Simple Key-Value Data

```dart
class ThemeRepository {
  Future<Result<bool>> isDarkMode() async {
    try {
      final value = await _service.isDarkMode();
      return Result.ok(value);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
  
  Stream<bool> observeDarkMode() => _darkModeController.stream;
}
```

### Navigation Patterns

### Named Routes

```dart
MaterialApp(
  initialRoute: '/',
  routes: {
    '/': (context) => const GalleryScreen(),
    '/edit': (context) => const EditScreen(),
    '/card': (context) => const CardScreen(),
  },
)
```

### Smart App Initialization

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final cardService = CardService();
  final hasCards = await cardService.hasCards();
  final defaultCardId = await cardService.getDefaultCardId();
  
  runApp(BusinessCardApp(
    cardService: cardService,
    initialRoute: _getInitialRoute(hasCards, defaultCardId),
  ));
}

String _getInitialRoute(bool hasCards, String? defaultCardId) {
  if (!hasCards) return '/edit';
  if (defaultCardId != null) return '/card/$defaultCardId';
  return '/';
}
```

## Testing Patterns

### Fake Repository for Testing

```dart
class FakeCardRepository implements CardRepository {
  List<BusinessCard> cards = [];
  
  @override
  Future<List<BusinessCard>> getCards() async {
    return cards;
  }
  
  @override
  Future<void> saveCard(BusinessCard card) async {
    cards.add(card);
  }
}
```

### Widget Testing

```dart
testWidgets('Gallery screen displays cards', (tester) async {
  final mockService = MockCardService();
  mockService.cards = [testCard];
  
  await tester.pumpWidget(
    GalleryScreen(cardService: mockService),
  );
  
  expect(find.text('John Doe'), findsOneWidget);
});
```

## Performance Optimization

### Lazy Loading

```dart
ListView.builder(
  itemCount: cards.length,
  itemBuilder: (context, index) {
    return CardTile(card: cards[index]);
  },
)
```

### Image Caching

```dart
class CachedImage extends StatelessWidget {
  const CachedImage({super.key, required this.url});
  
  final String url;
  
  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      cacheWidth: 100,
      cacheHeight: 100,
    );
  }
}
```

## Platform Integration

### Platform-Specific Brightness

```dart
class BrightnessUtils {
  static Future<void> setMaxBrightness() async {
    if (kIsWeb) {
      // Web-specific handling
      return;
    } else if (Platform.isIOS) {
      await ScreenBrightness().setScreenBrightness(1.0);
    }
  }
}
```

### Web Configuration

### Web Dev Server Proxy

```yaml
server:
  proxy:
    - target: "http://localhost:5000/"
      prefix: "/api/"
    - target: "http://localhost:3000/"
      regex: "^/api/(v\\d+)/(.*)"
      replace: "/$2?apiVersion=$1"
```

### Custom Headers

```yaml
server:
  headers:
    - name: "Cache-Control"
      value: "no-cache, no-store, must-revalidate"
    - name: "X-Custom-Header"
      value: "MyValue"
```

## Build & Deployment

### Assets Configuration

```yaml
flutter:
  assets:
    - assets/images/
    - assets/data/
  fonts:
    - family: Roboto
      fonts:
        - asset: fonts/Roboto-Regular.ttf
        - asset: fonts/Roboto-Bold.ttf
          weight: 700
```

### Deferred Components

```yaml
deferred-components:
  - loading-unit: 2
    components:
      - gallery_screen
      - card_editor
```

## Error Handling

### Result Type for Error Handling

```dart
sealed class Result<T> {
  const Result();
  
  factory Result.ok(T value) = Ok<T>(value);
  factory Result.error(Exception error) = Error<T>(error);
}

class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);
}

class Error<T> extends Result<T> {
  final Exception error;
  const Error(this.error);
}
```

### Exception Handling in UI

```dart
ListenableBuilder(
  listenable: viewModel,
  builder: (context, _) {
    if (viewModel.error != null) {
      return ErrorWidget(error: viewModel.error);
    }
    return NormalContent();
  },
)
```

## Debugging Tools

### Visual Layout Guidelines

```dart
import 'package:flutter/rendering.dart';

void showLayoutGuidelines() {
  debugPaintSizeEnabled = true;
}
```

### Performance Overlay

```dart
MaterialApp(
  debugShowCheckedModeBanner: false,
  checkerboardRasterCacheImages: true,
  showPerformanceOverlay: kDebugMode,
)
```

## Integration Testing

### Integration Test Setup

```yaml
dev_dependencies:
  integration_test:
    sdk: flutter
```

```dart
testWidgets('App flow integration test', (tester) async {
  app.main();
  await tester.pumpAndSettle();
  
  // Test complete user flow
  await tester.tap(find.byKey(Key('add-card-button')));
  await tester.pumpAndSettle();
  
  expect(find.byType(GalleryScreen), findsOneWidget);
});
```

This documentation provides comprehensive Flutter development patterns, templates, and best practices for building scalable, maintainable applications.