import '../models/favorite_model.dart';
import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../repositories/local_storage_repository.dart';
import '../services/api_exception.dart';
import '../services/weather_service.dart';

/// ViewModel untuk mengelola state dan logika halaman Home / Weather Screen.
/// Tidak mengimpor widget Flutter agar pemisahan MVVM tetap terjaga.
class HomeViewModel {
  final WeatherService _weatherService;
  final LocalStorageRepository _storageRepository;
  final void Function() onChanged;

  HomeViewModel({
    WeatherService? weatherService,
    LocalStorageRepository? storageRepository,
    required this.onChanged,
  })  : _weatherService = weatherService ?? WeatherService(),
        _storageRepository = storageRepository ?? LocalStorageRepository();

  bool isLoading = false;
  String? errorMessage;
  WeatherModel? weatherData;
  LocationModel? selectedLocation;
  List<FavoriteModel> favorites = [];

  bool get isCurrentFavorite {
    final location = selectedLocation;
    if (location == null) return false;
    return _storageRepository.isFavorite(location.id);
  }

  bool get isEmptyState =>
      !isLoading &&
      errorMessage == null &&
      weatherData == null &&
      selectedLocation == null;

  /// Memuat daftar favorit serta kota terakhir saat aplikasi dibuka.
  Future<void> init() async {
    favorites = _storageRepository.getFavorites();
    final initialLocation = _storageRepository.getLastCity() ??
        (favorites.isNotEmpty ? favorites.first.toLocation() : null);

    if (initialLocation != null) {
      await loadWeather(initialLocation);
    } else {
      onChanged();
    }
  }

  /// Mengambil data cuaca dari Open-Meteo untuk [location] yang dipilih.
  Future<void> loadWeather(LocationModel location) async {
    selectedLocation = location;
    isLoading = true;
    errorMessage = null;
    onChanged();

    await _storageRepository.saveLastCity(location);

    try {
      weatherData = await _weatherService.fetchWeather(
        latitude: location.latitude,
        longitude: location.longitude,
      );
    } on ApiException catch (e) {
      weatherData = null;
      errorMessage = e.message;
    } catch (_) {
      weatherData = null;
      errorMessage = 'Terjadi kesalahan saat memuat data cuaca';
    } finally {
      isLoading = false;
      favorites = _storageRepository.getFavorites();
      onChanged();
    }
  }

  /// Memuat ulang cuaca untuk kota yang sedang aktif.
  Future<void> retry() async {
    final location = selectedLocation;
    if (location != null) {
      await loadWeather(location);
    }
  }

  /// Menyimpan atau menghapus kota aktif dari daftar favorit Hive.
  Future<void> toggleFavorite() async {
    final location = selectedLocation;
    if (location == null) return;

    await _storageRepository.toggleFavorite(location);
    favorites = _storageRepository.getFavorites();
    onChanged();
  }

  /// Menyinkronkan daftar favorit dari Hive setelah kembali dari Search Screen.
  void refreshFavorites() {
    favorites = _storageRepository.getFavorites();
    onChanged();
  }
}
