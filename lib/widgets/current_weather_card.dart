import 'package:flutter/material.dart';

import '../models/location_model.dart';
import '../models/weather_model.dart';

/// Kartu utama yang menampilkan nama kota, ikon kondisi cuaca, dan suhu terkini.
class CurrentWeatherCard extends StatelessWidget {
  final LocationModel location;
  final CurrentWeather current;

  const CurrentWeatherCard({
    super.key,
    required this.location,
    required this.current,
  });

  /// Memetakan kode cuaca WMO Open-Meteo ke ikon Material dan deskripsi singkat.
  static ({IconData icon, String label}) mapWeatherCode(int code) {
    if (code == 0) {
      return (icon: Icons.wb_sunny, label: 'Cerah');
    } else if (code == 1 || code == 2) {
      return (icon: Icons.wb_cloudy, label: 'Cerah Berawan');
    } else if (code == 3) {
      return (icon: Icons.cloud, label: 'Berawan');
    } else if (code == 45 || code == 48) {
      return (icon: Icons.foggy, label: 'Berkabut');
    } else if (code >= 51 && code <= 57) {
      return (icon: Icons.grain, label: 'Gerimis');
    } else if ((code >= 61 && code <= 67) || (code >= 80 && code <= 82)) {
      return (icon: Icons.water_drop, label: 'Hujan');
    } else if ((code >= 71 && code <= 77) || code == 85 || code == 86) {
      return (icon: Icons.ac_unit, label: 'Salju');
    } else if (code >= 95 && code <= 99) {
      return (icon: Icons.thunderstorm, label: 'Hujan Petir');
    }
    return (icon: Icons.cloud_queue, label: 'Berawan');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final weatherInfo = mapWeatherCode(current.weatherCode);

    return Card(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              location.name,
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            if (location.subtitle.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                location.subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${current.temperature.round()}°C',
                        style: theme.textTheme.displayLarge?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        weatherInfo.label,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Terasa seperti ${current.apparentTemperature.round()}°C',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimaryContainer
                              .withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  weatherInfo.icon,
                  size: 72,
                  color: colorScheme.onPrimaryContainer,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
