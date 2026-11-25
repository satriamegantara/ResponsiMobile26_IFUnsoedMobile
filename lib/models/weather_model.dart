/// Model respons forecast dari Open-Meteo Weather API (current + daily).
class WeatherModel {
  final CurrentWeather current;
  final List<DailyForecast> daily;

  const WeatherModel({
    required this.current,
    required this.daily,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final currentJson = json['current'] as Map<String, dynamic>;
    final dailyJson = json['daily'] as Map<String, dynamic>;

    final times = (dailyJson['time'] as List<dynamic>).cast<String>();
    final maxTemps = (dailyJson['temperature_2m_max'] as List<dynamic>)
        .map((e) => (e as num).toDouble())
        .toList();
    final minTemps = (dailyJson['temperature_2m_min'] as List<dynamic>)
        .map((e) => (e as num).toDouble())
        .toList();
    final rainProbs =
        (dailyJson['precipitation_probability_max'] as List<dynamic>)
            .map((e) => e == null ? 0 : (e as num).toInt())
            .toList();
    final weatherCodes = (dailyJson['weather_code'] as List<dynamic>)
        .map((e) => e == null ? 0 : (e as num).toInt())
        .toList();

    final dailyList = List<DailyForecast>.generate(
      times.length,
      (index) => DailyForecast(
        date: DateTime.parse(times[index]),
        maxTemperature: maxTemps[index],
        minTemperature: minTemps[index],
        precipitationProbabilityMax: rainProbs[index],
        weatherCode: weatherCodes[index],
      ),
    );

    return WeatherModel(
      current: CurrentWeather.fromJson(currentJson),
      daily: dailyList,
    );
  }
}

/// Model kondisi cuaca terkini.
class CurrentWeather {
  final double temperature;
  final int relativeHumidity;
  final double apparentTemperature;
  final double precipitation;
  final int weatherCode;
  final double windSpeed;

  const CurrentWeather({
    required this.temperature,
    required this.relativeHumidity,
    required this.apparentTemperature,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: (json['temperature_2m'] as num).toDouble(),
      relativeHumidity: (json['relative_humidity_2m'] as num).toInt(),
      apparentTemperature: (json['apparent_temperature'] as num).toDouble(),
      precipitation: (json['precipitation'] as num).toDouble(),
      weatherCode: (json['weather_code'] as num).toInt(),
      windSpeed: (json['wind_speed_10m'] as num).toDouble(),
    );
  }
}

/// Model perkiraan cuaca harian.
class DailyForecast {
  final DateTime date;
  final double maxTemperature;
  final double minTemperature;
  final int precipitationProbabilityMax;
  final int weatherCode;

  const DailyForecast({
    required this.date,
    required this.maxTemperature,
    required this.minTemperature,
    required this.precipitationProbabilityMax,
    required this.weatherCode,
  });
}
