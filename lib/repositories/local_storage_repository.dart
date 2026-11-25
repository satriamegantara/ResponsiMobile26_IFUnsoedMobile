import 'package:hive_flutter/hive_flutter.dart';

import '../models/favorite_model.dart';
import '../models/location_model.dart';

/// Repository untuk membungkus akses penyimpanan lokal Hive
/// (favorit kota, riwayat pencarian, dan kota aktif terakhir).
class LocalStorageRepository {
  static const String favoritesBoxName = 'favorites';
  static const String searchHistoryBoxName = 'search_history';
  static const String settingsBoxName = 'settings';
  static const String lastCityKey = 'last_city';
  static const int maxSearchHistory = 10;

  /// Menginisialisasi Hive dan membuka seluruh box sebelum aplikasi dijalankan.
  static Future<void> init() async {
    try {
      await Hive.initFlutter();
      await Hive.openBox<dynamic>(favoritesBoxName);
      await Hive.openBox<String>(searchHistoryBoxName);
      await Hive.openBox<dynamic>(settingsBoxName);
    } catch (_) {
      // Penanganan aman agar aplikasi tetap dapat berjalan meski Hive gagal dibuka.
    }
  }

  Box<dynamic> get _favoritesBox => Hive.box<dynamic>(favoritesBoxName);
  Box<String> get _historyBox => Hive.box<String>(searchHistoryBoxName);
  Box<dynamic> get _settingsBox => Hive.box<dynamic>(settingsBoxName);

  /// Mengambil seluruh kota favorit yang tersimpan.
  List<FavoriteModel> getFavorites() {
    try {
      return _favoritesBox.values
          .whereType<Map<dynamic, dynamic>>()
          .map(FavoriteModel.fromMap)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  /// Mengecek apakah lokasi dengan [id] sudah ada di daftar favorit.
  bool isFavorite(String id) {
    try {
      return _favoritesBox.containsKey(id);
    } catch (_) {
      return false;
    }
  }

  /// Menyimpan kota ke daftar favorit.
  Future<void> addFavorite(FavoriteModel favorite) async {
    try {
      await _favoritesBox.put(favorite.id, favorite.toMap());
    } catch (_) {}
  }

  /// Menghapus kota dari daftar favorit berdasarkan [id].
  Future<void> removeFavorite(String id) async {
    try {
      await _favoritesBox.delete(id);
    } catch (_) {}
  }

  /// Menambah atau menghapus favorit untuk [location].
  Future<bool> toggleFavorite(LocationModel location) async {
    if (isFavorite(location.id)) {
      await removeFavorite(location.id);
      return false;
    } else {
      await addFavorite(FavoriteModel.fromLocation(location));
      return true;
    }
  }

  /// Mengambil riwayat pencarian terbaru (maksimal 10 kata kunci).
  List<String> getSearchHistory() {
    try {
      return _historyBox.values.toList().reversed.toList();
    } catch (_) {
      return const [];
    }
  }

  /// Menyimpan kata kunci pencarian ke riwayat (maksimal 10 item terbaru).
  Future<void> addSearchHistory(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    try {
      final current = _historyBox.values.toList();
      current.removeWhere(
        (item) => item.toLowerCase() == trimmed.toLowerCase(),
      );
      current.add(trimmed);

      if (current.length > maxSearchHistory) {
        current.removeRange(0, current.length - maxSearchHistory);
      }

      await _historyBox.clear();
      await _historyBox.addAll(current);
    } catch (_) {}
  }

  /// Menghapus seluruh riwayat pencarian.
  Future<void> clearSearchHistory() async {
    try {
      await _historyBox.clear();
    } catch (_) {}
  }

  /// Mengambil kota aktif terakhir yang disimpan di box settings.
  LocationModel? getLastCity() {
    try {
      final raw = _settingsBox.get(lastCityKey);
      if (raw is Map<dynamic, dynamic>) {
        return LocationModel.fromJson(Map<String, dynamic>.from(raw));
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Menyimpan kota aktif terakhir agar dimuat ulang saat startup.
  Future<void> saveLastCity(LocationModel location) async {
    try {
      await _settingsBox.put(lastCityKey, location.toJson());
    } catch (_) {}
  }
}
