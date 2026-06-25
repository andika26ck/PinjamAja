// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bookingDetailHash() => r'bf5ef53f6fe2d1756a10c172a33dfd05fd78dfe8';

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

/// See also [bookingDetail].
@ProviderFor(bookingDetail)
const bookingDetailProvider = BookingDetailFamily();

/// See also [bookingDetail].
class BookingDetailFamily extends Family<AsyncValue<Booking>> {
  /// See also [bookingDetail].
  const BookingDetailFamily();

  /// See also [bookingDetail].
  BookingDetailProvider call(
    String bookingId,
  ) {
    return BookingDetailProvider(
      bookingId,
    );
  }

  @override
  BookingDetailProvider getProviderOverride(
    covariant BookingDetailProvider provider,
  ) {
    return call(
      provider.bookingId,
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
  String? get name => r'bookingDetailProvider';
}

/// See also [bookingDetail].
class BookingDetailProvider extends AutoDisposeFutureProvider<Booking> {
  /// See also [bookingDetail].
  BookingDetailProvider(
    String bookingId,
  ) : this._internal(
          (ref) => bookingDetail(
            ref as BookingDetailRef,
            bookingId,
          ),
          from: bookingDetailProvider,
          name: r'bookingDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$bookingDetailHash,
          dependencies: BookingDetailFamily._dependencies,
          allTransitiveDependencies:
              BookingDetailFamily._allTransitiveDependencies,
          bookingId: bookingId,
        );

  BookingDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.bookingId,
  }) : super.internal();

  final String bookingId;

  @override
  Override overrideWith(
    FutureOr<Booking> Function(BookingDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BookingDetailProvider._internal(
        (ref) => create(ref as BookingDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        bookingId: bookingId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Booking> createElement() {
    return _BookingDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BookingDetailProvider && other.bookingId == bookingId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, bookingId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin BookingDetailRef on AutoDisposeFutureProviderRef<Booking> {
  /// The parameter `bookingId` of this provider.
  String get bookingId;
}

class _BookingDetailProviderElement
    extends AutoDisposeFutureProviderElement<Booking> with BookingDetailRef {
  _BookingDetailProviderElement(super.provider);

  @override
  String get bookingId => (origin as BookingDetailProvider).bookingId;
}

String _$renterBookingsHash() => r'eec7a13d204ee08d3f0ba7fd7829614eca360b97';

abstract class _$RenterBookings
    extends BuildlessAutoDisposeAsyncNotifier<List<Booking>> {
  late final String renterId;

  FutureOr<List<Booking>> build(
    String renterId,
  );
}

/// See also [RenterBookings].
@ProviderFor(RenterBookings)
const renterBookingsProvider = RenterBookingsFamily();

/// See also [RenterBookings].
class RenterBookingsFamily extends Family<AsyncValue<List<Booking>>> {
  /// See also [RenterBookings].
  const RenterBookingsFamily();

  /// See also [RenterBookings].
  RenterBookingsProvider call(
    String renterId,
  ) {
    return RenterBookingsProvider(
      renterId,
    );
  }

  @override
  RenterBookingsProvider getProviderOverride(
    covariant RenterBookingsProvider provider,
  ) {
    return call(
      provider.renterId,
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
  String? get name => r'renterBookingsProvider';
}

/// See also [RenterBookings].
class RenterBookingsProvider extends AutoDisposeAsyncNotifierProviderImpl<
    RenterBookings, List<Booking>> {
  /// See also [RenterBookings].
  RenterBookingsProvider(
    String renterId,
  ) : this._internal(
          () => RenterBookings()..renterId = renterId,
          from: renterBookingsProvider,
          name: r'renterBookingsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$renterBookingsHash,
          dependencies: RenterBookingsFamily._dependencies,
          allTransitiveDependencies:
              RenterBookingsFamily._allTransitiveDependencies,
          renterId: renterId,
        );

  RenterBookingsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.renterId,
  }) : super.internal();

  final String renterId;

  @override
  FutureOr<List<Booking>> runNotifierBuild(
    covariant RenterBookings notifier,
  ) {
    return notifier.build(
      renterId,
    );
  }

  @override
  Override overrideWith(RenterBookings Function() create) {
    return ProviderOverride(
      origin: this,
      override: RenterBookingsProvider._internal(
        () => create()..renterId = renterId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        renterId: renterId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<RenterBookings, List<Booking>>
      createElement() {
    return _RenterBookingsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RenterBookingsProvider && other.renterId == renterId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, renterId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin RenterBookingsRef on AutoDisposeAsyncNotifierProviderRef<List<Booking>> {
  /// The parameter `renterId` of this provider.
  String get renterId;
}

class _RenterBookingsProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<RenterBookings,
        List<Booking>> with RenterBookingsRef {
  _RenterBookingsProviderElement(super.provider);

  @override
  String get renterId => (origin as RenterBookingsProvider).renterId;
}

String _$ownerBookingsHash() => r'f214459e0fd04c6ad9104031c4df5e0a1de5d709';

abstract class _$OwnerBookings
    extends BuildlessAutoDisposeAsyncNotifier<List<Booking>> {
  late final String ownerId;

  FutureOr<List<Booking>> build(
    String ownerId,
  );
}

/// See also [OwnerBookings].
@ProviderFor(OwnerBookings)
const ownerBookingsProvider = OwnerBookingsFamily();

/// See also [OwnerBookings].
class OwnerBookingsFamily extends Family<AsyncValue<List<Booking>>> {
  /// See also [OwnerBookings].
  const OwnerBookingsFamily();

  /// See also [OwnerBookings].
  OwnerBookingsProvider call(
    String ownerId,
  ) {
    return OwnerBookingsProvider(
      ownerId,
    );
  }

  @override
  OwnerBookingsProvider getProviderOverride(
    covariant OwnerBookingsProvider provider,
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
  String? get name => r'ownerBookingsProvider';
}

/// See also [OwnerBookings].
class OwnerBookingsProvider
    extends AutoDisposeAsyncNotifierProviderImpl<OwnerBookings, List<Booking>> {
  /// See also [OwnerBookings].
  OwnerBookingsProvider(
    String ownerId,
  ) : this._internal(
          () => OwnerBookings()..ownerId = ownerId,
          from: ownerBookingsProvider,
          name: r'ownerBookingsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$ownerBookingsHash,
          dependencies: OwnerBookingsFamily._dependencies,
          allTransitiveDependencies:
              OwnerBookingsFamily._allTransitiveDependencies,
          ownerId: ownerId,
        );

  OwnerBookingsProvider._internal(
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
  FutureOr<List<Booking>> runNotifierBuild(
    covariant OwnerBookings notifier,
  ) {
    return notifier.build(
      ownerId,
    );
  }

  @override
  Override overrideWith(OwnerBookings Function() create) {
    return ProviderOverride(
      origin: this,
      override: OwnerBookingsProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<OwnerBookings, List<Booking>>
      createElement() {
    return _OwnerBookingsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OwnerBookingsProvider && other.ownerId == ownerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, ownerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin OwnerBookingsRef on AutoDisposeAsyncNotifierProviderRef<List<Booking>> {
  /// The parameter `ownerId` of this provider.
  String get ownerId;
}

class _OwnerBookingsProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<OwnerBookings,
        List<Booking>> with OwnerBookingsRef {
  _OwnerBookingsProviderElement(super.provider);

  @override
  String get ownerId => (origin as OwnerBookingsProvider).ownerId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
