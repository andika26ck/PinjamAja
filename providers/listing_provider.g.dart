// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$categoriesHash() => r'36651e516b74eb254f8f2e154dc5da42f573b94f';

/// Fetch semua kategori barang.
///
/// Copied from [categories].
@ProviderFor(categories)
final categoriesProvider = AutoDisposeFutureProvider<List<Category>>.internal(
  categories,
  name: r'categoriesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$categoriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CategoriesRef = AutoDisposeFutureProviderRef<List<Category>>;
String _$itemDetailHash() => r'2eb45064d2d7c77567fbadbef146b891a140d315';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Fetch detail item berdasarkan ID.
///
/// Copied from [itemDetail].
@ProviderFor(itemDetail)
const itemDetailProvider = ItemDetailFamily();

/// Fetch detail item berdasarkan ID.
///
/// Copied from [itemDetail].
class ItemDetailFamily extends Family<AsyncValue<Item>> {
  /// Fetch detail item berdasarkan ID.
  ///
  /// Copied from [itemDetail].
  const ItemDetailFamily();

  /// Fetch detail item berdasarkan ID.
  ///
  /// Copied from [itemDetail].
  ItemDetailProvider call(
    String itemId,
  ) {
    return ItemDetailProvider(
      itemId,
    );
  }

  @override
  ItemDetailProvider getProviderOverride(
    covariant ItemDetailProvider provider,
  ) {
    return call(
      provider.itemId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'itemDetailProvider';
}

/// Fetch detail item berdasarkan ID.
///
/// Copied from [itemDetail].
class ItemDetailProvider extends AutoDisposeFutureProvider<Item> {
  /// Fetch detail item berdasarkan ID.
  ///
  /// Copied from [itemDetail].
  ItemDetailProvider(
    String itemId,
  ) : this._internal(
          (ref) => itemDetail(
            ref as ItemDetailRef,
            itemId,
          ),
          from: itemDetailProvider,
          name: r'itemDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$itemDetailHash,
          dependencies: ItemDetailFamily._dependencies,
          allTransitiveDependencies:
              ItemDetailFamily._allTransitiveDependencies,
          itemId: itemId,
        );

  ItemDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.itemId,
  }) : super.internal();

  final String itemId;

  @override
  Override overrideWith(
    FutureOr<Item> Function(ItemDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ItemDetailProvider._internal(
        (ref) => create(ref as ItemDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        itemId: itemId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Item> createElement() {
    return _ItemDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ItemDetailProvider && other.itemId == itemId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, itemId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ItemDetailRef on AutoDisposeFutureProviderRef<Item> {
  /// The parameter `itemId` of this provider.
  String get itemId;
}

class _ItemDetailProviderElement extends AutoDisposeFutureProviderElement<Item>
    with ItemDetailRef {
  _ItemDetailProviderElement(super.provider);

  @override
  String get itemId => (origin as ItemDetailProvider).itemId;
}

String _$itemReviewsHash() => r'a8f9cb441f7e8470d58e3f8c13d94b5d884d2d2b';

/// Fetch reviews untuk item tertentu.
///
/// Copied from [itemReviews].
@ProviderFor(itemReviews)
const itemReviewsProvider = ItemReviewsFamily();

/// Fetch reviews untuk item tertentu.
///
/// Copied from [itemReviews].
class ItemReviewsFamily extends Family<AsyncValue<List<Review>>> {
  /// Fetch reviews untuk item tertentu.
  ///
  /// Copied from [itemReviews].
  const ItemReviewsFamily();

  /// Fetch reviews untuk item tertentu.
  ///
  /// Copied from [itemReviews].
  ItemReviewsProvider call(
    String itemId,
  ) {
    return ItemReviewsProvider(
      itemId,
    );
  }

  @override
  ItemReviewsProvider getProviderOverride(
    covariant ItemReviewsProvider provider,
  ) {
    return call(
      provider.itemId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'itemReviewsProvider';
}

/// Fetch reviews untuk item tertentu.
///
/// Copied from [itemReviews].
class ItemReviewsProvider extends AutoDisposeFutureProvider<List<Review>> {
  /// Fetch reviews untuk item tertentu.
  ///
  /// Copied from [itemReviews].
  ItemReviewsProvider(
    String itemId,
  ) : this._internal(
          (ref) => itemReviews(
            ref as ItemReviewsRef,
            itemId,
          ),
          from: itemReviewsProvider,
          name: r'itemReviewsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$itemReviewsHash,
          dependencies: ItemReviewsFamily._dependencies,
          allTransitiveDependencies:
              ItemReviewsFamily._allTransitiveDependencies,
          itemId: itemId,
        );

  ItemReviewsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.itemId,
  }) : super.internal();

  final String itemId;

  @override
  Override overrideWith(
    FutureOr<List<Review>> Function(ItemReviewsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ItemReviewsProvider._internal(
        (ref) => create(ref as ItemReviewsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        itemId: itemId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Review>> createElement() {
    return _ItemReviewsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ItemReviewsProvider && other.itemId == itemId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, itemId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ItemReviewsRef on AutoDisposeFutureProviderRef<List<Review>> {
  /// The parameter `itemId` of this provider.
  String get itemId;
}

class _ItemReviewsProviderElement
    extends AutoDisposeFutureProviderElement<List<Review>> with ItemReviewsRef {
  _ItemReviewsProviderElement(super.provider);

  @override
  String get itemId => (origin as ItemReviewsProvider).itemId;
}

String _$itemsNotifierHash() => r'3e178c1114263d11399ab05cfe65d3f2f763fd11';

/// Fetch items dengan pagination (infinite scroll).
///
/// Copied from [ItemsNotifier].
@ProviderFor(ItemsNotifier)
final itemsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<ItemsNotifier, List<Item>>.internal(
  ItemsNotifier.new,
  name: r'itemsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$itemsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ItemsNotifier = AutoDisposeAsyncNotifier<List<Item>>;
String _$searchNotifierHash() => r'd7e5a104006829e2986cea916026c346225bde1a';

abstract class _$SearchNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<Item>> {
  late final String query;
  late final String? categoryId;
  late final double? minPrice;
  late final double? maxPrice;
  late final String? location;
  late final DateTime? availableFrom;
  late final DateTime? availableTo;

  FutureOr<List<Item>> build({
    String query = '',
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    String? location,
    DateTime? availableFrom,
    DateTime? availableTo,
  });
}

/// Search items dengan query dan filters.
///
/// Copied from [SearchNotifier].
@ProviderFor(SearchNotifier)
const searchNotifierProvider = SearchNotifierFamily();

/// Search items dengan query dan filters.
///
/// Copied from [SearchNotifier].
class SearchNotifierFamily extends Family<AsyncValue<List<Item>>> {
  /// Search items dengan query dan filters.
  ///
  /// Copied from [SearchNotifier].
  const SearchNotifierFamily();

  /// Search items dengan query dan filters.
  ///
  /// Copied from [SearchNotifier].
  SearchNotifierProvider call({
    String query = '',
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    String? location,
    DateTime? availableFrom,
    DateTime? availableTo,
  }) {
    return SearchNotifierProvider(
      query: query,
      categoryId: categoryId,
      minPrice: minPrice,
      maxPrice: maxPrice,
      location: location,
      availableFrom: availableFrom,
      availableTo: availableTo,
    );
  }

  @override
  SearchNotifierProvider getProviderOverride(
    covariant SearchNotifierProvider provider,
  ) {
    return call(
      query: provider.query,
      categoryId: provider.categoryId,
      minPrice: provider.minPrice,
      maxPrice: provider.maxPrice,
      location: provider.location,
      availableFrom: provider.availableFrom,
      availableTo: provider.availableTo,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'searchNotifierProvider';
}

/// Search items dengan query dan filters.
///
/// Copied from [SearchNotifier].
class SearchNotifierProvider
    extends AutoDisposeAsyncNotifierProviderImpl<SearchNotifier, List<Item>> {
  /// Search items dengan query dan filters.
  ///
  /// Copied from [SearchNotifier].
  SearchNotifierProvider({
    String query = '',
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    String? location,
    DateTime? availableFrom,
    DateTime? availableTo,
  }) : this._internal(
          () => SearchNotifier()
            ..query = query
            ..categoryId = categoryId
            ..minPrice = minPrice
            ..maxPrice = maxPrice
            ..location = location
            ..availableFrom = availableFrom
            ..availableTo = availableTo,
          from: searchNotifierProvider,
          name: r'searchNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$searchNotifierHash,
          dependencies: SearchNotifierFamily._dependencies,
          allTransitiveDependencies:
              SearchNotifierFamily._allTransitiveDependencies,
          query: query,
          categoryId: categoryId,
          minPrice: minPrice,
          maxPrice: maxPrice,
          location: location,
          availableFrom: availableFrom,
          availableTo: availableTo,
        );

  SearchNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
    required this.categoryId,
    required this.minPrice,
    required this.maxPrice,
    required this.location,
    required this.availableFrom,
    required this.availableTo,
  }) : super.internal();

  final String query;
  final String? categoryId;
  final double? minPrice;
  final double? maxPrice;
  final String? location;
  final DateTime? availableFrom;
  final DateTime? availableTo;

  @override
  FutureOr<List<Item>> runNotifierBuild(
    covariant SearchNotifier notifier,
  ) {
    return notifier.build(
      query: query,
      categoryId: categoryId,
      minPrice: minPrice,
      maxPrice: maxPrice,
      location: location,
      availableFrom: availableFrom,
      availableTo: availableTo,
    );
  }

  @override
  Override overrideWith(SearchNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: SearchNotifierProvider._internal(
        () => create()
          ..query = query
          ..categoryId = categoryId
          ..minPrice = minPrice
          ..maxPrice = maxPrice
          ..location = location
          ..availableFrom = availableFrom
          ..availableTo = availableTo,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
        categoryId: categoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        location: location,
        availableFrom: availableFrom,
        availableTo: availableTo,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<SearchNotifier, List<Item>>
      createElement() {
    return _SearchNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchNotifierProvider &&
        other.query == query &&
        other.categoryId == categoryId &&
        other.minPrice == minPrice &&
        other.maxPrice == maxPrice &&
        other.location == location &&
        other.availableFrom == availableFrom &&
        other.availableTo == availableTo;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);
    hash = _SystemHash.combine(hash, categoryId.hashCode);
    hash = _SystemHash.combine(hash, minPrice.hashCode);
    hash = _SystemHash.combine(hash, maxPrice.hashCode);
    hash = _SystemHash.combine(hash, location.hashCode);
    hash = _SystemHash.combine(hash, availableFrom.hashCode);
    hash = _SystemHash.combine(hash, availableTo.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin SearchNotifierRef on AutoDisposeAsyncNotifierProviderRef<List<Item>> {
  /// The parameter `query` of this provider.
  String get query;

  /// The parameter `categoryId` of this provider.
  String? get categoryId;

  /// The parameter `minPrice` of this provider.
  double? get minPrice;

  /// The parameter `maxPrice` of this provider.
  double? get maxPrice;

  /// The parameter `location` of this provider.
  String? get location;

  /// The parameter `availableFrom` of this provider.
  DateTime? get availableFrom;

  /// The parameter `availableTo` of this provider.
  DateTime? get availableTo;
}

class _SearchNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<SearchNotifier, List<Item>>
    with SearchNotifierRef {
  _SearchNotifierProviderElement(super.provider);

  @override
  String get query => (origin as SearchNotifierProvider).query;
  @override
  String? get categoryId => (origin as SearchNotifierProvider).categoryId;
  @override
  double? get minPrice => (origin as SearchNotifierProvider).minPrice;
  @override
  double? get maxPrice => (origin as SearchNotifierProvider).maxPrice;
  @override
  String? get location => (origin as SearchNotifierProvider).location;
  @override
  DateTime? get availableFrom =>
      (origin as SearchNotifierProvider).availableFrom;
  @override
  DateTime? get availableTo => (origin as SearchNotifierProvider).availableTo;
}

String _$categoryItemsNotifierHash() =>
    r'7e447871a344d151f417bb09c5aff173904c53c3';

abstract class _$CategoryItemsNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<Item>> {
  late final String categoryId;

  FutureOr<List<Item>> build(
    String categoryId,
  );
}

/// Fetch items per kategori.
///
/// Copied from [CategoryItemsNotifier].
@ProviderFor(CategoryItemsNotifier)
const categoryItemsNotifierProvider = CategoryItemsNotifierFamily();

/// Fetch items per kategori.
///
/// Copied from [CategoryItemsNotifier].
class CategoryItemsNotifierFamily extends Family<AsyncValue<List<Item>>> {
  /// Fetch items per kategori.
  ///
  /// Copied from [CategoryItemsNotifier].
  const CategoryItemsNotifierFamily();

  /// Fetch items per kategori.
  ///
  /// Copied from [CategoryItemsNotifier].
  CategoryItemsNotifierProvider call(
    String categoryId,
  ) {
    return CategoryItemsNotifierProvider(
      categoryId,
    );
  }

  @override
  CategoryItemsNotifierProvider getProviderOverride(
    covariant CategoryItemsNotifierProvider provider,
  ) {
    return call(
      provider.categoryId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'categoryItemsNotifierProvider';
}

/// Fetch items per kategori.
///
/// Copied from [CategoryItemsNotifier].
class CategoryItemsNotifierProvider
    extends AutoDisposeAsyncNotifierProviderImpl<CategoryItemsNotifier,
        List<Item>> {
  /// Fetch items per kategori.
  ///
  /// Copied from [CategoryItemsNotifier].
  CategoryItemsNotifierProvider(
    String categoryId,
  ) : this._internal(
          () => CategoryItemsNotifier()..categoryId = categoryId,
          from: categoryItemsNotifierProvider,
          name: r'categoryItemsNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$categoryItemsNotifierHash,
          dependencies: CategoryItemsNotifierFamily._dependencies,
          allTransitiveDependencies:
              CategoryItemsNotifierFamily._allTransitiveDependencies,
          categoryId: categoryId,
        );

  CategoryItemsNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.categoryId,
  }) : super.internal();

  final String categoryId;

  @override
  FutureOr<List<Item>> runNotifierBuild(
    covariant CategoryItemsNotifier notifier,
  ) {
    return notifier.build(
      categoryId,
    );
  }

  @override
  Override overrideWith(CategoryItemsNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: CategoryItemsNotifierProvider._internal(
        () => create()..categoryId = categoryId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        categoryId: categoryId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<CategoryItemsNotifier, List<Item>>
      createElement() {
    return _CategoryItemsNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryItemsNotifierProvider &&
        other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, categoryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CategoryItemsNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<List<Item>> {
  /// The parameter `categoryId` of this provider.
  String get categoryId;
}

class _CategoryItemsNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<CategoryItemsNotifier,
        List<Item>> with CategoryItemsNotifierRef {
  _CategoryItemsNotifierProviderElement(super.provider);

  @override
  String get categoryId => (origin as CategoryItemsNotifierProvider).categoryId;
}

String _$myListingsNotifierHash() =>
    r'ebfe56dc88403f293a5e31f16e44e540179880b1';

abstract class _$MyListingsNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<Item>> {
  late final String ownerId;

  FutureOr<List<Item>> build(
    String ownerId,
  );
}

/// Fetch barang milik owner tertentu (MyListings).
///
/// Copied from [MyListingsNotifier].
@ProviderFor(MyListingsNotifier)
const myListingsNotifierProvider = MyListingsNotifierFamily();

/// Fetch barang milik owner tertentu (MyListings).
///
/// Copied from [MyListingsNotifier].
class MyListingsNotifierFamily extends Family<AsyncValue<List<Item>>> {
  /// Fetch barang milik owner tertentu (MyListings).
  ///
  /// Copied from [MyListingsNotifier].
  const MyListingsNotifierFamily();

  /// Fetch barang milik owner tertentu (MyListings).
  ///
  /// Copied from [MyListingsNotifier].
  MyListingsNotifierProvider call(
    String ownerId,
  ) {
    return MyListingsNotifierProvider(
      ownerId,
    );
  }

  @override
  MyListingsNotifierProvider getProviderOverride(
    covariant MyListingsNotifierProvider provider,
  ) {
    return call(
      provider.ownerId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'myListingsNotifierProvider';
}

/// Fetch barang milik owner tertentu (MyListings).
///
/// Copied from [MyListingsNotifier].
class MyListingsNotifierProvider extends AutoDisposeAsyncNotifierProviderImpl<
    MyListingsNotifier, List<Item>> {
  /// Fetch barang milik owner tertentu (MyListings).
  ///
  /// Copied from [MyListingsNotifier].
  MyListingsNotifierProvider(
    String ownerId,
  ) : this._internal(
          () => MyListingsNotifier()..ownerId = ownerId,
          from: myListingsNotifierProvider,
          name: r'myListingsNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$myListingsNotifierHash,
          dependencies: MyListingsNotifierFamily._dependencies,
          allTransitiveDependencies:
              MyListingsNotifierFamily._allTransitiveDependencies,
          ownerId: ownerId,
        );

  MyListingsNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.ownerId,
  }) : super.internal();

  final String ownerId;

  @override
  FutureOr<List<Item>> runNotifierBuild(
    covariant MyListingsNotifier notifier,
  ) {
    return notifier.build(
      ownerId,
    );
  }

  @override
  Override overrideWith(MyListingsNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: MyListingsNotifierProvider._internal(
        () => create()..ownerId = ownerId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        ownerId: ownerId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<MyListingsNotifier, List<Item>>
      createElement() {
    return _MyListingsNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MyListingsNotifierProvider && other.ownerId == ownerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, ownerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MyListingsNotifierRef on AutoDisposeAsyncNotifierProviderRef<List<Item>> {
  /// The parameter `ownerId` of this provider.
  String get ownerId;
}

class _MyListingsNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<MyListingsNotifier,
        List<Item>> with MyListingsNotifierRef {
  _MyListingsNotifierProviderElement(super.provider);

  @override
  String get ownerId => (origin as MyListingsNotifierProvider).ownerId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
