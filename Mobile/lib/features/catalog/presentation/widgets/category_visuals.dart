import 'package:flutter/material.dart';

/// Seed verisindeki ikon anahtarlarını Material ikonlarına çevirir.
const Map<String, IconData> _categoryIcons = {
  'devices': Icons.devices,
  'checkroom': Icons.checkroom,
  'chair': Icons.chair,
  'spa': Icons.spa,
  'local_grocery_store': Icons.local_grocery_store,
  'sports_soccer': Icons.sports_soccer,
  'menu_book': Icons.menu_book,
  'child_friendly': Icons.child_friendly,
};

IconData categoryIcon(String key) => _categoryIcons[key] ?? Icons.category;
