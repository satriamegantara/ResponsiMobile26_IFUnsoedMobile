import 'package:flutter/material.dart';

import '../models/weather_model.dart';
import 'current_weather_card.dart';

/// Baris perkiraan cuaca harian dengan ikon, peluang hujan, dan suhu min/maks.
class DailyForecastTile extends StatelessWidget {
  final DailyForecast forecast;
  final bool isToday;

  const DailyForecastTile({
    super.key,
    required this.forecast,
    this.isToday = false,
  });

  static const List<String> _dayNames = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  String _formatDayLabel() {
    if (isToday) return 'Hari Ini';
    return _dayNames[forecast.date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final weatherInfo = CurrentWeatherCard.mapWeatherCode(forecast.weatherCode);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                _formatDayLabel(),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            Icon(
              weatherInfo.icon,
              size: 22,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: Text(
                '${forecast.precipitationProbabilityMax}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ),
            Text(
              '${forecast.minTemperature.round()}° / ${forecast.maxTemperature.round()}°',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
