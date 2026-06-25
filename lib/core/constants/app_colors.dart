import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // --- Brand colors (light) — sesuai spec Prompt #1 ---
  static const primaryBlue = Color(0xFF2563EB);
  static const secondaryGreen = Color(0xFF16A34A);
  static const dangerRed = Color(0xFFDC2626);
  static const warningAmber = Color(0xFFD97706);

  static const background = Color(0xFFF8FAFC);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const border = Color(0xFFE2E8F0);

  // --- Dark mode ---
  // CATATAN: prompt hanya memberi palet light mode. Nilai di bawah ini
  // saya pilih sendiri (turunan slate dari brand color yang sama) supaya
  // "buat light theme dan dark theme" tetap terpenuhi — sesuaikan kalau
  // tim sudah punya palet dark mode resmi.
  static const backgroundDark = Color(0xFF0F172A);
  static const surfaceDark = Color(0xFF1E293B);
  static const textPrimaryDark = Color(0xFFF8FAFC);
  static const textSecondaryDark = Color(0xFF94A3B8);
  static const borderDark = Color(0xFF334155);
}
