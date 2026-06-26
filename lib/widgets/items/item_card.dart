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
    return Card(
      elevation: 2, // Shadow yang halus
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Ujung lebih melengkung
        side: BorderSide(color: Colors.grey.shade200), // Border tipis elegan
      ),
      clipBehavior: Clip.antiAlias, // Biar gambar ngikutin border radius
      child: InkWell(
        onTap: () => context.go('/item/${item.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian Foto dengan Hero Animation
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    // Tag Hero HARUS unik dan sama antara Card dan Detail
                    tag: 'item_image_${item.id}', 
                    child: CachedNetworkImage(
                      imageUrl: item.imageUrls.isNotEmpty 
                          ? item.imageUrls.first 
                          : 'https://picsum.photos/400/300?random=${item.id}',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[100],
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[100],
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  ),
                  // Badge Status
                  if (item.status != ItemStatus.available)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: item.status == ItemStatus.rented 
                              ? Colors.orange.shade600 
                              : Colors.red.shade600,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.status == ItemStatus.rented ? 'Disewa' : 'Tidak Tersedia',
                          style: const TextStyle(
                            color: Colors.white, 
                            fontSize: 10, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Bagian Teks Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Owner Avatar & Nama (opsional, jika dikirim)
                  if (ownerName != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundImage: ownerAvatar != null
                                ? NetworkImage(ownerAvatar!)
                                : null,
                            backgroundColor: Colors.grey[200],
                            child: ownerAvatar == null
                                ? Icon(Icons.person, size: 14, color: Colors.grey[500])
                                : null,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              ownerName!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, size: 16, color: Colors.amber.shade600),
                      const SizedBox(width: 4),
                      Text(
                        item.rating.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        ' (${item.totalReviews})',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.grey.shade500,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp ${item.pricePerDay.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}