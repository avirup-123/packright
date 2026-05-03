import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/index.dart';

class GeminiService {
  static const String _model = 'gemini-1.5-flash';
  late final GenerativeModel _genAI;

  GeminiService({required String apiKey}) {
    _genAI = GenerativeModel(
      model: _model,
      apiKey: apiKey,
    );
  }

  Future<List<PackingItem>> generatePackingList({
    required Trip trip,
  }) async {
    try {
      final prompt = '''
You are a travel packing expert. Based on the following trip description, generate a comprehensive and smart packing list. 

Trip: ${trip.description}

Generate a JSON response ONLY with the following format (no other text):
{
  "items": [
    {
      "name": "item name",
      "category": "clothing|toiletries|electronics|documents|accessories|other",
      "quantity": 1,
      "notes": "optional notes"
    }
  ]
}

Make sure the packing list is:
- Contextually appropriate for the destination and activities
- Organized by category
- Includes items they might forget
- Takes into account weather, culture, and accommodation type
- Practical and not excessive
- Includes quantities where relevant
''';

      final content = [Content.text(prompt)];
      final response = await _genAI.generateContent(content);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Empty response from Gemini');
      }

      // Parse the JSON response
      final jsonString = _extractJson(response.text!);
      final items = _parsePackingItems(jsonString, trip.id);

      return items;
    } catch (e) {
      throw Exception('Failed to generate packing list: $e');
    }
  }

  String _extractJson(String text) {
    final startIndex = text.indexOf('{');
    final endIndex = text.lastIndexOf('}');

    if (startIndex == -1 || endIndex == -1) {
      throw Exception('Could not extract JSON from response');
    }

    return text.substring(startIndex, endIndex + 1);
  }

  List<PackingItem> _parsePackingItems(String jsonString, String tripId) {
    try {
      // This is a simplified parser - in production use proper JSON decoding
      final items = <PackingItem>[];

      // Extract items array manually or use a proper JSON parser
      // For now, this is a placeholder
      return items;
    } catch (e) {
      throw Exception('Failed to parse packing items: $e');
    }
  }
}
