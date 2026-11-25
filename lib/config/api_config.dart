/// Konstanta endpoint dan pembangun URI untuk Open-Meteo API.
class ApiConfig {
  ApiConfig._();

  static const String weatherBaseUrl = 'https://api.open-meteo.com/v1/forecast';
  static const String geocodingBaseUrl =
      'https://geocoding-api.open-meteo.com/v1/search';

  static const Duration requestTimeout = Duration(seconds: 10);

  /// Membentuk URI untuk mengambil data cuaca terkini dan perkiraan 7 hari.
  static Uri buildForecastUri({
    required double latitude,
    required double longitude,
  }) {
    return Uri.parse(weatherBaseUrl).replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current':
            'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m',
        'daily':
            'temperature_2m_max,temperature_2m_min,precipitation_probability_max,weather_code',
        'timezone': 'auto',
        'forecast_days': '7',
      },
    );
  }

  /// Membentuk URI untuk mencari kota berdasarkan nama.
  static Uri buildGeocodingUri(String query) {
    return Uri.parse(geocodingBaseUrl).replace(
      queryParameters: {
        'name': query.trim(),
        'count': '10',
        'language': 'id',
        'format': 'json',
      },
    );
  }
}
