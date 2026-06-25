import 'package:flutter/material.dart';

/// Placeholder screen — diisi pada prompt fitur berikutnya.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: const Center(child: Text('Profil — coming soon')),
    );
  }
}
