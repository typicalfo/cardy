**MVP Planning Doc – Flutter iOS + Web (No Android)**

**Project:** `business_card_app`  
**Platforms:** `ios,web`  
**Flutter:** 3.35.5+  
**Goal:** Input → full-screen OCR-friendly card. Show on device for photo capture.

---

**1. CLI Setup (Done)**  
```bash
flutter create . --platforms ios,web
flutter pub add shared_preferences screen_brightness
flutter pub get
flutter doctor  # ✓ iOS toolchain, web enabled
```

---

**2. Project Structure**
```
lib/
├── main.dart          → MaterialApp + routes
├── screens/
│   ├── edit_screen.dart
│   └── card_screen.dart
└── utils/
    └── brightness.dart  → platform-specific max brightness
```

---

**3. EditScreen (Input)**
- `StatefulWidget`  
- `TextEditingController` ×6: name, title, company, phone, email, website  
- Save to `SharedPreferences` on button  
- Navigate → `/card`

---

**4. CardScreen (Display)**
- `StatelessWidget` + `FutureBuilder<SharedPreferences>`  
- Full-screen white, black text, centered  
- Font sizes: name 32sp bold, others 24–28sp  
- 16dp spacing, 32dp padding  
- Force portrait: `SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])`  
- Max brightness:  
  ```dart
  // utils/brightness.dart
  if (kIsWeb) {
    // wakelock_web or JS interop (optional)
  } else if (Platform.isIOS) {
    ScreenBrightness().setScreenBrightness(1.0);
  }
  ```
- Hide system UI: `SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive)`

---

**5. pubspec.yaml**
```yaml
dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.3.0
  screen_brightness: ^0.2.2

flutter:
  uses-material-design: true
```

---

**6. Web Optimizations**
- `web/index.html`: `<meta name="mobile-web-app-capable" content="yes">`  
- Force high DPI: `canvasKitRenderer` or `html` fallback  
- Test in Safari/Chrome mobile → screenshot → Lens OCR

---

**7. Tasks for Dev Agent**
1. Create `EditScreen`: form + save + navigate  
2. Create `CardScreen`: load data → layout → brightness + orientation  
3. Add `brightness.dart` with platform checks  
4. Test:  
   - iOS simulator → enter → show → screenshot → Live Text  
   - Web (Chrome iOS) → same flow  
5. Commit: `git add . && git commit -m "MVP: input + display"`

---

**Success Criteria**  
- All fields persist  
- Card legible in photo (1–2 ft)  
- Brightness max on iOS, wake lock on web  
- No crashes on iOS device or mobile web

Build → `flutter run -d ios` / `flutter run -d chrome --web-port=8080`