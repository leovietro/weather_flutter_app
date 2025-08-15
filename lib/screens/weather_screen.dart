import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  final String username;
  const WeatherScreen({required this.username});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Map<String, dynamic>? weatherData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final lat = pos.latitude;
      final lon = pos.longitude;
      const apiKey = 'API_KEY';
      final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          weatherData = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Error fetching weather data";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
    }
  }

  String _kelvinToFahrenheit(double kelvin) {
    return ((kelvin - 273.15) * 9 / 5 + 32).toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = [Colors.blue.shade300, Colors.blue.shade900];

    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.blue[700])),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Weather")),
        body: Center(child: Text(errorMessage!)),
      );
    }

    final city = weatherData!['name'];
    final country = weatherData!['sys']['country'];
    final description = weatherData!['weather'][0]['description'];
    final iconCode = weatherData!['weather'][0]['icon'];
    final temp = _kelvinToFahrenheit(weatherData!['main']['temp']);
    final feelsLike = _kelvinToFahrenheit(weatherData!['main']['feels_like']);
    final humidity = weatherData!['main']['humidity'];
    final windSpeed = weatherData!['wind']['speed'];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Hello, ${widget.username}!",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "$city, $country",
                  style: const TextStyle(fontSize: 20, color: Colors.white70),
                ),
                const SizedBox(height: 20),
                Text(
                  "$temp°F",
                  style: const TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  description[0].toUpperCase() + description.substring(1),
                  style: const TextStyle(fontSize: 22, color: Colors.white70),
                ),
                const SizedBox(height: 30),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Icon(Icons.thermostat, color: Colors.orange),
                            const SizedBox(height: 5),
                            Text(
                              "$feelsLike°F",
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Text("Feels Like"),
                          ],
                        ),
                        Column(
                          children: [
                            const Icon(Icons.water_drop, color: Colors.blue),
                            const SizedBox(height: 5),
                            Text(
                              "$humidity%",
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Text("Humidity"),
                          ],
                        ),
                        Column(
                          children: [
                            const Icon(Icons.air, color: Colors.green),
                            const SizedBox(height: 5),
                            Text(
                              "$windSpeed m/s",
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Text("Wind"),
                          ],
                        ),
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
