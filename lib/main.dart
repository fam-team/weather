import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'weather_visual.dart';
import 'package:flutter_animate/flutter_animate.dart';

// -----------------------------------------------------------------------------
// 1. Models
// -----------------------------------------------------------------------------

class WeatherData {
  final double latitude;
  final double longitude;
  final CurrentWeather currentWeather;

  WeatherData({
    required this.latitude,
    required this.longitude,
    required this.currentWeather,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      latitude: json['latitude'],
      longitude: json['longitude'],
      currentWeather: CurrentWeather.fromJson(json['current_weather']),
    );
  }
}

class CurrentWeather {
  final String time;
  final double temperature;
  final double windspeed;
  final int winddirection;
  final int isDay;
  final int weathercode;

  CurrentWeather({
    required this.time,
    required this.temperature,
    required this.windspeed,
    required this.winddirection,
    required this.isDay,
    required this.weathercode,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      time: json['time'],
      temperature: (json['temperature'] as num).toDouble(),
      windspeed: (json['windspeed'] as num).toDouble(),
      winddirection: json['winddirection'],
      isDay: json['is_day'],
      weathercode: json['weathercode'],
    );
  }
}

// -----------------------------------------------------------------------------
// 2. Constants & Utilities
// -----------------------------------------------------------------------------

const String kWeatherApiUrl =
    'https://api.open-meteo.com/v1/forecast?latitude=40.71&longitude=-74.01&current_weather=true';

String getWeatherDescription(int code) {
  // WMO Weather interpretation codes
  if (code == 0) return 'Clear Sky';
  if (code >= 1 && code <= 3) return 'Partly Cloudy';
  if (code >= 45 && code <= 48) return 'Foggy';
  if (code >= 51 && code <= 55) return 'Drizzle';
  if (code >= 61 && code <= 67) return 'Rain';
  if (code >= 71 && code <= 77) return 'Snow';
  if (code >= 80 && code <= 82) return 'Rain Showers';
  if (code >= 95) return 'Thunderstorm';
  return 'Unknown';
}

IconData getWeatherIcon(int code) {
  if (code == 0) return Icons.wb_sunny_rounded;
  if (code >= 1 && code <= 3) return Icons.cloud_queue_rounded;
  if (code >= 45 && code <= 48) return Icons.waves;
  if (code >= 51 && code <= 67) return Icons.water_drop_outlined;
  if (code >= 71 && code <= 77) return Icons.ac_unit_rounded;
  if (code >= 95) return Icons.bolt_rounded;
  return Icons.cloud;
}

// -----------------------------------------------------------------------------
// 3. Main App
// -----------------------------------------------------------------------------

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        textTheme: GoogleFonts.outfitTextTheme(Theme.of(context).textTheme)
            .apply(bodyColor: Colors.white, displayColor: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      home: const WeatherHomePage(),
    );
  }
}

// -----------------------------------------------------------------------------
// 4. Home Page
// -----------------------------------------------------------------------------

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  late Future<WeatherData> _weatherFuture;

  @override
  void initState() {
    super.initState();
    _weatherFuture = _fetchWeather();
  }

  Future<WeatherData> _fetchWeather() async {
    // START: Mocked Data for Design Verification (Moon + Cloud)
    // The user requested to match the "moon with cloud" design.
    // We force the state to Night (isDay: 0) and Partly Cloudy (code: 2).
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    return WeatherData(
      latitude: 40.71,
      longitude: -74.01,
      currentWeather: CurrentWeather(
        time: DateTime.now().toIso8601String(),
        temperature: 18.5,
        windspeed: 12.0,
        winddirection: 240,
        isDay: 0, // Night for Moon
        weathercode: 2, // Partly Cloudy for Cloud
      ),
    );
    // END: Mocked Data

    /* 
    // Real API Call (Restored when design is approved)
    final response = await http.get(Uri.parse(kWeatherApiUrl));
    if (response.statusCode == 200) {
      return WeatherData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
    */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E1E2C), // Dark Blue/Black
              Color(0xFF2D2B55), // Deep Purpleish
            ],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<WeatherData>(
            future: _weatherFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.redAccent)),
                );
              } else if (!snapshot.hasData) {
                return const Center(child: Text('No data found'));
              }

              final data = snapshot.data!;
              final current = data.currentWeather;

              // Parsing time for display
              // API returns ISO8601 string, e.g., "2026-02-14T04:30"
              final dateTime = DateTime.parse(current.time);
              final timeString = DateFormat('h:mm a').format(dateTime);

              return Column(
                children: [
                  const SizedBox(height: 20),
                  // Location Header (Mocked location name as API matches lat/long for simplified example)
                  Text(
                    'New York City',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ).animate().fadeIn().slideY(begin: -0.2, end: 0),
                  
                  const SizedBox(height: 5),

                  Text(
                    timeString,
                    style: GoogleFonts.outfit(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(delay: 200.ms).scale(),

                  const Spacer(), 

                  // Central Weather Icon with Glow
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.3),
                              blurRadius: 60,
                              spreadRadius: 20,
                            ),
                          ],
                        ),
                      ),
                      WeatherVisual(
                        code: current.weathercode,
                        isDay: current.isDay,
                      ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                       .scale(
                         begin: const Offset(1, 1), 
                         end: const Offset(1.05, 1.05),
                         duration: 2000.ms,
                         curve: Curves.easeInOut,
                       ),
                    ],
                  ),

                  const Spacer(),

                  // Temperature Area
                  Column(
                    children: [
                      Text(
                        '${current.temperature.round()}°C',
                        style: GoogleFonts.outfit(
                          fontSize: 80,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        getWeatherDescription(current.weathercode),
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          color: Colors.blueGrey.shade100,
                        ),
                      ),
                    ],
                  ).animate().fadeIn().slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 30),

                  // Detail Cards (Glassmorphism)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildGlassCard(
                          label: 'Wind',
                          value: '${current.windspeed} km/h',
                          icon: Icons.air,
                        ),
                        const SizedBox(width: 16),
                        _buildGlassCard(
                          label: 'Direction',
                          value: '${current.winddirection}°',
                          icon: Icons.navigation_rounded,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 40),

                  // Bottom Forecast Section (Mocked for design faithfulness as API is current only)
                  // The user user requested "single page... achieve above app design".
                  // The loop creates dummy daily forecast cards.
                  SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(left: 24),
                      children: [
                        _buildForecastCard('Today', -1, Icons.cloud),
                        _buildForecastCard('Feb 15', -2, Icons.wb_cloudy),
                        _buildForecastCard('Feb 16', 0, Icons.wb_sunny),
                        _buildForecastCard('Feb 17', 2, Icons.wb_sunny),
                         _buildForecastCard('Feb 18', 1, Icons.cloud_queue),
                      ],
                    ),
                  ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.2, end: 0),

                  const SizedBox(height: 20),
                ],
              );
            },
          ),
        ),
      ),
      // Simple Bottom Nav Bar for Visual Completeness
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1E1E2C),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Today'),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: 'Hourly'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Daily'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required String label, required String value, required IconData icon}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white70, size: 28),
            const SizedBox(height: 8),
            Text(value, 
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
            ),
            Text(label, 
              style: const TextStyle(fontSize: 14, color: Colors.white54)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastCard(String date, int temp, IconData icon) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(date, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 8),
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(height: 8),
          Text('$temp°', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
