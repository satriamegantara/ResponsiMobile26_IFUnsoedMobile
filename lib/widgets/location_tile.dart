import 'package:flutter/material.dart';

import '../models/location_model.dart';

/// Baris daftar lokasi hasil pencarian atau favorit dengan tombol bintang.
class LocationTile extends StatelessWidget {
  final LocationModel location;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const LocationTile({
    super.key,
    required this.location,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        leading: Icon(
          Icons.location_on_outlined,
          color: colorScheme.primary,
        ),
        title: Text(
          location.name,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: location.subtitle.isNotEmpty
            ? Text(
                location.subtitle,
                style: theme.textTheme.bodyMedium,
              )
            : null,
        trailing: IconButton(
          onPressed: onToggleFavorite,
          tooltip: isFavorite ? 'Hapus dari favorit' : 'Simpan ke favorit',
          icon: Icon(
            isFavorite ? Icons.star : Icons.star_border,
            color:
                isFavorite ? colorScheme.primary : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
