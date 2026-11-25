import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:responsimobile/config/app_theme.dart';
import 'package:responsimobile/models/location_model.dart';
import 'package:responsimobile/models/weather_model.dart';
import 'package:responsimobile/widgets/current_weather_card.dart';

void main() {
  testWidgets('CurrentWeatherCard menampilkan nama kota dan suhu',
      (WidgetTester tester) async {
    const location = LocationModel(
      name: 'Purwokerto',
      latitude: -7.4214,
      longitude: 109.2344,
      country: 'Indonesia',
      admin1: 'Jawa Tengah',
    );
    const current = CurrentWeather(
      temperature: 29.0,
      relativeHumidity: 75,
      apparentTemperature: 32.0,
      precipitation: 0.0,
      weatherCode: 1,
      windSpeed: 10.0,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: CurrentWeatherCard(
            location: location,
            current: current,
          ),
        ),
      ),
    );

    expect(find.text('Purwokerto'), findsOneWidget);
    expect(find.text('29°C'), findsOneWidget);
    expect(find.text('Cerah Berawan'), findsOneWidget);
  });
}
