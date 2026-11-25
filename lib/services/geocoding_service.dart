import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/location_model.dart';
import 'api_exception.dart';

/// Service untuk mencari lokasi kota melalui Open-Meteo Geocoding API.
class GeocodingService {
  final http.Client _client;

  GeocodingService({http.Client? client}) : _client = client ?? http.Client();

  /// Mencari daftar kota berdasarkan [query].
  /// Mengembalikan list kosong jika [results] tidak ada di respons API.
  Future<List<LocationModel>> searchCities(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) {
      return const [];
    }

    final uri = ApiConfig.buildGeocodingUri(trimmed);

    try {
      final response = await _client.get(uri).timeout(ApiConfig.requestTimeout);

      if (response.statusCode != 200) {
        throw ApiException.server(response.statusCode);
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw ApiException.parse();
      }

      final results = decoded['results'];
      if (results == null) {
        return const [];
      }
      if (results is! List) {
        throw ApiException.parse();
      }

      return results
          .whereType<Map<String, dynamic>>()
          .map(LocationModel.fromJson)
          .toList();
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
