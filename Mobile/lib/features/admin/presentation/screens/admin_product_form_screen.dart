import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../providers/admin_providers.dart';

/// Ürün ekleme/düzenleme formu (admin).
class AdminProductFormScreen extends ConsumerStatefulWidget {
  const AdminProductFormScreen({super.key, this.existing});

  final Product? existing;

  @override
  ConsumerState<AdminProductFormScreen> createState() =>
      _AdminProductFormScreenState();
}

class _AdminProductFormScreenState
    extends ConsumerState<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final _nameController = TextEditingController(
    text: widget.existing?.name,
  );
  late final _brandController = TextEditingController(
    text: widget.existing?.brand,
  );
  late final _descriptionController = TextEditingController(
    text: widget.existing?.description,
  );
  late final _priceController = TextEditingController(
    text: widget.existing?.price.toStringAsFixed(2),
  );
  late final _originalPriceController = TextEditingController(
    text: widget.existing?.originalPrice?.toStringAsFixed(2) ?? '',
  );
  late final _stockController = TextEditingController(
    text: widget.existing?.stock.toString(),
  );
  late final _sellerController = TextEditingController(
    text: widget.existing?.seller ?? 'VBShop',
  );

  late String? _categoryId = widget.existing?.categoryId;
  late bool _freeShipping = widget.existing?.freeShipping ?? false;
  late bool _isFlashDeal = widget.existing?.isFlashDeal ?? false;
  late bool _isFeatured = widget.existing?.isFeatured ?? false;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _stockController.dispose();
    _sellerController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bir kategori seç.')),
      );
      return;
    }

    final price = double.parse(_priceController.text.replaceAll(',', '.'));
    final originalPrice = _originalPriceController.text.trim().isEmpty
        ? null
        : double.parse(_originalPriceController.text.replaceAll(',', '.'));

    // Yeni üründe görseller ürün adından türetilen seed ile üretilir.
    final seed = _nameController.text.trim().hashCode.toRadixString(16);
    final images = widget.existing?.images ??
        [
          'https://picsum.photos/seed/vbshop-$seed-a/600/600',
          'https://picsum.photos/seed/vbshop-$seed-b/600/600',
        ];

    final product = Product(
      id: widget.existing?.id ?? '',
      name: _nameController.text.trim(),
      brand: _brandController.text.trim(),
      description: _descriptionController.text.trim(),
      categoryId: _categoryId!,
      price: price,
      originalPrice: originalPrice,
      images: images,
      rating: widget.existing?.rating ?? 0,
      reviewCount: widget.existing?.reviewCount ?? 0,
      stock: int.parse(_stockController.text),
      seller: _sellerController.text.trim(),
      freeShipping: _freeShipping,
      isFlashDeal: _isFlashDeal,
      isFeatured: _isFeatured,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );

    setState(() => _saving = true);
    try {
      await ref.read(adminActionsProvider).upsertProduct(product);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.existing == null ? 'Ürün eklendi.' : 'Ürün güncellendi.',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'Yeni Ürün' : 'Ürünü Düzenle'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Ürün Adı'),
                validator: _required,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _brandController,
                      decoration: const InputDecoration(labelText: 'Marka'),
                      validator: _required,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _sellerController,
                      decoration: const InputDecoration(labelText: 'Satıcı'),
                      validator: _required,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              categories.when(
                data: (items) => DropdownButtonFormField<String>(
                  initialValue: _categoryId,
                  decoration: const InputDecoration(labelText: 'Kategori'),
                  items: [
                    for (final category in items)
                      DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      ),
                  ],
                  onChanged: (value) => setState(() => _categoryId = value),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, _) => const Text('Kategoriler yüklenemedi'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Açıklama',
                  alignLabelWithHint: true,
                ),
                validator: _required,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Satış Fiyatı (TL)',
                      ),
                      validator: (value) {
                        final parsed = double.tryParse(
                          (value ?? '').replaceAll(',', '.'),
                        );
                        return (parsed == null || parsed <= 0)
                            ? 'Geçerli fiyat girin'
                            : null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _originalPriceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Eski Fiyat (ops.)',
                        helperText: 'İndirim için',
                        helperStyle: TextStyle(fontSize: 10),
                      ),
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) return null;
                        final parsed =
                            double.tryParse(value!.replaceAll(',', '.'));
                        if (parsed == null || parsed <= 0) {
                          return 'Geçersiz fiyat';
                        }
                        final price = double.tryParse(
                          _priceController.text.replaceAll(',', '.'),
                        );
                        if (price != null && parsed <= price) {
                          return 'Satış fiyatından büyük olmalı';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Stok Adedi'),
                validator: (value) {
                  final parsed = int.tryParse(value ?? '');
                  return (parsed == null || parsed < 0)
                      ? 'Geçerli stok girin'
                      : null;
                },
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Kargo Bedava'),
                value: _freeShipping,
                onChanged: (value) => setState(() => _freeShipping = value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Süper Fırsat (⚡ flash deal)'),
                value: _isFlashDeal,
                onChanged: (value) => setState(() => _isFlashDeal = value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Öne Çıkan'),
                value: _isFeatured,
                onChanged: (value) => setState(() => _isFeatured = value),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        widget.existing == null ? 'Ürünü Ekle' : 'Kaydet',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _required(String? value) =>
      (value == null || value.trim().isEmpty) ? 'Bu alan gerekli' : null;
}
