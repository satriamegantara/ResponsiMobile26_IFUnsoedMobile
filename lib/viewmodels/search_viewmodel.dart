import '../models/favorite_model.dart';
import '../models/location_model.dart';
import '../repositories/local_storage_repository.dart';
import '../services/api_exception.dart';
import '../services/geocoding_service.dart';

/// ViewModel untuk mengelola state pencarian kota, riwayat, dan favorit.
/// Tidak mengimpor widget Flutter agar tetap terpisah dari layer View.
class SearchViewModel {
  final GeocodingService _geocodingService;
  final LocalStorageRepository _storageRepository;
  final void Function() onChanged;

  SearchViewModel({
    GeocodingService? geocodingService,
    LocalStorageRepository? storageRepository,
    required this.onChanged,
  })  : _geocodingService = geocodingService ?? GeocodingService(),
        _storageRepository = storageRepository ?? LocalStorageRepository();

  bool isLoading = false;
  String? errorMessage;
  List<LocationModel> results = [];
  List<String> searchHistory = [];
  List<FavoriteModel> favorites = [];
  String lastQuery = '';
  bool hasSearched = false;

  /// Memuat riwayat pencarian dan daftar favorit dari Hive saat screen dibuka.
  void init() {
    searchHistory = _storageRepository.getSearchHistory();
    favorites = _storageRepository.getFavorites();
    onChanged();
  }

  /// Mengecek apakah lokasi sudah tersimpan di favorit.
  bool isFavorite(String id) => _storageRepository.isFavorite(id);

  /// Mencari kota melalui Open-Meteo Geocoding API (minimal 2 karakter).
  Future<void> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) {
      errorMessage = 'Masukkan minimal 2 karakter untuk mencari kota';
      results = [];
      hasSearched = false;
      onChanged();
      return;
    }

    lastQuery = trimmed;
    isLoading = true;
    errorMessage = null;
    hasSearched = true;
    onChanged();

    try {
      results = await _geocodingService.searchCities(trimmed);
      await _storageRepository.addSearchHistory(trimmed);
      searchHistory = _storageRepository.getSearchHistory();
    } on ApiException catch (e) {
      results = [];
      errorMessage = e.message;
    } catch (_) {
      results = [];
      errorMessage = 'Terjadi kesalahan saat mencari kota';
    } finally {
      isLoading = false;
      onChanged();
    }
  }

  /// Menghapus hasil pencarian saat input dikosongkan.
  void clearResults() {
    results = [];
    errorMessage = null;
    hasSearched = false;
    lastQuery = '';
    onChanged();
  }

  /// Menambah atau menghapus kota dari daftar favorit Hive.
  Future<void> toggleFavorite(LocationModel location) async {
    await _storageRepository.toggleFavorite(location);
    favorites = _storageRepository.getFavorites();
    onChanged();
  }

  /// Menghapus seluruh riwayat pencarian di Hive.
  Future<void> clearHistory() async {
    await _storageRepository.clearSearchHistory();
    searchHistory = [];
    onChanged();
  }
}
