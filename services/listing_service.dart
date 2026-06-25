import '../core/config/supabase_config.dart';
import '../core/errors/app_exception.dart';
import '../models/category.dart';
import '../models/item.dart';
import '../models/review.dart';

/// Service layer untuk manage listing (barang rental).
/// Semua query ke tabel items, categories, reviews lewat sini.
class ListingService {
  const ListingService._();

  static final _client = SupabaseConfig.client;

  /// Ambil semua item dengan pagination.
  static Future<List<Item>> getAll({int page = 0, int limit = 10}) async {
    try {
      final offset = page * limit;
      final response = await _client
          .from('items')
          .select(
            '''
            id, owner_id, category_id, title, description, 
            price_per_day, deposit_amount, image_urls, condition, 
            status, location, latitude, longitude, blocked_dates,
            rating, total_reviews, created_at
            '''
          )
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((json) => Item.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw AppException(
        message: 'Gagal memuat daftar barang. Coba lagi.',
        originalError: e,
      );
    }
  }

  /// Ambil item berdasarkan kategori.
  static Future<List<Item>> getByCategory(
    String categoryId, {
    int page = 0,
    int limit = 10,
  }) async {
    try {
      final offset = page * limit;
      final response = await _client
          .from('items')
          .select(
            '''
            id, owner_id, category_id, title, description, 
            price_per_day, deposit_amount, image_urls, condition, 
            status, location, latitude, longitude, blocked_dates,
            rating, total_reviews, created_at
            '''
          )
          .eq('category_id', categoryId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((json) => Item.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw AppException(
        message: 'Gagal memuat barang kategori. Coba lagi.',
        originalError: e,
      );
    }
  }

  /// Ambil detail item berdasarkan ID.
  static Future<Item> getById(String itemId) async {
    try {
      final response = await _client
          .from('items')
          .select(
            '''
            id, owner_id, category_id, title, description, 
            price_per_day, deposit_amount, image_urls, condition, 
            status, location, latitude, longitude, blocked_dates,
            rating, total_reviews, created_at
            '''
          )
          .eq('id', itemId)
          .single();

      return Item.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw AppException(
        message: 'Gagal memuat detail barang. Coba lagi.',
        originalError: e,
      );
    }
  }

  /// Search item dengan berbagai filter.
  static Future<List<Item>> search({
    String? query,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    String? location,
    DateTime? availableFrom,
    DateTime? availableTo,
    int page = 0,
    int limit = 10,
  }) async {
    try {
      final offset = page * limit;
      var queryBuilder = _client
          .from('items')
          .select(
            '''
            id, owner_id, category_id, title, description, 
            price_per_day, deposit_amount, image_urls, condition, 
            status, location, latitude, longitude, blocked_dates,
            rating, total_reviews, created_at
            '''
          );

      // Filter by query (judul atau deskripsi)
      if (query != null && query.isNotEmpty) {
        queryBuilder = queryBuilder.or(
          'title.ilike.%$query%,description.ilike.%$query%',
        );
      }

      // Filter by kategori
      if (categoryId != null && categoryId.isNotEmpty) {
        queryBuilder = queryBuilder.eq('category_id', categoryId);
      }

      // Filter by harga
      if (minPrice != null) {
        queryBuilder = queryBuilder.gte('price_per_day', minPrice);
      }
      if (maxPrice != null) {
        queryBuilder = queryBuilder.lte('price_per_day', maxPrice);
      }

      // Filter by lokasi (partial match)
      if (location != null && location.isNotEmpty) {
        queryBuilder = queryBuilder.ilike('location', '%$location%');
      }

      final response = await queryBuilder
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final items = (response as List)
          .map((json) => Item.fromJson(json as Map<String, dynamic>))
          .toList();

      // Filter by availability dates (post-query filter)
      if (availableFrom != null || availableTo != null) {
        return items.where((item) {
          for (final blockedDate in item.blockedDates) {
            if (availableFrom != null && blockedDate.isBefore(availableFrom)) {
              continue;
            }
            if (availableTo != null && blockedDate.isAfter(availableTo)) {
              continue;
            }
            // Blocked date dalam range yang diminta
            if (availableFrom == null || availableTo == null) {
              return false;
            }
            if (blockedDate.isAfter(availableFrom) &&
                blockedDate.isBefore(availableTo)) {
              return false;
            }
          }
          return true;
        }).toList();
      }

      return items;
    } catch (e) {
      throw AppException(
        message: 'Gagal mencari barang. Coba lagi.',
        originalError: e,
      );
    }
  }

  /// Ambil ulasan item dengan join ke tabel profiles.
  static Future<List<Review>> getReviews(
    String itemId, {
    int limit = 10,
  }) async {
    try {
      // Query dengan join untuk nama dan avatar reviewer
      final response = await _client
          .from('reviews')
          .select(
            '''
            id, booking_id, item_id, reviewer_id, rating, comment, created_at,
            profiles!reviewer_id(name, avatar_url)
            '''
          )
          .eq('item_id', itemId)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List).map((json) {
        final data = json as Map<String, dynamic>;
        final profile = data['profiles'] as Map<String, dynamic>?;
        return Review.fromJson({
          ...data,
          'reviewer_name': profile?['name'] ?? 'Pengguna',
          'reviewer_avatar_url': profile?['avatar_url'],
        });
      }).toList();
    } catch (e) {
      throw AppException(
        message: 'Gagal memuat ulasan. Coba lagi.',
        originalError: e,
      );
    }
  }

  /// Ambil semua kategori.
  static Future<List<Category>> getCategories() async {
    try {
      final response = await _client
          .from('categories')
          .select('id, name, icon_url, slug, item_count')
          .order('name', ascending: true);

      return (response as List)
          .map((json) => Category.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw AppException(
        message: 'Gagal memuat kategori. Coba lagi.',
        originalError: e,
      );
    }
  }

  /// Buat item barang baru.
  static Future<Item> create(Map<String, dynamic> data) async {
    try {
      final response = await _client
          .from('items')
          .insert(data)
          .select(
            '''
            id, owner_id, category_id, title, description, 
            price_per_day, deposit_amount, image_urls, condition, 
            status, location, latitude, longitude, blocked_dates,
            rating, total_reviews, created_at
            '''
          )
          .single();

      return Item.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw AppException(
        message: 'Gagal membuat barang baru. Coba lagi.',
        originalError: e,
      );
    }
  }

  /// Update item barang.
  static Future<Item> update(String itemId, Map<String, dynamic> data) async {
    try {
      final response = await _client
          .from('items')
          .update(data)
          .eq('id', itemId)
          .select(
            '''
            id, owner_id, category_id, title, description, 
            price_per_day, deposit_amount, image_urls, condition, 
            status, location, latitude, longitude, blocked_dates,
            rating, total_reviews, created_at
            '''
          )
          .single();

      return Item.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw AppException(
        message: 'Gagal update barang. Coba lagi.',
        originalError: e,
      );
    }
  }

  /// Hapus item barang.
  static Future<void> delete(String itemId) async {
    try {
      await _client.from('items').delete().eq('id', itemId);
    } catch (e) {
      throw AppException(
        message: 'Gagal hapus barang. Coba lagi.',
        originalError: e,
      );
    }
  }

  /// Update status item (available, rented, unavailable).
  static Future<void> updateStatus(String itemId, ItemStatus newStatus) async {
    try {
      await _client
          .from('items')
          .update({'status': newStatus.toDb()})
          .eq('id', itemId);
    } catch (e) {
      throw AppException(
        message: 'Gagal update status barang. Coba lagi.',
        originalError: e,
      );
    }
  }

  /// Update tanggal blocked item.
  static Future<void> updateBlockedDates(
    String itemId,
    List<DateTime> dates,
  ) async {
    try {
      final dateStrings =
          dates.map((d) => d.toIso8601String().split('T').first).toList();
      await _client
          .from('items')
          .update({'blocked_dates': dateStrings})
          .eq('id', itemId);
    } catch (e) {
      throw AppException(
        message: 'Gagal update tanggal blocked. Coba lagi.',
        originalError: e,
      );
    }
  }

  /// Ambil semua barang milik owner tertentu.
  static Future<List<Item>> getMyListings(String ownerId) async {
    try {
      final response = await _client
          .from('items')
          .select(
            '''
            id, owner_id, category_id, title, description, 
            price_per_day, deposit_amount, image_urls, condition, 
            status, location, latitude, longitude, blocked_dates,
            rating, total_reviews, created_at
            '''
          )
          .eq('owner_id', ownerId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Item.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw AppException(
        message: 'Gagal memuat barang Anda. Coba lagi.',
        originalError: e,
      );
    }
  }
}
