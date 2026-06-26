import 'package:flutter/material.dart';

/// Placeholder screen — diisi pada prompt fitur berikutnya.
class EditListingScreen extends StatelessWidget {
  const EditListingScreen({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Barang')),
      body: Center(child: Text('Edit Barang — coming soon\nitemId: $itemId')),
    );
  }
}
