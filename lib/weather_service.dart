import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = "b1cedb626d1bcd73378e43238f3bd007";

  Future<Map<String, dynamic>> fetchWeather(String city) async {
    final url = Uri.parse(
      "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return {
        "name": data['name'],
        "temp": data['main']['temp'],
        "condition": data['weather'][0]['main'],
        "icon": data['weather'][0]['icon'],
        "humidity": data['main']['humidity'],
        "wind": data['wind']['speed'],
        "feelsLike": data['main']['feels_like'],
        "clouds": data['clouds']['all'],
        "visibility": (data['visibility'] ?? 0) / 1000,
      };
    } else {
      throw Exception("City not found");
    }
  }
}
