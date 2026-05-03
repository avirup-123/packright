import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/category.dart';
import '../models/packing_item.dart';
import '../providers/theme_provider.dart';

/// AI Service
/// Handles communication with Anthropic Claude API for generating packing lists
class AIService {
  static const String _apiKey = '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';
  static const String _baseUrl = 'http://localhost:3000/v1/messages';
  static const String _model = 'claude-haiku-4-5-20251001';
  static const Duration _timeout = Duration(seconds: 30);

  /// Icon mapping from string identifiers to Flutter IconData
  static const Map<String, IconData> iconMap = {
    'clothing': Icons.checkroom_outlined,
    'toiletries': Icons.soap_outlined,
    'electronics': Icons.power_outlined,
    'documents': Icons.description_outlined,
    'health': Icons.medical_services_outlined,
    'food': Icons.restaurant_outlined,
    'accessories': Icons.watch_outlined,
    'footwear': Icons.ice_skating,
    'bags': Icons.luggage_outlined,
    'miscellaneous': Icons.category_outlined,
  };

  /// Get IconData for an icon name
  static IconData getIconForName(String iconName) {
    return iconMap[iconName.toLowerCase()] ?? Icons.category_outlined;
  }

  /// The system prompt for generating packing lists
  static String _buildSystemPrompt(String? language) {
    String prompt = '''You are PackRight, an expert travel packing assistant. The user will describe their trip in natural language. Your job is to generate a comprehensive, personalized packing checklist.

ANALYZE the trip description to identify:
- Destination(s) and their climate/weather for the travel dates
- Trip duration
- Activities planned (trekking, beach, business, temple visits, etc.)
- Accommodation type (hotel, hostel, camping, Airbnb, etc.)
- Transport mode (flying, driving, train, etc.)
- Travel companions (solo, couple, family with kids, etc.)
- Any special requirements mentioned

GENERATE a packing list that includes:
- Destination-specific items (plug adapters, voltage converters, local currency tips)
- Weather-appropriate clothing with sensible quantities based on trip duration
- Activity-specific gear (hiking boots for treks, swimwear for beaches, formal wear for business/dinners)
- Accommodation-specific items (padlock and towel for hostels, sleep mask for shared dorms)
- Cultural awareness items (modest clothing for temples/religious sites, head coverings where needed)
- Health and safety (medications, sunscreen, insect repellent, first aid basics appropriate to destination)
- Documents and essentials (passport, visa copies, travel insurance, emergency contacts)
- Electronics (chargers, adapters, power bank)
- Toiletries (travel-sized, appropriate to trip length)
- Practical extras the user might forget (reusable water bottle, snacks, plastic bags for dirty laundry)

RULES:
- Never include offensive, stereotypical, or assumptive items
- Assign realistic quantities (e.g., 5 underwear for a 5-day trip, not 1)
- Group items into logical categories
- Keep category names short and clear
- Each category should have an icon identifier from this list: clothing, toiletries, electronics, documents, health, food, accessories, footwear, bags, miscellaneous
- Respond ONLY with valid JSON, no markdown, no explanation, no preamble

RESPOND in this exact JSON format:
{
  "categories": [
    {
      "name": "Category Name",
      "icon": "icon_identifier",
      "items": [
        { "name": "Item name", "quantity": 1 },
        { "name": "Another item", "quantity": 3 }
      ]
    }
  ]
}''';

    if (language != null && language.isNotEmpty) {
      prompt += '\n\nGenerate all item names in $language.';
    }

    return prompt;
  }

  /// Build Anthropic API headers
  static Map<String, String> _buildHeaders() {
    return {
      'Content-Type': 'application/json',
      'x-api-key': _apiKey,
      'anthropic-version': '2023-06-01',
    };
  }

  /// Extract text from Anthropic API response
  static String _extractText(Map<String, dynamic> responseData) {
    final content = responseData['content'] as List?;
    if (content == null || content.isEmpty) {
      throw ApiException('No response generated from API');
    }
    final textBlock = content.firstWhere(
      (block) => block['type'] == 'text',
      orElse: () => null,
    );
    if (textBlock == null) {
      throw ApiException('Invalid response format: no text block');
    }
    final text = textBlock['text'] as String?;
    if (text == null || text.isEmpty) {
      throw ApiException('Empty response from API');
    }
    return text;
  }

  /// Generate a packing list from a trip description
  static Future<List<Category>> generatePackingList(
    String tripDescription, {
    String? language,
  }) async {
    language ??= await ThemeProvider.getCurrentLanguage();
    final systemPrompt = _buildSystemPrompt(language);

    final requestBody = jsonEncode({
      'model': _model,
      'max_tokens': 4096,
      'system': systemPrompt,
      'messages': [
        {
          'role': 'user',
          'content': tripDescription,
        }
      ],
    });

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _buildHeaders(),
        body: requestBody,
      ).timeout(_timeout);

      if (response.statusCode != 200) {
        throw ApiException(
          'API request failed with status ${response.statusCode}: ${response.body}',
          statusCode: response.statusCode,
        );
      }

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      final generatedText = _extractText(responseData);
      return _parseGeneratedCategories(generatedText);
    } on SocketException {
      throw ApiException(
        'No internet connection. Please check your network and try again.',
        isNetworkError: true,
      );
    } on TimeoutException {
      throw ApiException(
        'Request timed out. Please try again.',
        isTimeout: true,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to generate packing list: ${e.toString()}');
    }
  }

  /// Safely parse a quantity value which may be a num, String, or null
  static int _parseQuantity(dynamic value) {
    if (value == null) return 1;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      // Try to extract first number from strings like "as needed", "1-2", "2 pairs"
      final match = RegExp(r'\d+').firstMatch(value);
      if (match != null) return int.parse(match.group(0)!);
    }
    return 1;
  }

  /// Parse the AI-generated JSON string into a list of Category objects
  static List<Category> _parseGeneratedCategories(String jsonString) {
    try {
      String cleanedJson = jsonString.trim();
      if (cleanedJson.startsWith('```json')) {
        cleanedJson = cleanedJson.substring(7);
      }
      if (cleanedJson.startsWith('```')) {
        cleanedJson = cleanedJson.substring(3);
      }
      if (cleanedJson.endsWith('```')) {
        cleanedJson = cleanedJson.substring(0, cleanedJson.length - 3);
      }
      cleanedJson = cleanedJson.trim();

      final data = jsonDecode(cleanedJson) as Map<String, dynamic>;
      final categoriesJson = data['categories'] as List?;

      if (categoriesJson == null) {
        throw FormatException('No categories found in response');
      }

      return categoriesJson.map((catJson) {
        final catMap = catJson as Map<String, dynamic>;
        final itemsJson = catMap['items'] as List? ?? [];

        final items = itemsJson.map((itemJson) {
          final itemMap = itemJson as Map<String, dynamic>;
          return PackingItem(
            name: itemMap['name'] as String? ?? 'Unknown item',
            quantity: _parseQuantity(itemMap['quantity']),
            isPacked: false,
          );
        }).toList();

        return Category(
          name: catMap['name'] as String? ?? 'Miscellaneous',
          iconName: catMap['icon'] as String? ?? 'miscellaneous',
          items: items,
        );
      }).toList();
    } catch (e) {
      throw ApiException('Failed to parse AI response: ${e.toString()}');
    }
  }

  /// Generate additional items based on new context
  static Future<List<Category>> generateAdditionalItems(
    String originalDescription,
    String additionalContext, {
    String? language,
  }) async {
    final systemPrompt = _buildSystemPrompt(language);

    final userMessage = '''Original trip: $originalDescription

The user now wants to add: $additionalContext

Generate ONLY the additional items needed based on the new context. Do not repeat items that would already be in a standard packing list for the original trip. Return the same JSON format.''';

    final requestBody = jsonEncode({
      'model': _model,
      'max_tokens': 4096,
      'system': systemPrompt,
      'messages': [
        {
          'role': 'user',
          'content': userMessage,
        }
      ],
    });

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _buildHeaders(),
        body: requestBody,
      ).timeout(_timeout);

      if (response.statusCode != 200) {
        throw ApiException(
          'API request failed with status ${response.statusCode}: ${response.body}',
          statusCode: response.statusCode,
        );
      }

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      final generatedText = _extractText(responseData);
      return _parseGeneratedCategories(generatedText);
    } on SocketException {
      throw ApiException(
        'No internet connection. Please check your network and try again.',
        isNetworkError: true,
      );
    } on TimeoutException {
      throw ApiException(
        'Request timed out. Please try again.',
        isTimeout: true,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to generate additional items: ${e.toString()}');
    }
  }
}

/// Custom exception for API-related errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final bool isNetworkError;
  final bool isTimeout;

  ApiException(
    this.message, {
    this.statusCode,
    this.isNetworkError = false,
    this.isTimeout = false,
  });

  @override
  String toString() => 'ApiException: $message';
}
