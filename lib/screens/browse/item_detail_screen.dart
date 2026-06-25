import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/item.dart';
import '../../providers/listing_provider.dart';

class ItemDetailScreen extends ConsumerStatefulWidget {
  final String itemId;

  const ItemDetailScreen({required this.itemId, super.key});

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen> {
  late PageController _galleryController;
  int _currentImageIndex = 0;
  bool _expandDescription = false;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _galleryController = PageController();
  }

  @override
  void dispose() {
    _galleryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemAsync = ref.watch(itemDetailProvider(widget.itemId));
    final reviewsAsync = ref.watch(itemReviewsProvider(widget.itemId));

    return itemAsync.when(
      data: (item) => Scaffold(
        body: CustomScrollView(
          slivers: [
            // SliverAppBar dengan foto item di background
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    // Photo Gallery
                    PageView.builder(
                      controller: _galleryController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentImageIndex =
                              index % (item.imageUrls.isNotEmpty ? item.imageUrls.length : 1);
                        });
                      },
                      itemBuilder: (context, index) {
                        final imageUrl = item.imageUrls.isNotEmpty
                            ? item.imageUrls[index % item.imageUrls.length]
                            : 'https://picsum.photos/400/300?random=${item.id}';
                        return CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image),
                          ),
                        );
                      },
                    ),
                    // Photo counter
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(200),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_currentImageIndex + 1}/${item.imageUrls.length > 0 ? item.imageUrls.length : 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Dots indicator
                    if (item.imageUrls.length > 1)
                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: Row(
                          children: List.generate(
                            item.imageUrls.length,
                            (index) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentImageIndex == index
                                      ? Colors.white
                                      : Colors.white.withAlpha(150),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul & Rating
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${item.rating.toStringAsFixed(1)} (${item.totalReviews} ulasan)',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Kondisi & Lokasi
                    Wrap(
                      spacing: 12,
                      children: [
                        _InfoBadge(
                          label:
                              _getConditionLabel(item.condition),
                          icon: Icons.check_circle,
                        ),
                        _InfoBadge(
                          label: item.location,
                          icon: Icons.location_on,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Divider
                    Divider(color: Colors.grey[200]),
                    const SizedBox(height: 16),
                    // Harga
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rp ${item.pricePerDay.toStringAsFixed(0)} / hari',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'Deposit: Rp ${item.depositAmount.toStringAsFixed(0)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                            const SizedBox(width: 8),
                            Tooltip(
                              message:
                                  'Deposit akan dikembalikan setelah item dikembalikan dalam kondisi baik.',
                              child: Icon(Icons.info, size: 16, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(color: Colors.grey[200]),
                    const SizedBox(height: 16),
                    // Deskripsi (Collapsible)
                    _CollapsibleDescription(
                      title: 'Deskripsi',
                      description: item.description,
                      isExpanded: _expandDescription,
                      onExpand: (expanded) {
                        setState(() {
                          _expandDescription = expanded;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    Divider(color: Colors.grey[200]),
                    const SizedBox(height: 16),
                    // Ketersediaan (Calendar)
                    Text(
                      'Ketersediaan',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    TableCalendar(
                      firstDay: DateTime.now(),
                      lastDay: DateTime.now().add(const Duration(days: 365)),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      calendarBuilders: CalendarBuilders(
                        defaultBuilder: (context, day, focusedDay) {
                          final isBlocked = item.blockedDates.any(
                            (d) => isSameDay(d, day),
                          );
                          return Container(
                            decoration: BoxDecoration(
                              color: isBlocked ? Colors.red[100] : null,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                day.day.toString(),
                                style: TextStyle(
                                  color: isBlocked ? Colors.red : Colors.black,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.green[300],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('Tersedia'),
                        const SizedBox(width: 20),
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('Tidak Tersedia'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Divider(color: Colors.grey[200]),
                    const SizedBox(height: 16),
                    // Profil Pemilik
                    reviewsAsync.when(
                      data: (_) => const SizedBox.shrink(), // Placeholder
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    Text(
                      'Pemilik',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[200]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.grey[200],
                            child: const Icon(Icons.person),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nama Pemilik',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.star, size: 14, color: Colors.amber[600]),
                                    const SizedBox(width: 4),
                                    const Text('4.8 • Terverifikasi', style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => context.go(
                              '/chat/${item.ownerId}',
                              extra: {'itemTitle': item.title},
                            ),
                            child: const Text('Chat'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Divider(color: Colors.grey[200]),
                    const SizedBox(height: 16),
                    // Reviews
                    Text(
                      'Ulasan',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    reviewsAsync.when(
                      data: (reviews) {
                        if (reviews.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                'Belum ada ulasan',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            ),
                          );
                        }
                        return Column(
                          children: [
                            ...reviews.take(3).map((review) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor: Colors.grey[200],
                                        child: const Icon(Icons.person, size: 16),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              review.reviewerName,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            Row(
                                              children: [
                                                ...List.generate(
                                                  5,
                                                  (i) => Icon(
                                                    Icons.star,
                                                    size: 12,
                                                    color: i < review.rating
                                                        ? Colors.amber[600]
                                                        : Colors.grey[300],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    review.comment,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            )),
                            if (reviews.length > 3)
                              TextButton(
                                onPressed: () {
                                  // TODO: Navigate ke review list screen
                                },
                                child: const Text('Lihat Semua Ulasan'),
                              ),
                          ],
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (error, _) => Center(
                        child: Text(error.toString()),
                      ),
                    ),
                    const SizedBox(height: 100), // Space untuk bottom button
                  ],
                ),
              ),
            ),
          ],
        ),
        // Sticky Bottom Bar
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rp ${item.pricePerDay.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'per hari',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: item.status == ItemStatus.rented
                        ? null
                        : () => context.go('/booking/${item.id}'),
                    child: Text(
                      item.status == ItemStatus.rented ? 'Sedang Disewa' : 'Sewa Sekarang',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text(error.toString())),
      ),
    );
  }

  String _getConditionLabel(ItemCondition condition) {
    return switch (condition) {
      ItemCondition.baru => 'Baru',
      ItemCondition.sangatBaik => 'Sangat Baik',
      ItemCondition.baik => 'Baik',
      ItemCondition.cukup => 'Cukup',
    };
  }
}

/// Widget untuk info badge (kondisi, lokasi, dll).
class _InfoBadge extends StatelessWidget {
  final String label;
  final IconData icon;

  const _InfoBadge({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Widget untuk deskripsi yang bisa di-expand/collapse.
class _CollapsibleDescription extends StatelessWidget {
  final String title;
  final String description;
  final bool isExpanded;
  final Function(bool) onExpand;

  const _CollapsibleDescription({
    required this.title,
    required this.description,
    required this.isExpanded,
    required this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            IconButton(
              icon: Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
              ),
              onPressed: () => onExpand(!isExpanded),
              iconSize: 20,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          description,
          maxLines: isExpanded ? null : 4,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
