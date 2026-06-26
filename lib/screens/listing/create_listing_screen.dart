import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';

import '../../models/item.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listing_provider.dart' as listing;
import '../../services/listing_service.dart';
import '../../services/storage_service.dart';

class CreateListingScreen extends ConsumerStatefulWidget {
  const CreateListingScreen({super.key});

  @override
  ConsumerState<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  int _currentStep = 0;
  bool _isUploading = false;

  // Step 1 - Informasi Barang
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  String? _selectedCategoryId;
  ItemCondition? _selectedCondition;
  final GlobalKey<FormState> _step1FormKey = GlobalKey<FormState>();

  // Step 2 - Foto Barang
  final List<File?> _imageFiles = [null, null, null, null, null];
  final GlobalKey<FormState> _step2FormKey = GlobalKey<FormState>();

  // Step 3 - Harga & Aturan
  late TextEditingController _priceController;
  late TextEditingController _depositController;
  final GlobalKey<FormState> _step3FormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _locationController = TextEditingController();
    _priceController = TextEditingController();
    _depositController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _depositController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(int index) async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFiles[index] = File(pickedFile.path);
      });
    }
  }

  Future<void> _takePhoto(int index) async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFiles[index] = File(pickedFile.path);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageFiles[index] = null;
    });
  }

  void _showImageSourcePicker(int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitListing() async {
    final authState = ref.read(authProvider).valueOrNull;
    if (authState == null || authState.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User tidak ditemukan')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Validate all data
      if (_titleController.text.isEmpty ||
          _selectedCategoryId == null ||
          _selectedCondition == null ||
          _descriptionController.text.isEmpty ||
          _locationController.text.isEmpty ||
          _priceController.text.isEmpty ||
          _depositController.text.isEmpty ||
          _imageFiles.every((f) => f == null)) {
        throw Exception('Data tidak lengkap');
      }

      // Generate temp item ID untuk path storage
      final tempItemId = DateTime.now().millisecondsSinceEpoch.toString();

      // Upload images
      final uploadedUrls = <String>[];
      for (int i = 0; i < _imageFiles.length; i++) {
        if (_imageFiles[i] != null) {
          try {
            final url = await StorageService.uploadItemImage(
              imageFile: _imageFiles[i]!,
              itemId: tempItemId,
              index: i,
            );
            uploadedUrls.add(url);
          } catch (e) {
            print('Warning: Gagal upload foto $i: $e');
          }
        }
      }

      if (uploadedUrls.isEmpty) {
        throw Exception('Minimal harus 1 foto berhasil di-upload');
      }

      // Create item data
      final itemData = {
        'owner_id': authState.user!.id,
        'category_id': _selectedCategoryId,
        'title': _titleController.text,
        'description': _descriptionController.text,
        'price_per_day': double.parse(_priceController.text),
        'deposit_amount': double.parse(_depositController.text),
        'image_urls': uploadedUrls,
        'condition': _selectedCondition!.toDb(),
        'status': 'available',
        'location': _locationController.text,
        'blocked_dates': [],
        'created_at': DateTime.now().toIso8601String(),
      };

      // Create item di Supabase
      await ListingService.create(itemData);

      // Refresh MyListings
      if (authState.user != null) {
        // TAMBAHKAN "listing." DI DEPANNYA:
        ref.invalidate(listing.myListingsNotifierProvider(authState.user!.id));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Barang berhasil didaftarkan!')),
        );
        context.go('/listing/my');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mendaftarkan barang: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(listing.categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftarkan Barang'),
        elevation: 0,
      ),
      body: _isUploading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Mengunggah barang Anda...'),
                ],
              ),
            )
          : Stepper(
              currentStep: _currentStep,
              onStepContinue: () {
                // Validate current step
                if (_currentStep == 0) {
                  if (_step1FormKey.currentState?.validate() ?? false) {
                    if (_selectedCondition == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pilih kondisi barang')),
                      );
                      return;
                    }
                    setState(() => _currentStep = 1);
                  }
                } else if (_currentStep == 1) {
                  // Validate at least 1 image
                  if (_imageFiles.any((f) => f != null)) {
                    setState(() => _currentStep = 2);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tambahkan minimal 1 foto')),
                    );
                  }
                } else if (_currentStep == 2) {
                  if (_step3FormKey.currentState?.validate() ?? false) {
                    _submitListing();
                  }
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() => _currentStep -= 1);
                }
              },
              steps: [
                // Step 1: Informasi Barang
                Step(
                  title: const Text('Informasi Barang'),
                  isActive: _currentStep >= 0,
                  content: Form(
                    key: _step1FormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: 'Nama Barang',
                            hintText: 'Contoh: Laptop ASUS VivoBook',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            counterText:
                                '${_titleController.text.length}/60',
                          ),
                          maxLength: 60,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nama barang tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Kategori',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        categoriesAsync.when(
                          data: (categories) => DropdownButtonFormField<String>(
                            value: _selectedCategoryId,
                            decoration: InputDecoration(
                              hintText: 'Pilih kategori',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            items: categories
                                .map((cat) => DropdownMenuItem(
                                  value: cat.id,
                                  child: Text(cat.name),
                                ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategoryId = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Pilih kategori';
                              }
                              return null;
                            },
                          ),
                          loading: () => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          error: (error, _) => Text(error.toString()),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Kondisi Barang',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        SegmentedButton<ItemCondition>(
                          segments: const [
                            ButtonSegment(label: Text('Baru'), value: ItemCondition.baru),
                            ButtonSegment(label: Text('Sangat Baik'), value: ItemCondition.sangatBaik),
                            ButtonSegment(label: Text('Baik'), value: ItemCondition.baik),
                            ButtonSegment(label: Text('Cukup'), value: ItemCondition.cukup),
                          ],
                          selected: _selectedCondition != null
                              ? {_selectedCondition!}
                              : {},
                          onSelectionChanged: (value) {
                            setState(() {
                              _selectedCondition = value.first;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Deskripsi Barang',
                            hintText: 'Jelaskan kondisi, fitur, dan hal penting lainnya...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            counterText:
                                '${_descriptionController.text.length}/500',
                          ),
                          maxLines: 5,
                          maxLength: 500,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Deskripsi tidak boleh kosong';
                            }
                            if (value.length < 30) {
                              return 'Deskripsi minimal 30 karakter';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _locationController,
                          decoration: InputDecoration(
                            labelText: 'Lokasi',
                            hintText: 'Contoh: Malang, Jawa Timur',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lokasi tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // Step 2: Foto Barang
                Step(
                  title: const Text('Foto Barang'),
                  isActive: _currentStep >= 1,
                  content: Form(
                    key: _step2FormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tambahkan Foto (Min 1, Max 5)',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            final hasImage = _imageFiles[index] != null;
                            return GestureDetector(
                              onTap: hasImage
                                  ? null
                                  : () => _showImageSourcePicker(index),
                              child: DottedBorder(
                                borderType: BorderType.RRect,
                                radius: const Radius.circular(8),
                                dashPattern: const [8, 4],
                                color: Colors.grey[400]!,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey[50],
                                  ),
                                  child: hasImage
                                      ? Stack(
                                          children: [
                                            Image.file(
                                              _imageFiles[index]!,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                            ),
                                            Positioned(
                                              top: 4,
                                              right: 4,
                                              child: GestureDetector(
                                                onTap: () => _removeImage(index),
                                                child: Container(
                                                  decoration: const BoxDecoration(
                                                    color: Colors.red,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  padding: const EdgeInsets.all(4),
                                                  child: const Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.camera_alt,
                                                size: 32,
                                                color: Colors.grey[400],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Tambah Foto',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // Step 3: Harga & Aturan
                Step(
                  title: const Text('Harga & Aturan'),
                  isActive: _currentStep >= 2,
                  content: Form(
                    key: _step3FormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Harga Sewa per Hari',
                            hintText: '50000',
                            prefixText: 'Rp ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Harga tidak boleh kosong';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Harga harus berupa angka';
                            }
                            if (double.parse(value) <= 0) {
                              return 'Harga harus lebih dari 0';
                            }
                            return null;
                          },
                          onChanged: (value) => setState(() {}),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _depositController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Jumlah Deposit',
                            hintText: '100000',
                            prefixText: 'Rp ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            suffixIcon: Tooltip(
                              message:
                                  'Deposit akan dikembalikan setelah barang kembali dalam kondisi baik.',
                              child: const Icon(Icons.info, size: 20),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Deposit tidak boleh kosong';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Deposit harus berupa angka';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Estimasi Pendapatan',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge,
                              ),
                              const SizedBox(height: 8),
                              if (_priceController.text.isNotEmpty)
                                Builder(
                                  builder: (context) {
                                    final price =
                                        double.tryParse(_priceController.text) ?? 0;
                                    final afterFee = price * 0.95;
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Rp ${afterFee.toStringAsFixed(0)}/hari',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '(setelah biaya platform 5%)',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color: Colors.grey[600],
                                              ),
                                        ),
                                      ],
                                    );
                                  },
                                )
                              else
                                Text(
                                  'Masukkan harga untuk melihat estimasi',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: Colors.grey[600]),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
