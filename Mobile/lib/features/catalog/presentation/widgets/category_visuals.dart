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

/// Gerçek API kategorileri ikon anahtarı taşımaz (yalnızca `iconId` — bir
/// fotoğraf kaydı, seed'de yok); `slug`'a göre en yakın ikonu seçer.
const Map<String, String> _iconBySlug = {
  'elektronik': 'devices',
  'giyim': 'checkroom',
  'ev-yasam': 'chair',
  'kozmetik': 'spa',
  'spor-outdoor': 'sports_soccer',
};

String iconKeyForSlug(String slug) => _iconBySlug[slug] ?? '';
