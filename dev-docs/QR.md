**QR Integration Plan for Cardy App**

**Goal**  
Add multiple scannable QR codes to the full-screen business card display:  
- Deep link to personal/website  
- mailto: (email)  
- tel: (phone call)  
- vCard (full contact download)  

Secondary goal: Allow recipient to scan any QR and auto-import contact or trigger action without typing.

**Chosen Packages** (pub.dev latest as of Nov 2025)  
- Generation: `pretty_qr_code: ^3.5.0` (superior customization, embedded logo support, smooth edges)  
- Fallback low-level: `qr: ^3.0.2` (if needed for raw data)  
- Scanning (future v2): `mobile_scanner: ^7.1.3`  

**Data Model Extensions** (lib/models/card.dart or new qr_data.dart)  
```dart
class CardData {
  // existing fields...
  
  // New QR-specific
  String? websiteUrl;      // https://example.com or custom deep link
  String? email;           // for mailto
  String? phone;           // for tel
  bool enableVcardQr;      // toggle
  bool enableLinkQr;
  bool enableEmailQr;
  bool enablePhoneQr;
}
```

**QR Payload Specifications**  
1. **Link QR**  
   Payload: `websiteUrl` (ensure https:// prefix)  
   Fallback: if empty, hide QR  

2. **Email QR**  
   Payload: `mailto:${email}?subject=Meeting%20from%20Cardy`  
   Optional params: cc, bcc, body (add toggleable fields later)  

3. **Phone QR**  
   Payload: `tel:${phone.replaceAll(RegExp(r'[^\d+]'), '')}`  
   Strip formatting for international compatibility  

4. **vCard QR** (vCard 4.0 spec – max compatibility)  
```vcard
BEGIN:VCARD
VERSION:4.0
N:${lastName};${firstName};;;
FN:${firstName} ${lastName}
ORG:${company}
TITLE:${title}
TEL;TYPE=CELL:${phone}
EMAIL:${email}
URL:${websiteUrl}
ADR;TYPE=WORK:;;${street};${city};${state};${zip};${country}
END:VCARD
```
Encode as UTF-8 string, max 2.9KB for QR version ~25 with ECC H  

**UI/UX Layout Plan** (full-screen display page)  
- Background: solid or subtle gradient (match card theme)  
- Main card area (70% height): existing text/layout  
- QR ribbon at bottom (30% height, scrollable if needed):  
  ```
  Row(
    mainAxisAlignment: SpaceEvenly,
    children: [
      if(enableLinkQr) QrButton(icon: Icons.link, label: "Website"),
      if(enableEmailQr) QrButton(icon: Icons.email, label: "Email"),
      if(enablePhoneQr) QrButton(icon: Icons.phone, label: "Call"),
      if(enableVcardQr) QrButton(icon: Icons.contact_page, label: "Save Contact"),
    ]
  )
  ```
- Each QrButton:  
  - Tap → full-screen modal with PrettyQrCode (size 80% screen)  
  - Embedded logo: company logo or avatar (center, 15% occlusion max)  
  - Auto-regenerate on data change  
  - Long-press → share PNG (use screenshot or repaint to image bytes)  

**PrettyQrCode Settings (per QR)**  
```dart
PrettyQrView.data(
  data: payload,
  errorCorrectionLevel: QrErrorCorrectLevel.H, // 30% damage tolerance
  decoration: PrettyQrDecoration(
    shape: PrettyQrSmoothSymbol(
      roundFactor: 0.15,
      dotSizeFactor: 0.9,
    ),
    image: PrettyQrDecorationImage(
      image: NetworkImage(avatarUrl),
      position: PrettyQrDecorationImagePosition.embedded,
    ),
  ),
)
```

**Storage & Persistence**  
- Use existing shared_preferences or hive box  
- Add QR toggle booleans + payload fields to save/load  
- Version migration: on app update, auto-generate vCard payload from existing fields if enableVcardQr true  

**Future Scanning Feature (v2 roadmap)**  
- Add "Scan Received Card" FAB on home  
- Use mobile_scanner → onDetect:  
  - If vCard → parse + save to contacts (contacts_service package)  
  - If mailto/tel → launch url_launcher  
  - If http → open in-app browser  

**Performance Notes**  
- Cache QR images (MemoryImage from toImageSync())  
- Generate only on display or data change (use ValueNotifier)  
- Max QR size: 512x512 pixels (plenty for mobile scan distance 15-30cm)  

**Testing Checklist**  
- Scan with iOS Camera, Google Lens, Android QR apps  
- Test on low-light, angled, damaged prints  
- Verify vCard imports correctly on iOS Contacts & Android People  
- Ensure mailto/tel launch native apps  

**Next Steps for Coding Agents**  
1. Update CardData model + persistence  
2. Create QrPayloadService (static methods for each payload type)  
3. Build QrDisplayModal widget (reusable)  
4. Add QR ribbon to DisplayScreen  
5. Implement tap → modal with embedded logo  
6. Add share PNG export (repaintBoundary)  

Ready for agent implementation – no code written here, pure architecture.