import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  // ================= CONTROLLERS =================
  final TextEditingController _cityController = TextEditingController();

  // ================= WEATHER VARIABLES =================
  String cityName = "";
  String temperature = "";
  String condition = "";
  String humidity = "";
  String windSpeed = "";
  String feelsLike = "";
  String visibility = "";
  String minTemp = "";
  String maxTemp = "";

  bool isLoading = false;
  bool hasError = false; // Used to change border color when city not found

  // ================= API CALL FUNCTION =================
  Future<void> getWeather() async {
    if (_cityController.text.trim().isEmpty) return;

    setState(() {
      isLoading = true;
      hasError = false;
    });

    const apiKey = "b1cedb626d1bcd73378e43238f3bd007";
    final city = _cityController.text.trim();

    final url = Uri.parse(
      "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric",
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          cityName = data['name'];
          temperature = data['main']['temp'].toString();
          condition = data['weather'][0]['main'];
          humidity = data['main']['humidity'].toString();
          windSpeed = data['wind']['speed'].toString();
          feelsLike = data['main']['feels_like'].toString();
          visibility = (data['visibility'] / 1000).toString();
          minTemp = data['main']['temp_min'].toString();
          maxTemp = data['main']['temp_max'].toString();
        });
      } else {
        _showError("City not found");
      }
    } catch (e) {
      _showError("API Error");
    }

    setState(() => isLoading = false);
  }

  // ================= ERROR HANDLER =================
  void _showError(String message) {
    setState(() {
      hasError = true;
      cityName = "";
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ================= MAIN UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,

      // ================= APP BAR =================
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        foregroundColor: Colors.white,
        title: const Text(
          "Weather App",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Icon(Icons.wb_cloudy_rounded),
        ),
      ),

      // ================= BACKGROUND =================
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // ================= SEARCH LABEL =================
                const Text(
                  "Search City",
                  style: TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 15),

                // ================= SEARCH FIELD =================
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: hasError ? Colors.red : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: TextField(
                    controller: _cityController,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white, // WHITE BACKGROUND
                      hintText: "Enter city name...",
                      prefixIcon: const Icon(Icons.search), // LEFT ICON
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ================= BUTTON =================
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: getWeather,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3A86FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            " Get Weather ☁️",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),

                const SizedBox(height: 30),

                // ================= WEATHER CARD =================
                if (cityName.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2A38),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // CITY NAME
                        Text(
                          cityName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // TEMPERATURE
                        Text(
                          "$temperature°C",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // CONDITION
                        Text(
                          condition,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // WEATHER INFO GRID
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 2.5,
                          children: [
                            _infoTile("Humidity", "$humidity %"),
                            _infoTile("Wind", "$windSpeed m/s"),
                            _infoTile("Feels Like", "$feelsLike °C"),
                            _infoTile("Visibility", "$visibility km"),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // MIN / MAX SECTION
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF243447),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _minMaxTile(
                                "Min Temp",
                                "$minTemp °C",
                                Colors.blueAccent,
                              ),
                              _minMaxTile(
                                "Max Temp",
                                "$maxTemp °C",
                                Colors.redAccent,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= SMALL INFO TILE =================
  Widget _infoTile(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF243447),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ================= MIN / MAX TILE =================
  Widget _minMaxTile(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
