import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../models/category.dart';
import '../../providers/listing_provider.dart';
import '../../widgets/items/item_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final String? categoryId;

  const SearchScreen({this.categoryId, super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late TextEditingController _searchController;
  String _query = '';
  String? _categoryId;
  double? _minPrice;
  double? _maxPrice;
  String? _location;
  DateTime? _availableFrom;
  DateTime? _availableTo;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _categoryId = widget.categoryId;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FilterBottomSheet(
        initialCategoryId: _categoryId,
        initialMinPrice: _minPrice,
        initialMaxPrice: _maxPrice,
        initialLocation: _location,
        initialAvailableFrom: _availableFrom,
        initialAvailableTo: _availableTo,
        onApply: (category, minPrice, maxPrice, location, from, to) {
          setState(() {
            _categoryId = category;
            _minPrice = minPrice;
            _maxPrice = maxPrice;
            _location = location;
            _availableFrom = from;
            _availableTo = to;
          });
          Navigator.pop(context);
        },
        onReset: () {
          setState(() {
            _categoryId = null;
            _minPrice = null;
            _maxPrice = null;
            _location = null;
            _availableFrom = null;
            _availableTo = null;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchAsync = ref.watch(
      searchNotifierProvider(
        query: _query,
        categoryId: _categoryId,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        location: _location,
        availableFrom: _availableFrom,
        availableTo: _availableTo,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text('Cari Barang'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Cari barang...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _query = '';
                                  });
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _query = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.tune),
                    onPressed: _openFilterBottomSheet,
                    tooltip: 'Filter Lanjutan',
                  ),
                ],
              ),
            ),
            // Filter Chips
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Semua chip
                  FilterChip(
                    label: const Text('Semua'),
                    selected: _categoryId == null,
                    onSelected: (selected) {
                      setState(() {
                        _categoryId = null;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  // Category chips (dummy untuk saat ini)
                  ..._getCategoryChips(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Hasil Pencarian
            Expanded(
              child: searchAsync.when(
                data: (items) {
                  if (items.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Barang tidak ditemukan',
                            style:
                                Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Coba dengan kata kunci atau filter lain',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      // Load more saat scroll ke bawah
                      if (index == items.length - 2) {
                        Future.microtask(() {
                          ref
                              .read(
                                searchNotifierProvider(
                                  query: _query,
                                  categoryId: _categoryId,
                                  minPrice: _minPrice,
                                  maxPrice: _maxPrice,
                                  location: _location,
                                  availableFrom: _availableFrom,
                                  availableTo: _availableTo,
                                ).notifier)
                              .loadMore();
                        });
                      }
                      return ItemCard(item: items[index]);
                    },
                  );
                },
                loading: () => GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                error: (error, stack) => Center(
                  child: Text(error.toString()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _getCategoryChips() {
    const categoryNames = [
      'Hobi',
      'Elektronik',
      'Outdoor',
      'Olahraga',
      'Lainnya'
    ];
    return categoryNames
        .map(
          (name) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(name),
              onSelected: (selected) {
                setState(() {
                  // TODO: set actual category id from categories provider
                });
              },
            ),
          ),
        )
        .toList();
  }
}

/// Filter bottom sheet untuk advanced filtering.
class _FilterBottomSheet extends ConsumerStatefulWidget {
  final String? initialCategoryId;
  final double? initialMinPrice;
  final double? initialMaxPrice;
  final String? initialLocation;
  final DateTime? initialAvailableFrom;
  final DateTime? initialAvailableTo;
  final Function(String?, double?, double?, String?, DateTime?, DateTime?)
      onApply;
  final VoidCallback onReset;

  const _FilterBottomSheet({
    this.initialCategoryId,
    this.initialMinPrice,
    this.initialMaxPrice,
    this.initialLocation,
    this.initialAvailableFrom,
    this.initialAvailableTo,
    required this.onApply,
    required this.onReset,
  });

  @override
  ConsumerState<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<_FilterBottomSheet> {
  late String? _categoryId;
  late double? _minPrice;
  late double? _maxPrice;
  late String? _location;
  late DateTime? _availableFrom;
  late DateTime? _availableTo;
  late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.initialCategoryId;
    _minPrice = widget.initialMinPrice;
    _maxPrice = widget.initialMaxPrice;
    _location = widget.initialLocation;
    _availableFrom = widget.initialAvailableFrom;
    _availableTo = widget.initialAvailableTo;
    _locationController = TextEditingController(text: _location ?? '');
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Filter Lanjutan',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 20),
              // Kategori Dropdown
              Text(
                'Kategori',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              categoriesAsync.when(
                data: (categories) => DropdownButtonFormField<String?>(
                  value: _categoryId,
                  decoration: InputDecoration(
                    hintText: 'Pilih kategori',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Semua Kategori'),
                    ),
                    ...categories.map((cat) => DropdownMenuItem(
                      value: cat.id,
                      child: Text(cat.name),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _categoryId = value;
                    });
                  },
                ),
                loading: () => const SizedBox(
                  height: 48,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => Text(error.toString()),
              ),
              const SizedBox(height: 16),
              // Rentang Harga
              Text(
                'Rentang Harga (Rp)',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Min',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                      ),
                      onChanged: (value) {
                        _minPrice = double.tryParse(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('-', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Max',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                      ),
                      onChanged: (value) {
                        _maxPrice = double.tryParse(value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Lokasi
              Text(
                'Lokasi',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: 'Kota/Kecamatan',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                onChanged: (value) {
                  _location = value.isEmpty ? null : value;
                },
              ),
              const SizedBox(height: 16),
              // Tanggal Tersedia
              Text(
                'Tanggal Tersedia',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _availableFrom ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null) {
                          setState(() {
                            _availableFrom = picked;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          hintText: 'Dari',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        child: Text(
                          _availableFrom != null
                              ? '${_availableFrom!.day}/${_availableFrom!.month}/${_availableFrom!.year}'
                              : 'Pilih tanggal',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _availableTo ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null) {
                          setState(() {
                            _availableTo = picked;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          hintText: 'Sampai',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        child: Text(
                          _availableTo != null
                              ? '${_availableTo!.day}/${_availableTo!.month}/${_availableTo!.year}'
                              : 'Pilih tanggal',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Tombol Reset dan Terapkan
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        widget.onReset();
                      },
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApply(
                          _categoryId,
                          _minPrice,
                          _maxPrice,
                          _location,
                          _availableFrom,
                          _availableTo,
                        );
                      },
                      child: const Text('Terapkan'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
