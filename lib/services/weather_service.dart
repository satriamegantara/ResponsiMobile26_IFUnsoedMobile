import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/weather_model.dart';
import 'api_exception.dart';

/// Service untuk mengambil data prakiraan cuaca dari Open-Meteo Forecast API.
class WeatherService {
  final http.Client _client;

  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  /// Mengambil data cuaca terkini dan harian berdasarkan koordinat lokasi.
  Future<WeatherModel> fetchWeather({
    required double latitude,
    required double longitude,
  }) async {
    final uri = ApiConfig.buildForecastUri(
      latitude: latitude,
      longitude: longitude,
    );

    try {
      final response = await _client.get(uri).timeout(ApiConfig.requestTimeout);

      if (response.statusCode != 200) {
        throw ApiException.server(response.statusCode);
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw ApiException.parse();
      }

      return WeatherModel.fromJson(decoded);
    } on ApiException {
      rethrow;
    } on SocketException {
      throw ApiException.noInternet();
    } on TimeoutException {
      throw ApiException.timeout();
    } on FormatException {
      throw ApiException.parse();
    } on TypeError {
      throw ApiException.parse();
    } catch (_) {
      throw ApiException.parse();
    }
  }
}
