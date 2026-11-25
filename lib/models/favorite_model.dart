import 'location_model.dart';

/// Model lokasi favorit yang disimpan sebagai Map di Hive.
class FavoriteModel {
  final String id;
  final String name;
  final String? admin1;
  final String country;
  final double latitude;
  final double longitude;

  const FavoriteModel({
    required this.id,
    required this.name,
    this.admin1,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  /// Membuat [FavoriteModel] dari [LocationModel].
  factory FavoriteModel.fromLocation(LocationModel location) {
    return FavoriteModel(
      id: location.id,
      name: location.name,
      admin1: location.admin1,
      country: location.country,
      latitude: location.latitude,
      longitude: location.longitude,
    );
  }

  /// Mengonversi data Map dari Hive ke [FavoriteModel].
  factory FavoriteModel.fromMap(Map<dynamic, dynamic> map) {
    return FavoriteModel(
      id: (map['id'] as String?) ?? '',
      name: (map['name'] as String?) ?? '',
      admin1: map['admin1'] as String?,
      country: (map['country'] as String?) ?? '',
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
    );
  }

  /// Mengonversi ke Map untuk disimpan di Hive tanpa TypeAdapter.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'admin1': admin1,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// Mengonversi ke [LocationModel] untuk memuat ulang data cuaca.
  LocationModel toLocation() {
    return LocationModel(
      name: name,
      latitude: latitude,
      longitude: longitude,
      country: country,
      admin1: admin1,
    );
  }
}
