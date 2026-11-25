/// Model lokasi hasil Open-Meteo Geocoding API.
class LocationModel {
  final String name;
  final double latitude;
  final double longitude;
  final String country;
  final String? admin1;

  const LocationModel({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.country,
    this.admin1,
  });

  /// Kunci unik lokasi berbasis koordinat (lat_lon).
  String get id => '${latitude}_$longitude';

  /// Ringkasan wilayah dan negara untuk ditampilkan di UI.
  String get subtitle {
    final parts = <String>[
      if (admin1 != null && admin1!.trim().isNotEmpty) admin1!.trim(),
      if (country.trim().isNotEmpty) country.trim(),
    ];
    return parts.join(', ');
  }

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      name: (json['name'] as String?) ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      country: (json['country'] as String?) ?? '',
      admin1: json['admin1'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'country': country,
      'admin1': admin1,
    };
  }
}
