import 'package:flutter/material.dart';

import '../../domain/entities/product_query.dart';

/// Fiyat aralığı / puan / stok filtreleri. "Uygula" ile yeni [ProductQuery]
/// döner; "Temizle" filtreleri sıfırlar (arama/kategori bağlamı korunur).
class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key, required this.current});

  final ProductQuery current;

  static Future<ProductQuery?> show(
    BuildContext context,
    ProductQuery current,
  ) {
    return showModalBottomSheet<ProductQuery>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => FilterSheet(current: current),
    );
  }

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late final _minPriceController = TextEditingController(
    text: widget.current.minPrice?.toStringAsFixed(0) ?? '',
  );
  late final _maxPriceController = TextEditingController(
    text: widget.current.maxPrice?.toStringAsFixed(0) ?? '',
  );
  late double? _minRating = widget.current.minRating;
  late bool _inStockOnly = widget.current.inStockOnly;

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  ProductQuery _buildQuery({bool cleared = false}) {
    final base = widget.current;
    return ProductQuery(
      q: base.q,
      categoryId: base.categoryId,
      flashDealsOnly: base.flashDealsOnly,
      featuredOnly: base.featuredOnly,
      sort: base.sort,
      size: base.size,
      minPrice: cleared ? null : double.tryParse(_minPriceController.text),
      maxPrice: cleared ? null : double.tryParse(_maxPriceController.text),
      minRating: cleared ? null : _minRating,
      inStockOnly: !cleared && _inStockOnly,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtrele',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          const Text('Fiyat Aralığı (TL)',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minPriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'En az'),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text('—'),
              ),
              Expanded(
                child: TextField(
                  controller: _maxPriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'En çok'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Minimum Puan',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final rating in const [null, 3.0, 4.0, 4.5])
                ChoiceChip(
                  label: Text(
                    rating == null ? 'Tümü' : '$rating ★ ve üzeri',
                  ),
                  selected: _minRating == rating,
                  onSelected: (_) => setState(() => _minRating = rating),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Sadece stoktakiler'),
            value: _inStockOnly,
            onChanged: (value) => setState(() => _inStockOnly = value),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      Navigator.pop(context, _buildQuery(cleared: true)),
                  child: const Text('Temizle'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, _buildQuery()),
                  child: const Text('Uygula'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
