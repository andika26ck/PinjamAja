import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/category.dart';
import '../models/item.dart';
import '../models/review.dart';
import '../services/listing_service.dart';

part 'listing_provider.g.dart';

// NOTE: file ini memakai riverpod_annotation — jalankan
//   dart run build_runner build --delete-conflicting-outputs
// untuk men-generate `listing_provider.g.dart`.

/// Fetch semua kategori barang.
@riverpod
Future<List<Category>> categories(CategoriesRef ref) {
  return ListingService.getCategories();
}

/// Fetch items dengan pagination (infinite scroll).
@riverpod
class ItemsNotifier extends _$ItemsNotifier {
  @override
  Future<List<Item>> build() {
    return ListingService.getAll(page: 0, limit: 10);
  }

  /// Load halaman berikutnya (untuk infinite scroll).
  Future<void> loadMore() async {
    final currentItems = state.valueOrNull ?? [];
    final nextPage = (currentItems.length / 10).ceil();
    
    try {
      final newItems = await ListingService.getAll(page: nextPage, limit: 10);
      if (newItems.isNotEmpty) {
        state = AsyncValue.data([...currentItems, ...newItems]);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Search items dengan query dan filters.
@riverpod
class SearchNotifier extends _$SearchNotifier {
  @override
  Future<List<Item>> build({
    String query = '',
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    String? location,
    DateTime? availableFrom,
    DateTime? availableTo,
  }) {
    return ListingService.search(
      query: query.isEmpty ? null : query,
      categoryId: categoryId,
      minPrice: minPrice,
      maxPrice: maxPrice,
      location: location,
      availableFrom: availableFrom,
      availableTo: availableTo,
      page: 0,
      limit: 10,
    );
  }

  /// Load halaman berikutnya (untuk infinite scroll).
  Future<void> loadMore() async {
    final currentItems = state.valueOrNull ?? [];
    final nextPage = (currentItems.length / 10).ceil();
    
    try {
      final newItems = await ListingService.search(
        query: query.isEmpty ? null : query,
        categoryId: categoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        location: location,
        availableFrom: availableFrom,
        availableTo: availableTo,
        page: nextPage,
        limit: 10,
      );
      if (newItems.isNotEmpty) {
        state = AsyncValue.data([...currentItems, ...newItems]);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Fetch detail item berdasarkan ID.
@riverpod
Future<Item> itemDetail(ItemDetailRef ref, String itemId) {
  return ListingService.getById(itemId);
}

/// Fetch reviews untuk item tertentu.
@riverpod
Future<List<Review>> itemReviews(ItemReviewsRef ref, String itemId) {
  return ListingService.getReviews(itemId);
}

/// Fetch items per kategori.
@riverpod
class CategoryItemsNotifier extends _$CategoryItemsNotifier {
  @override
  Future<List<Item>> build(String categoryId) {
    return ListingService.getByCategory(categoryId, page: 0, limit: 10);
  }

  /// Load halaman berikutnya.
  Future<void> loadMore() async {
    final currentItems = state.valueOrNull ?? [];
    final nextPage = (currentItems.length / 10).ceil();
    
    try {
      final newItems = await ListingService.getByCategory(
        categoryId,
        page: nextPage,
        limit: 10,
      );
      if (newItems.isNotEmpty) {
        state = AsyncValue.data([...currentItems, ...newItems]);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Fetch barang milik owner tertentu (MyListings).
@riverpod
class MyListingsNotifier extends _$MyListingsNotifier {
  @override
  Future<List<Item>> build(String ownerId) {
    return ListingService.getMyListings(ownerId);
  }

  /// Refresh daftar barang (untuk setelah create/update/delete).
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final items = await ListingService.getMyListings(ownerId);
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Update status item dalam list.
  void updateItemStatus(String itemId, ItemStatus newStatus) {
    final items = state.valueOrNull ?? [];
    final index = items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      final updatedItem = items[index].copyWith(status: newStatus);
      state = AsyncValue.data([
        ...items.sublist(0, index),
        updatedItem,
        ...items.sublist(index + 1),
      ]);
    }
  }
}
