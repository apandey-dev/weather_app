import 'package:flutter/material.dart';
import 'weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _controller = TextEditingController();
  final WeatherService _service = WeatherService();

  Map<String, dynamic>? weatherData;
  bool isLoading = false;
  String errorMessage = "";

  @override
  void dispose() {
    _controller.dispose(); // Prevent memory leak
    super.dispose();
  }

  Future<void> getWeather() async {
    if (_controller.text.trim().isEmpty) return;

    FocusScope.of(context).unfocus();

    setState(() {
      isLoading = true;
      weatherData = null;
      errorMessage = "";
    });

    try {
      final data = await _service.fetchWeather(_controller.text.trim());

      setState(() {
        weatherData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "City not found!";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 🔍 Search Field
                TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search City",
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // 🔘 Button
                ElevatedButton(
                  onPressed: isLoading ? null : getWeather,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Get Weather"),
                ),

                const SizedBox(height: 25),

                // 📦 Content Section
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (errorMessage.isNotEmpty)
                          Text(
                            errorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),

                        if (!isLoading &&
                            weatherData == null &&
                            errorMessage.isEmpty)
                          const Text(
                            "Search for a city to see weather",
                            style: TextStyle(color: Colors.white70),
                          ),

                        if (weatherData != null) ...[
                          _WeatherHeader(data: weatherData!),
                          const SizedBox(height: 20),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            children: [
                              _InfoTile(
                                title: "Humidity",
                                value: "${weatherData!['humidity']}%",
                              ),
                              _InfoTile(
                                title: "Wind",
                                value: "${weatherData!['wind']} m/s",
                              ),
                              _InfoTile(
                                title: "Feels Like",
                                value: "${weatherData!['feelsLike']}°C",
                              ),
                              _InfoTile(
                                title: "Clouds",
                                value: "${weatherData!['clouds']}%",
                              ),
                              _InfoTile(
                                title: "Visibility",
                                value: "${weatherData!['visibility']} km",
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================= WEATHER HEADER =================
class _WeatherHeader extends StatelessWidget {
  final Map<String, dynamic> data;

  const _WeatherHeader({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            data['name'],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Image.network(
            "https://openweathermap.org/img/wn/${data['icon']}@2x.png",
          ),
          Text(
            "${data['temp']}°C",
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            data['condition'],
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

// ================= INFO TILE =================
class _InfoTile extends StatelessWidget {
  final String title;
  final String value;

  const _InfoTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
