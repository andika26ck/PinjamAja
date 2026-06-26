import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../../models/item.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listing_provider.dart' as listing;
import '../../services/listing_service.dart';
import '../../widgets/common/empty_state.dart'; // WIDGET BARU KITA

class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider).valueOrNull;
    
    if (authState == null || authState.user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Barang Saya')),
        body: const Center(child: Text('Silakan login terlebih dahulu')),
      );
    }

    final ownerId = authState.user!.id;
    final myListingsAsync = ref.watch(listing.myListingsNotifierProvider(ownerId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Barang Saya'),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/listing/create'),
        child: const Icon(Icons.add),
      ),
      // PERBAIKAN: Bungkus body dengan RefreshIndicator
      body: RefreshIndicator(
        onRefresh: () async {
          // Invalidate provider untuk me-reload data dari Supabase
          ref.invalidate(listing.myListingsNotifierProvider(ownerId));
        },
        child: myListingsAsync.when(
          loading: () => ListView.builder(
            itemCount: 6,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.all(12),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          error: (error, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(), // Biar tetap bisa ditarik ke bawah
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: EmptyState(
                  title: 'Terjadi Kesalahan',
                  message: 'Gagal memuat barang: $error',
                  icon: Icons.error_outline,
                ),
              ),
            ],
          ),
          data: (listings) {
            // PERBAIKAN: Gunakan EmptyState jika data kosong
            if (listings.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: EmptyState(
                      title: 'Belum Ada Barang',
                      message: 'Mulai hasilkan pendapatan dengan mendaftarkan barang pertama Anda.',
                      icon: Icons.inventory_2_outlined,
                      buttonText: 'Daftarkan Barang',
                      onButtonPressed: () => context.go('/listing/create'),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: listings.length,
              itemBuilder: (context, index) {
                final item = listings[index];
                return _ListingCard(
                  item: item,
                  onEdit: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Edit fitur akan segera tersedia')),
                    );
                  },
                  onDelete: () => _showDeleteDialog(context, ref, item, ownerId),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    Item item,
    String ownerId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Barang?'),
        content: Text('Apakah Anda yakin ingin menghapus "${item.title}"?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ListingService.delete(item.id);
                ref.invalidate(listing.myListingsNotifierProvider(ownerId));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Barang berhasil dihapus')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

class _ListingCard extends ConsumerWidget {
  final Item item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ListingCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onLongPress: () => _showOptionsBottomSheet(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: item.imageUrls.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: item.imageUrls.first,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported),
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.condition.name, // Mengambil string nama enum
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp ${item.pricePerDay.toStringAsFixed(0)}/hari',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    // Status Toggle + Badge
                    Row(
                      children: [
                        if (item.status == ItemStatus.rented)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Sedang Disewa',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else
                          _StatusToggle(
                            item: item,
                            onStatusChanged: () {},
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Barang'),
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Hapus Barang', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _StatusToggle extends ConsumerWidget {
  final Item item;
  final VoidCallback onStatusChanged;

  const _StatusToggle({
    required this.item,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAvailable = item.status == ItemStatus.available;

    return SizedBox(
      height: 32,
      child: Switch(
        value: isAvailable,
        activeColor: Theme.of(context).primaryColor,
        onChanged: (value) async {
          final newStatus =
              value ? ItemStatus.available : ItemStatus.unavailable;
          try {
            await ListingService.updateStatus(item.id, newStatus);
            final authState = ref.read(authProvider).valueOrNull;
            if (authState?.user != null) {
              ref.invalidate(listing.myListingsNotifierProvider(authState!.user!.id));
            }
            onStatusChanged();
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Gagal update status: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }
}