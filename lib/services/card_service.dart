import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/business_card.dart';

class CardService {
  static const String _cardsKey = 'business_cards';
  static const String _defaultCardKey = 'default_card_id';
  
  static List<BusinessCard>? _cachedCards;
  static String? _cachedDefaultCardId;

  static Future<List<BusinessCard>> getCards() async {
    // Return cached cards if available
    if (_cachedCards != null) {
      return _cachedCards!;
    }
    
    final prefs = await SharedPreferences.getInstance();
    final cardsJson = prefs.getString(_cardsKey) ?? '[]';
    
    try {
      final List<dynamic> cardsList = jsonDecode(cardsJson);
      _cachedCards = cardsList
          .map((card) => BusinessCard.fromJson(card as Map<String, dynamic>))
          .toList();
      return _cachedCards!;
    } catch (e) {
      _cachedCards = [];
      return [];
    }
  }

  static Future<void> saveCards(List<BusinessCard> cards) async {
    final prefs = await SharedPreferences.getInstance();
    final cardsJson = jsonEncode(cards.map((card) => card.toJson()).toList());
    await prefs.setString(_cardsKey, cardsJson);
  }

  static Future<BusinessCard?> getCard(String id) async {
    final cards = await getCards();
    try {
      return cards.firstWhere((card) => card.id == id);
    } catch (e) {
      return null;
    }
  }

  static Future<BusinessCard?> getCardById(String id) async {
    return await getCard(id);
  }

  static Future<void> saveCard(BusinessCard card) async {
    final cards = await getCards();
    final existingIndex = cards.indexWhere((c) => c.id == card.id);
    
    if (existingIndex != -1) {
      cards[existingIndex] = card;
    } else {
      cards.add(card);
    }
    
    await saveCards(cards);
    // Update cache
    _cachedCards = cards;
  }

  static Future<void> deleteCard(String id) async {
    final cards = await getCards();
    cards.removeWhere((card) => card.id == id);
    await saveCards(cards);
    // Update cache
    _cachedCards = cards;
  }

  static Future<String?> getDefaultCardId() async {
    // Return cached default card ID if available
    if (_cachedDefaultCardId != null) {
      return _cachedDefaultCardId;
    }
    
    final prefs = await SharedPreferences.getInstance();
    _cachedDefaultCardId = prefs.getString(_defaultCardKey);
    return _cachedDefaultCardId;
  }

  static Future<void> setDefaultCardId(String? id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id == null) {
      await prefs.remove(_defaultCardKey);
    } else {
      await prefs.setString(_defaultCardKey, id);
    }
    // Update cache
    _cachedDefaultCardId = id;
  }

  static Future<BusinessCard?> getDefaultCard() async {
    final defaultCardId = await getDefaultCardId();
    if (defaultCardId == null) return null;
    return getCard(defaultCardId!);
  }

  static Future<bool> hasCards() async {
    final cards = await getCards();
    return cards.isNotEmpty;
  }

  static Future<void> clearAllCards() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cardsKey);
    await prefs.remove(_defaultCardKey);
    // Clear cache
    _cachedCards = null;
    _cachedDefaultCardId = null;
  }
}