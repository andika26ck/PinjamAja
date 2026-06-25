import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/item.dart';

/// Reusable item card widget untuk display barang di grid.
class ItemCard extends StatelessWidget {
  final Item item;
  final String? ownerName;
  final String? ownerAvatar;

  const ItemCard({
    required this.item,
    this.ownerName,
    this.ownerAvatar,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.imageUrls.isNotEmpty
        ? item.imageUrls.first
        : 'https://picsum.photos/400/300?random=${item.id}';

    return GestureDetector(
      onTap: () => context.go('/item/${item.id}'),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto Item dengan Badge Status
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      color: Colors.grey[200],
                    ),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                ),
                // Badge Status
                Positioned(
                  top: 8,
                  left: 8,
                  child: _StatusBadge(status: item.status),
                ),
              ],
            ),
            // Konten Item
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Owner Avatar & Nama
                    if (ownerName != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundImage: ownerAvatar != null
                                  ? NetworkImage(ownerAvatar!)
                                  : null,
                              child: ownerAvatar == null
                                  ? const Icon(Icons.person, size: 12)
                                  : null,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                ownerName!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style:
                                    Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Judul
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 6),
                    // Rating
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: Colors.amber[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${item.rating.toStringAsFixed(1)} (${item.totalReviews})',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Harga
                    Text(
                      'Rp ${item.pricePerDay.toStringAsFixed(0)} / hari',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Badge untuk tampilkan status item (available, rented, unavailable).
class _StatusBadge extends StatelessWidget {
  final ItemStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      ItemStatus.available => ('Tersedia', Colors.green),
      ItemStatus.rented => ('Disewa', Colors.orange),
      ItemStatus.unavailable => ('Tidak Tersedia', Colors.red),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
