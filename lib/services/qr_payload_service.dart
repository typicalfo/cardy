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