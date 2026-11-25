import 'package:flutter/material.dart';

import '../models/location_model.dart';
import '../viewmodels/search_viewmodel.dart';
import '../widgets/location_tile.dart';

/// Halaman pencarian kota melalui Open-Meteo Geocoding API dan manajemen favorit.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final SearchViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = SearchViewModel(
      onChanged: () {
        if (mounted) {
          setState(() {});
        }
      },
    );
    _viewModel.init();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch([String? overrideQuery]) {
    final query = overrideQuery ?? _searchController.text;
    if (overrideQuery != null) {
      _searchController.text = overrideQuery;
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: overrideQuery.length),
      );
    }
    FocusScope.of(context).unfocus();
    _viewModel.search(query);
  }

  void _selectLocation(LocationModel location) {
    Navigator.of(context).pop(location);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Kota'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _performSearch(),
                      onChanged: (value) {
                        if (value.trim().isEmpty && _viewModel.hasSearched) {
                          _viewModel.clearResults();
                        } else {
                          setState(() {});
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Contoh: Jakarta, Purwokerto...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  _viewModel.clearResults();
                                },
                                icon: const Icon(Icons.clear),
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed:
                        _viewModel.isLoading ? null : () => _performSearch(),
                    child: const Text('Cari'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _buildContent(theme, colorScheme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, ColorScheme colorScheme) {
    if (_viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_viewModel.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                _viewModel.errorMessage!,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              if (_viewModel.lastQuery.isNotEmpty) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _performSearch(_viewModel.lastQuery),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba lagi'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (_viewModel.hasSearched) {
      if (_viewModel.results.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off,
                size: 56,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                'Kota tidak ditemukan',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Coba periksa ejaan atau gunakan nama kota lain.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: _viewModel.results.length,
        itemBuilder: (context, index) {
          final location = _viewModel.results[index];
          return LocationTile(
            location: location,
            isFavorite: _viewModel.isFavorite(location.id),
            onTap: () => _selectLocation(location),
            onToggleFavorite: () => _viewModel.toggleFavorite(location),
          );
        },
      );
    }

    if (_viewModel.searchHistory.isEmpty && _viewModel.favorites.isEmpty) {
      return Center(
        child: Text(
          'Ketik minimal 2 huruf nama kota untuk mulai mencari.',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_viewModel.searchHistory.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Riwayat Pencarian',
                  style: theme.textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: _viewModel.clearHistory,
                  child: const Text('Hapus'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _viewModel.searchHistory
                  .map(
                    (query) => ActionChip(
                      avatar: const Icon(Icons.history, size: 18),
                      label: Text(query),
                      onPressed: () => _performSearch(query),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],
          if (_viewModel.favorites.isNotEmpty) ...[
            Text(
              'Kota Favorit',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ..._viewModel.favorites.map((fav) {
              final location = fav.toLocation();
              return LocationTile(
                location: location,
                isFavorite: true,
                onTap: () => _selectLocation(location),
                onToggleFavorite: () => _viewModel.toggleFavorite(location),
              );
            }),
          ],
        ],
      ),
    );
  }
}
