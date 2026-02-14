import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

// -----------------------------------------------------------------------------
// 5. Custom Weather Visuals
// -----------------------------------------------------------------------------

class WeatherVisual extends StatelessWidget {
  final int code;
  final int isDay;

  const WeatherVisual({super.key, required this.code, required this.isDay});

  @override
  Widget build(BuildContext context) {
    // 0: Clear sky
    // 1-3: Partly cloudy
    // 45,48: Fog
    // 51-67: Drizzle/Rain
    // 71-77: Snow
    // 95-99: Thunderstorm

    // --- NIGHT LOGIC ---
    if (isDay == 0) {
      if (code == 0) {
        // Clear Night: Just Moon
        return const Icon(Icons.nightlight_round, size: 150, color: Color(0xFFFEFCD7));
      } else if (code >= 1 && code <= 3) {
        // Partly Cloudy Night: Moon + Cloud (Requested Design)
        return SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Moon (Back)
              Positioned(
                top: 20,
                right: 40,
                child: const Icon(Icons.nightlight_round, size: 120, color: Color(0xFFFEFCD7))
                    .animate(onPlay: (c) => c.repeat())
                    .shimmer(duration: 2000.ms, color: Colors.white30),
              ),
              // Cloud (Front, slightly offset)
              Positioned(
                bottom: 20,
                left: 20,
                child: const Icon(Icons.cloud, size: 120, color: Colors.white)
                    .animate()
                    .fadeIn()
                    .slideX(begin: -0.1, end: 0, duration: 800.ms),
              ),
            ],
          ),
        );
      } else if (code >= 95) {
        // Storm
        return const Icon(Icons.thunderstorm, size: 150, color: Colors.white);
      } else if (code >= 51) {
        // Rain
        return const Icon(Icons.beach_access, size: 150, color: Colors.white); // Placeholder
      }
      // Default Night
      return const Icon(Icons.nightlight_round, size: 150, color: Colors.white70);
    } 
    
    // --- DAY LOGIC ---
    else {
      if (code == 0) {
        return const Icon(Icons.wb_sunny_rounded, size: 150, color: Colors.orangeAccent);
      } else if (code >= 1 && code <= 3) {
        // Day + Clouds
        return SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 20,
                right: 30,
                child: const Icon(Icons.wb_sunny_rounded, size: 100, color: Colors.orangeAccent),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                child: const Icon(Icons.cloud, size: 120, color: Colors.white),
              ),
            ],
          ),
        );
      } else if (code >= 95) {
        return const Icon(Icons.thunderstorm, size: 150, color: Colors.white);
      } else if (code >= 51) {
        return const Icon(Icons.water_drop_outlined, size: 150, color: Colors.blueAccent);
      }
      // Default Day
      return const Icon(Icons.wb_cloudy, size: 150, color: Colors.white);
    }
  }
}
