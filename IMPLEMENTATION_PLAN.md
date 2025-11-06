# QR Code Implementation Plan for Cardy App

## Overview
Add multiple scannable QR codes to the full-screen business card display with individual modal popups for each QR type. Each QR code can be tapped to display a full-screen modal optimized for scanning.

## Dependencies
Add to `pubspec.yaml`:
```yaml
dependencies:
  pretty_qr_code: ^3.5.0
  url_launcher: ^6.3.0  # for testing QR functionality
  share_plus: ^10.0.0   # for PNG export
  path_provider: ^2.1.0  # for temporary file storage
```

## 1. Data Model Extensions

### Update BusinessCard Model (`lib/models/business_card.dart`)
Add QR-specific fields to existing model:

```dart
class BusinessCard {
  const BusinessCard({
    required this.id,
    required this.name,
    this.title = '',
    this.company = '',
    this.phone = '',
    this.email = '',
    this.website = '',
    // New QR fields
    this.websiteUrl = '',           // Dedicated QR website URL
    this.enableVcardQr = true,      // Toggle for vCard QR
    this.enableLinkQr = true,       // Toggle for website QR
    this.enableEmailQr = true,      // Toggle for email QR
    this.enablePhoneQr = true,      // Toggle for phone QR
    this.createdAt,
    this.isDefault = false,
  });

  final String websiteUrl;
  final bool enableVcardQr;
  final bool enableLinkQr;
  final bool enableEmailQr;
  final bool enablePhoneQr;

  // Update copyWith, toJson, fromJson accordingly
}
```

## 2. QR Payload Service

### Create QrPayloadService (`lib/services/qr_payload_service.dart`)
```dart
import '../models/business_card.dart';

class QrPayloadService {
  static String generateWebsitePayload(BusinessCard card) {
    String url = card.websiteUrl.isNotEmpty ? card.websiteUrl : card.website;
    if (!url.startsWith('http')) {
      url = 'https://$url';
    }
    return url;
  }

  static String generateEmailPayload(BusinessCard card) {
    if (card.email.isEmpty) return '';
    return 'mailto:${card.email}?subject=Meeting%20from%20Cardy';
  }

  static String generatePhonePayload(BusinessCard card) {
    if (card.phone.isEmpty) return '';
    // Remove formatting for international compatibility
    final cleanPhone = card.phone.replaceAll(RegExp(r'[^\d+]'), '');
    return 'tel:$cleanPhone';
  }

  static String generateVcardPayload(BusinessCard card) {
    // Split name into first/last (basic implementation)
    final nameParts = card.name.split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    return '''BEGIN:VCARD
VERSION:4.0
N:$lastName;$firstName;;;
FN:${card.name}
ORG:${card.company}
TITLE:${card.title}
TEL;TYPE=CELL:${card.phone}
EMAIL:${card.email}
URL:${card.websiteUrl.isNotEmpty ? card.websiteUrl : card.website}
END:VCARD''';
  }
}
```

## 3. QR Display Modal Widget

### Create QrDisplayModal (`lib/widgets/qr_display_modal.dart`)
```dart
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

enum QrType { website, email, phone, vcard }

class QrDisplayModal extends StatefulWidget {
  const QrDisplayModal({
    super.key,
    required this.payload,
    required this.title,
    required this.type,
    this.logoUrl,
  });

  final String payload;
  final String title;
  final QrType type;
  final String? logoUrl;

  @override
  State<QrDisplayModal> createState() => _QrDisplayModalState();
}

class _QrDisplayModalState extends State<QrDisplayModal> {
  final GlobalKey _qrKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _shareQrCode,
                        icon: const Icon(Icons.share, color: Colors.white),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // QR Code Display
            Expanded(
              child: Center(
                child: RepaintBoundary(
                  key: _qrKey,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: PrettyQrView.data(
                      data: widget.payload,
                      errorCorrectionLevel: QrErrorCorrectLevel.H,
                      decoration: PrettyQrDecoration(
                        shape: PrettyQrSmoothSymbol(
                          roundFactor: 0.15,
                          dotSizeFactor: 0.9,
                        ),
                        image: widget.logoUrl != null
                            ? PrettyQrDecorationImage(
                                image: NetworkImage(widget.logoUrl!),
                                position: PrettyQrDecorationImagePosition.embedded,
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Footer with instructions
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Scan this QR code to ${_getActionText()}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Point your camera at the code',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getActionText() {
    switch (widget.type) {
      case QrType.website:
        return 'visit the website';
      case QrType.email:
        return 'send an email';
      case QrType.phone:
        return 'make a phone call';
      case QrType.vcard:
        return 'save the contact';
    }
  }

  Future<void> _shareQrCode() async {
    try {
      final RenderRepaintBoundary boundary = _qrKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        final Uint8List pngBytes = byteData.buffer.asUint8List();
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/qr_code_${widget.type.name}.png');
        await file.writeAsBytes(pngBytes);
        
        await Share.shareXFiles([XFile(file.path)], text: 'QR Code for ${widget.title}');
      }
    } catch (e) {
      // Handle error silently or show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to share QR code')),
      );
    }
  }
}
```

## 4. QR Button Widget

### Create QrButton (`lib/widgets/qr_button.dart`)
```dart
import 'package:flutter/material.dart';

class QrButton extends StatelessWidget {
  const QrButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isEnabled = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isEnabled ? Colors.black : Colors.grey[300],
          borderRadius: BorderRadius.circular(25),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isEnabled ? Colors.white : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isEnabled ? Colors.white : Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 5. Update Card Screen

### Modify CardScreen (`lib/screens/card_screen.dart`)
Add QR ribbon and modal functionality:

```dart
// Add these imports
import '../widgets/qr_button.dart';
import '../widgets/qr_display_modal.dart';
import '../services/qr_payload_service.dart';

// Add this method to _CardScreenState class
void _showQrModal(BuildContext context, QrType type, BusinessCard card) {
  String payload = '';
  String title = '';
  
  switch (type) {
    case QrType.website:
      payload = QrPayloadService.generateWebsitePayload(card);
      title = 'Website';
      break;
    case QrType.email:
      payload = QrPayloadService.generateEmailPayload(card);
      title = 'Email';
      break;
    case QrType.phone:
      payload = QrPayloadService.generatePhonePayload(card);
      title = 'Phone';
      break;
    case QrType.vcard:
      payload = QrPayloadService.generateVcardPayload(card);
      title = 'Save Contact';
      break;
  }
  
  if (payload.isNotEmpty) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => QrDisplayModal(
        payload: payload,
        title: title,
        type: type,
        // logoUrl: card.avatarUrl, // Add if you have avatar functionality
      ),
    );
  }
}

// Update the build method's body section to include QR ribbon
body: _isLoading
    ? const Center(child: CircularProgressIndicator())
    : _card == null
        ? const Center(child: Text('Card not found'))
        : Column(
            children: [
              // Existing card content (70% height)
              Expanded(
                flex: 7,
                child: Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Existing text fields (name, title, company, phone, email, website)
                      // ... keep existing code ...
                    ],
                  ),
                ),
              ),
              
              // QR Ribbon (30% height)
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border(top: BorderSide(color: Colors.grey[200]!)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Tap to scan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (_card!.enableLinkQr && 
                                (_card!.websiteUrl.isNotEmpty || _card!.website.isNotEmpty))
                              QrButton(
                                icon: Icons.link,
                                label: "Website",
                                onTap: () => _showQrModal(context, QrType.website, _card!),
                              ),
                            const SizedBox(width: 12),
                            if (_card!.enableEmailQr && _card!.email.isNotEmpty)
                              QrButton(
                                icon: Icons.email,
                                label: "Email",
                                onTap: () => _showQrModal(context, QrType.email, _card!),
                              ),
                            const SizedBox(width: 12),
                            if (_card!.enablePhoneQr && _card!.phone.isNotEmpty)
                              QrButton(
                                icon: Icons.phone,
                                label: "Call",
                                onTap: () => _showQrModal(context, QrType.phone, _card!),
                              ),
                            const SizedBox(width: 12),
                            if (_card!.enableVcardQr)
                              QrButton(
                                icon: Icons.contact_page,
                                label: "Save Contact",
                                onTap: () => _showQrModal(context, QrType.vcard, _card!),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
```

## 6. Update Card Service

### Modify CardService (`lib/services/card_service.dart`)
Update to handle new QR fields in persistence:

```dart
// Update the toJson and fromJson methods in BusinessCard class
// These are already in the model file, but ensure they include new fields:

@override
Map<String, dynamic> toJson() {
  return {
    'id': id,
    'name': name,
    'title': title,
    'company': company,
    'phone': phone,
    'email': email,
    'website': website,
    'websiteUrl': websiteUrl,
    'enableVcardQr': enableVcardQr,
    'enableLinkQr': enableLinkQr,
    'enableEmailQr': enableEmailQr,
    'enablePhoneQr': enablePhoneQr,
    'createdAt': createdAt?.toIso8601String(),
    'isDefault': isDefault,
  };
}

factory BusinessCard.fromJson(Map<String, dynamic> json) {
  return BusinessCard(
    id: json['id'] as String,
    name: json['name'] as String,
    title: json['title'] as String? ?? '',
    company: json['company'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    email: json['email'] as String? ?? '',
    website: json['website'] as String? ?? '',
    websiteUrl: json['websiteUrl'] as String? ?? '',
    enableVcardQr: json['enableVcardQr'] as bool? ?? true,
    enableLinkQr: json['enableLinkQr'] as bool? ?? true,
    enableEmailQr: json['enableEmailQr'] as bool? ?? true,
    enablePhoneQr: json['enablePhoneQr'] as bool? ?? true,
    createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt'] as String)
        : null,
    isDefault: json['isDefault'] as bool? ?? false,
  );
}
```

## 7. Testing Checklist

### Manual Testing Steps
1. **QR Generation**:
   - Test each QR type with valid data
   - Test with empty fields (should not show QR button)
   - Verify vCard format compliance

2. **Modal Display**:
   - Tap each QR button → modal opens
   - Verify QR code is large and scannable
   - Test close button and tap-outside-to-close
   - Test share functionality

3. **Scanning**:
   - Test with iOS Camera app
   - Test with Google Lens
   - Test with Android QR scanner
   - Verify vCard imports to Contacts app
   - Verify mailto opens email app
   - Verify tel opens phone app
   - Verify URL opens browser

4. **Edge Cases**:
   - Very long URLs
   - Special characters in email/phone
   - International phone numbers
   - Empty/null fields

### Automated Tests
Update existing test files to cover new QR functionality:
- Test QrPayloadService methods
- Test BusinessCard serialization with new fields
- Test modal widget rendering

## 8. Future Enhancements (v2)

1. **QR Scanning Feature**:
   - Add "Scan Received Card" functionality
   - Use `mobile_scanner` package
   - Parse vCard and auto-import contacts

2. **Advanced Customization**:
   - Custom QR colors and themes
   - Multiple logo options
   - QR code analytics

3. **Additional QR Types**:
   - WiFi credentials
   - Location maps
   - Social media profiles

## Implementation Order

1. Add dependencies to pubspec.yaml
2. Extend BusinessCard model with QR fields
3. Create QrPayloadService
4. Build QrDisplayModal widget
5. Create QrButton widget
6. Update CardScreen with QR ribbon
7. Update CardService persistence
8. Test thoroughly
9. Deploy and gather feedback

This plan provides a complete, user-friendly QR code implementation where each QR type can be individually displayed in a full-screen modal for optimal scanning experience.