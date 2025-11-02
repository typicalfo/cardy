# Flutter Design Patterns & Best Practices

## SOLID Principles

### Single Responsibility Principle

Each class should have one reason to change:

```dart
// Good: Single responsibility
class UserRepository {
  Future<User> getUser(String id) async {
    // Only handles user data retrieval
  }
}

class EmailValidator {
  static bool isValid(String email) {
    // Only handles email validation
  }
}

// Bad: Multiple responsibilities
class UserHelper {
  Future<User> getUser(String id) async { /* ... */ }
  static bool isValidEmail(String email) { /* ... */ }
  void sendEmail(User user, String message) { /* ... */ }
}
```

### Open/Closed Principle

Classes should be open for extension, closed for modification:

```dart
// Abstract base class
abstract class StorageService {
  Future<void> save(String key, String value);
  Future<String?> get(String key);
  Future<void> remove(String key);
}

// Concrete implementations
class SharedPreferencesStorage implements StorageService {
  @override
  Future<void> save(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }
}

class SecureStorage implements StorageService {
  @override
  Future<void> save(String key, String value) async {
    // Secure storage implementation
  }
}
```

### Liskov Substitution Principle

Derived classes must be substitutable for base classes:

```dart
abstract class Shape {
  double getArea();
}

class Rectangle implements Shape {
  final double width, height;
  
  Rectangle(this.width, this.height);
  
  @override
  double getArea() => width * height;
}

class Circle implements Shape {
  final double radius;
  
  Circle(this.radius);
  
  @override
  double getArea() => 3.14159 * radius * radius;
}
```

### Interface Segregation Principle

Clients shouldn't depend on interfaces they don't use:

```dart
// Bad: Large interface
interface UserOperations {
  Future<User> getUser(String id);
  Future<void> saveUser(User user);
  Future<void> deleteUser(String id);
  Future<void> sendEmail(User user, String message);
  Future<void> backupUserData(User user);
}

// Good: Segregated interfaces
interface UserReader {
  Future<User> getUser(String id);
}

interface UserWriter {
  Future<void> saveUser(User user);
  Future<void> deleteUser(String id);
}

interface EmailService {
  Future<void> sendEmail(User user, String message);
}
```

### Dependency Inversion Principle

Depend on abstractions, not concretions:

```dart
// Bad: Direct dependency
class UserService {
  final HttpClient httpClient = HttpClient(); // Concrete dependency
  
  Future<User> getUser(String id) async {
    final response = await httpClient.get('...');
    return User.fromJson(response.body);
  }
}

// Good: Abstract dependency
class UserService {
  final HttpService httpService; // Abstract dependency
  
  UserService(this.httpService);
  
  Future<User> getUser(String id) async {
    final response = await httpService.get('...');
    return User.fromJson(response.body);
  }
}
```

## Design Patterns

### Factory Pattern

Create objects without specifying exact classes:

```dart
abstract class ThemeFactory {
  ThemeData createLightTheme();
  ThemeData createDarkTheme();
}

class DefaultThemeFactory implements ThemeFactory {
  @override
  ThemeData createLightTheme() {
    return ThemeData.light().copyWith(
      primaryColor: Colors.blue,
    );
  }
  
  @override
  ThemeData createDarkTheme() {
    return ThemeData.dark().copyWith(
      primaryColor: Colors.indigo,
    );
  }
}
```

### Builder Pattern

Construct complex objects step by step:

```dart
class PizzaBuilder {
  String _size = 'medium';
  String _crust = 'thin';
  List<String> _toppings = [];

  PizzaBuilder size(String size) {
    _size = size;
    return this;
  }

  PizzaBuilder crust(String crust) {
    _crust = crust;
    return this;
  }

  PizzaBuilder addTopping(String topping) {
    _toppings.add(topping);
    return this;
  }

  Pizza build() {
    return Pizza(
      size: _size,
      crust: _crust,
      toppings: _toppings,
    );
  }
}

// Usage
final pizza = PizzaBuilder()
    .size('large')
    .crust('thick')
    .addTopping('cheese')
    .addTopping('pepperoni')
    .build();
```

### Observer Pattern

Define one-to-many dependency between objects:

```dart
class WeatherStation extends ChangeNotifier {
  double _temperature = 0.0;
  
  double get temperature => _temperature;
  
  void setTemperature(double newTemp) {
    _temperature = newTemp;
    notifyListeners();
  }
}

class TemperatureDisplay extends StatelessWidget {
  const TemperatureDisplay({super.key, required this.weatherStation});

  final WeatherStation weatherStation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: weatherStation,
      builder: (context, child) {
        return Text(
          '${weatherStation.temperature.toStringAsFixed(1)}°C',
          style: Theme.of(context).textTheme.headlineMedium,
        );
      },
    );
  }
}
```

### Strategy Pattern

Encapsulate algorithms and make them interchangeable:

```dart
abstract class SortingStrategy {
  List<int> sort(List<int> numbers);
}

class BubbleSort implements SortingStrategy {
  @override
  List<int> sort(List<int> numbers) {
    // Bubble sort implementation
    final sorted = List<int>.from(numbers);
    for (int i = 0; i < sorted.length - 1; i++) {
      for (int j = 0; j < sorted.length - i - 1; j++) {
        if (sorted[j] > sorted[j + 1]) {
          final temp = sorted[j];
          sorted[j] = sorted[j + 1];
          sorted[j + 1] = temp;
        }
      }
    }
    return sorted;
  }
}

class QuickSort implements SortingStrategy {
  @override
  List<int> sort(List<int> numbers) {
    // Quick sort implementation
    if (numbers.length <= 1) return numbers;
    
    final pivot = numbers[0];
    final less = numbers.where((n) => n < pivot).toList();
    final greater = numbers.where((n) => n > pivot).toList();
    
    return [...sort(less), pivot, ...sort(greater)];
  }
}

class Sorter {
  final SortingStrategy strategy;
  
  Sorter(this.strategy);
  
  List<int> sort(List<int> numbers) {
    return strategy.sort(numbers);
  }
}
```

### Command Pattern

Encapsulate requests as objects:

```dart
abstract class Command {
  Future<void> execute();
}

class AddUserCommand implements Command {
  final User user;
  final UserRepository repository;
  
  AddUserCommand(this.user, this.repository);
  
  @override
  Future<void> execute() async {
    await repository.saveUser(user);
  }
}

class DeleteUserCommand implements Command {
  final String userId;
  final UserRepository repository;
  
  DeleteUserCommand(this.userId, this.repository);
  
  @override
  Future<void> execute() async {
    await repository.deleteUser(userId);
  }
}

class CommandInvoker {
  final List<Command> _history = [];
  
  void executeCommand(Command command) async {
    await command.execute();
    _history.add(command);
  }
  
  void undo() {
    if (_history.isNotEmpty) {
      _history.removeLast();
    }
  }
}
```

### Repository Pattern

Mediate between domain and data mapping layers:

```dart
// Domain entity
class User {
  final String id;
  final String name;
  final String email;
  
  User({required this.id, required this.name, required this.email});
}

// Repository interface
abstract class UserRepository {
  Future<User?> findById(String id);
  Future<List<User>> findAll();
  Future<void> save(User user);
  Future<void> delete(String id);
}

// Concrete implementation
class SqliteUserRepository implements UserRepository {
  final Database _database;
  
  SqliteUserRepository(this._database);
  
  @override
  Future<User?> findById(String id) async {
    final maps = await _database.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }
  
  @override
  Future<List<User>> findAll() async {
    final maps = await _database.query('users');
    return maps.map((map) => User.fromMap(map)).toList();
  }
}
```

## Architectural Patterns

### Clean Architecture

Separation of concerns with clear layers:

```dart
// Domain Layer
abstract class UserRepository {
  Future<User> getUser(String id);
  Future<List<User>> getAllUsers();
}

// Data Layer
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;
  
  UserRepositoryImpl(this.remoteDataSource, this.localDataSource);
  
  @override
  Future<User> getUser(String id) async {
    try {
      return await remoteDataSource.getUser(id);
    } catch (e) {
      return await localDataSource.getUser(id);
    }
  }
}

// Presentation Layer
class UserViewModel extends ChangeNotifier {
  final UserRepository _repository;
  
  UserViewModel(this._repository);
  
  User? _user;
  User? get user => _user;
  
  Future<void> loadUser(String id) async {
    _user = await _repository.getUser(id);
    notifyListeners();
  }
}
```

### MVVM (Model-View-ViewModel)

```dart
// Model
class Counter {
  int value;
  
  Counter(this.value);
  
  Counter copyWith({int? value}) {
    return Counter(value: value ?? this.value);
  }
}

// ViewModel
class CounterViewModel extends ChangeNotifier {
  Counter _counter = Counter(value: 0);
  
  Counter get counter => _counter;
  
  void increment() {
    _counter = _counter.copyWith(value: _counter.value + 1);
    notifyListeners();
  }
  
  void decrement() {
    _counter = _counter.copyWith(value: _counter.value - 1);
    notifyListeners();
  }
}

// View
class CounterView extends StatelessWidget {
  const CounterView({super.key, required this.viewModel});

  final CounterViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Count: ${viewModel.counter.value}'),
        Row(
          children: [
            ElevatedButton(
              onPressed: viewModel.increment,
              child: const Text('+'),
            ),
            ElevatedButton(
              onPressed: viewModel.decrement,
              child: const Text('-'),
            ),
          ],
        ),
      ],
    );
  }
}
```

### BLoC Pattern

Business Logic Component for state management:

```dart
// Events
abstract class CounterEvent {}

class CounterIncremented extends CounterEvent {}
class CounterDecremented extends CounterEvent {}

// States
abstract class CounterState {}

class CounterInitial extends CounterState {}
class CounterValue extends CounterState {
  final int value;
  CounterValue(this.value);
}

// BLoC
class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(CounterInitial()) {
    on<CounterIncremented>((event, emit) {
      final currentState = state as CounterValue;
      emit(CounterValue(currentState.value + 1));
    });
    
    on<CounterDecremented>((event, emit) {
      final currentState = state as CounterValue;
      emit(CounterValue(currentState.value - 1));
    });
  }
}

// BLoC Provider
class CounterBlocProvider extends BlocProvider<CounterBloc, CounterState> {
  CounterBlocProvider() : super(create: () => CounterBloc());
}

// Widget
class CounterView extends StatelessWidget {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterBloc(),
      child: BlocBuilder<CounterBloc, CounterState>(
        builder: (context, state) {
          if (state is CounterValue) {
            return Column(
              children: [
                Text('Count: ${state.value}'),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        context.read<CounterBloc>().add(CounterIncremented());
                      },
                      child: const Text('+'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.read<CounterBloc>().add(CounterDecremented());
                      },
                      child: const Text('-'),
                    ),
                  ],
                ),
              ],
            );
          }
          return const CircularProgressIndicator();
        },
      ),
    );
  }
}
```

## UI Design Patterns

### Widget Composition

Build complex UIs from simple, reusable widgets:

```dart
class CustomCard extends StatelessWidget {
  const CustomCard({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.elevation = 2.0,
    this.margin = const EdgeInsets.all(8.0),
  });

  final Widget child;
  final Color color;
  final double elevation;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Material(
        elevation: elevation,
        color: color,
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }
}

// Usage
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomCard(
              child: Text('Profile Information'),
            ),
            const SizedBox(height: 16),
            CustomCard(
              color: Colors.grey[100],
              child: Column(
                children: [
                  Text('Name: John Doe'),
                  Text('Email: john@example.com'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Responsive Design

Adapt UI to different screen sizes:

```dart
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
  });

  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          return desktop;
        } else if (constraints.maxWidth >= 800) {
          return tablet;
        } else {
          return mobile;
        }
      },
    );
  }
}

// Usage
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        desktop: _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return const Column(
      children: [
        Text('Mobile Layout'),
        // Mobile-specific widgets
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        Expanded(child: _buildSidebar()),
        Expanded(flex: 2, child: _buildMainContent()),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        SizedBox(width: 300, child: _buildSidebar()),
        Expanded(child: _buildMainContent()),
      ],
    );
  }
}
```

### Theme Management

Consistent theming across the app:

```dart
class AppTheme {
  static const Color primaryColor = Colors.blue;
  static const Color secondaryColor = Colors.orange;
  static const Color backgroundColor = Colors.white;
  static const Color surfaceColor = Color(0xFFF5F5F5);
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: surfaceColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }
}

// Theme provider
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  
  ThemeMode get themeMode => _themeMode;
  
  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}

// Theme app
class ThemedApp extends StatelessWidget {
  const ThemedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            themeMode: themeProvider.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: child!,
          );
        },
      ),
    );
  }
}
```

## Performance Patterns

### Lazy Loading

Load data only when needed:

```dart
class LazyListView extends StatefulWidget {
  const LazyListView({super.key});

  @override
  State<LazyListView> createState() => _LazyListViewState();
}

class _LazyListViewState extends State<LazyListView> {
  final List<Item> _items = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadMoreItems();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreItems();
    }
  }

  Future<void> _loadMoreItems() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    
    try {
      final newItems = await ApiService.getItems(_currentPage);
      setState(() {
        _items.addAll(newItems);
        _currentPage++;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _items.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _items.length) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final item = _items[index];
        return ListTile(
          title: Text(item.title),
          subtitle: Text(item.description),
        );
      },
    );
  }
}
```

### Image Caching

Optimize image loading and display:

```dart
class CachedImage extends StatefulWidget {
  const CachedImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  State<CachedImage> createState() => _CachedImageState();
}

class _CachedImageState extends State<CachedImage> {
  ImageProvider? _imageProvider;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    setState(() => _isLoading = true);
    
    try {
      final imageProvider = NetworkImage(widget.url);
      await precacheImage(imageProvider, context);
      
      setState(() {
        _imageProvider = imageProvider;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey[300],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_imageProvider == null) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey[300],
        child: const Icon(Icons.error),
      );
    }

    return Image(
      image: _imageProvider,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
    );
  }
}
```

## Testing Patterns

### Widget Testing

Comprehensive widget testing approach:

```dart
class WidgetTestCase {
  static Widget createWidget(Widget widget) {
    return MaterialApp(
      home: Scaffold(
        body: widget,
      ),
    );
  }

  static Future<void> pumpWidget(WidgetTester tester, Widget widget) async {
    await tester.pumpWidget(createWidget(widget));
    await tester.pumpAndSettle();
  }

  static Finder findText(String text) {
    return find.text(text);
  }

  static Finder findKey(Key key) {
    return find.byKey(key);
  }

  static Future<void> tapButton(WidgetTester tester, String text) async {
    await tester.tap(findText(text));
    await tester.pumpAndSettle();
  }

  static Future<void> enterText(WidgetTester tester, Key key, String text) async {
    await tester.enterText(findKey(key), text);
    await tester.pumpAndSettle();
  }
}

void main() {
  group('CustomButton Tests', () {
    testWidgets('renders correctly with text', (tester) async {
      await WidgetTestCase.pumpWidget(
        CustomButton(text: 'Test Button', onPressed: () {}),
      );

      expect(WidgetTestCase.findText('Test Button'), findsOneWidget);
    });

    testWidgets('shows loading indicator when loading', (tester) async {
      await WidgetTestCase.pumpWidget(
        CustomButton(text: 'Loading', onPressed: () {}, isLoading: true),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(WidgetTestCase.findText('Loading'), findsNothing);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      bool wasPressed = false;
      
      await WidgetTestCase.pumpWidget(
        CustomButton(
          text: 'Test Button',
          onPressed: () => wasPressed = true,
        ),
      );

      await WidgetTestCase.tapButton(tester, 'Test Button');
      expect(wasPressed, isTrue);
    });
  });
}
```

### Integration Testing

End-to-end testing scenarios:

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('complete user flow', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Test login flow
    await tester.tap(find.byKey(const Key('login-button')));
    await tester.pumpAndSettle();

    await WidgetTestCase.enterText(tester, const Key('email-field'), 'test@example.com');
    await WidgetTestCase.enterText(tester, const Key('password-field'), 'password');
    await tester.tap(find.byKey(const Key('submit-login')));
    await tester.pumpAndSettle();

    // Verify home screen appears
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Welcome, test@example.com'), findsOneWidget);

    // Test navigation to profile
    await tester.tap(find.byIcon(Icons.person));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
```

This comprehensive guide covers Flutter design patterns, architectural principles, and best practices for building maintainable, scalable applications.