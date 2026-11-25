import 'package:flutter/material.dart';

import '../models/location_model.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/daily_forecast_tile.dart';
import '../widgets/weather_detail_item.dart';

/// Halaman utama yang menampilkan kondisi cuaca terkini dan perkiraan harian.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel(
      onChanged: () {
        if (mounted) {
          setState(() {});
        }
      },
    );
    _viewModel.init();
  }

  Future<void> _openSearch() async {
    final selected =
        await Navigator.of(context).pushNamed<LocationModel>('/search');
    if (!mounted) return;

    if (selected != null) {
      await _viewModel.loadWeather(selected);
    } else {
      _viewModel.refreshFavorites();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('WeatherApp'),
        actions: [
          if (_viewModel.selectedLocation != null)
            IconButton(
              onPressed: _viewModel.toggleFavorite,
              tooltip: _viewModel.isCurrentFavorite
                  ? 'Hapus dari favorit'
                  : 'Simpan ke favorit',
              icon: Icon(
                _viewModel.isCurrentFavorite ? Icons.star : Icons.star_border,
                color: _viewModel.isCurrentFavorite
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          IconButton(
            onPressed: _openSearch,
            tooltip: 'Cari kota',
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(theme, colorScheme),
      ),
    );
  }

  Widget _buildBody(ThemeData theme, ColorScheme colorScheme) {
    if (_viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_viewModel.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off,
                size: 56,
                color: colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                _viewModel.errorMessage!,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _viewModel.retry,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_viewModel.isEmptyState) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_searching,
                size: 64,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Belum ada kota dipilih',
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Cari nama kota untuk melihat kondisi cuaca terkini dan perkiraan beberapa hari ke depan.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _openSearch,
                icon: const Icon(Icons.search),
                label: const Text('Cari Kota'),
              ),
            ],
          ),
        ),
      );
    }

    final location = _viewModel.selectedLocation!;
    final weather = _viewModel.weatherData!;
    final todayRainProb = weather.daily.isNotEmpty
        ? weather.daily.first.precipitationProbabilityMax
        : 0;

    return RefreshIndicator(
      onRefresh: _viewModel.retry,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_viewModel.favorites.isNotEmpty) ...[
              Text(
                'Kota Favorit',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _viewModel.favorites.map((fav) {
                  final isSelected = fav.id == location.id;
                  return ChoiceChip(
                    label: Text(fav.name),
                    selected: isSelected,
                    onSelected: (_) {
                      _viewModel.loadWeather(fav.toLocation());
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            CurrentWeatherCard(
              location: location,
              current: weather.current,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: WeatherDetailItem(
                    icon: Icons.water_drop_outlined,
                    label: 'Kelembapan',
                    value: '${weather.current.relativeHumidity}%',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: WeatherDetailItem(
                    icon: Icons.air,
                    label: 'Angin',
                    value: '${weather.current.windSpeed.round()} km/j',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: WeatherDetailItem(
                    icon: Icons.umbrella_outlined,
                    label: 'Peluang Hujan',
                    value: '$todayRainProb%',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Perkiraan Harian',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            ...List.generate(
              weather.daily.length,
              (index) => DailyForecastTile(
                forecast: weather.daily[index],
                isToday: index == 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
