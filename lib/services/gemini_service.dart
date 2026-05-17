import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../models/weather_model.dart';

class GeminiService {
  // We define how long the cache is valid (e.g., 2 hours)
  static const int cacheValidDurationHours = 2;

  Future<String> generateWeatherInsight(WeatherModel weather, String persona) async {
    // 1. Create unique storage keys based on the city AND the specific tab (persona)
    final String cacheKey = 'insight_${persona}_${weather.cityName}';
    final String timeKey = 'time_${persona}_${weather.cityName}';

    // 2. Open the phone's physical hard drive
    final prefs = await SharedPreferences.getInstance();
    
    // 3. Check if we already have saved data
    final savedInsight = prefs.getString(cacheKey);
    final savedTimeStr = prefs.getString(timeKey);

    if (savedInsight != null && savedTimeStr != null) {
      final savedTime = DateTime.parse(savedTimeStr);
      final hoursDifference = DateTime.now().difference(savedTime).inHours;

      // 4. If the data is less than 2 hours old, RETURN IT IMMEDIATELY. NO API CALL.
      if (hoursDifference < cacheValidDurationHours) {
        print('CACHE HIT: Loaded $persona insight for ${weather.cityName} from hard drive.');
        return savedInsight;
      }
    }

    // 5. If we reach here, the cache is missing or expired. We MUST call the API.
    print('CACHE MISS: Fetching fresh $persona insight for ${weather.cityName} from Google...');
    
    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash', 
        apiKey: AppConstants.geminiApiKey,
      );

      String focus = '';
      if (persona == 'lifestyle') {
        focus = 'Give a friendly, helpful tip for daily life. Mention if it is a good day for outdoor activities, line-drying clothes, or if they should stay inside and relax.';
      } else if (persona == 'agri') {
        focus = 'Give an encouraging, supportive tip for farmers. Mention if the current wind (${weather.windKph}km/h) is safe for spraying, and if they should expect rain for their crops.';
      } else {
        focus = 'Give a warm, welcoming general weather summary. Be positive and helpful.'; 
      }

      final prompt = '''
      You are a warm, friendly, and highly professional weather assistant for an Indian audience.
      Current conditions: ${weather.temperatureC}°C, ${weather.condition}, Wind: ${weather.windKph}km/h, Humidity: ${weather.humidity}%, PM2.5 Pollution: ${weather.pm25}, Rain Chance: ${weather.forecastDays[0].dailyChanceOfRain}%.
      $focus
      Provide exactly 2 sentences of helpful, easy-to-understand advice. Use a supportive tone. You may use exactly one relevant emoji.
      ''';

      final response = await model.generateContent([Content.text(prompt)]);
      final newInsight = response.text?.trim() ?? 'AI failed to generate an insight.';

      // 6. SAVE THE NEW DATA TO THE HARD DRIVE
      await prefs.setString(cacheKey, newInsight);
      await prefs.setString(timeKey, DateTime.now().toIso8601String());

      return newInsight;

    } catch (e) {
      print('GEMINI ERROR: $e'); 
      return 'SYSTEM FAILURE: AI connection interrupted. Please wait a moment and try again.';
    }
  }
}