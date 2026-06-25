import 'package:flutter/material.dart';

/// Placeholder screen — diisi pada prompt fitur berikutnya.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: const Center(child: Text('Pengaturan — coming soon')),
    );
  }
}
