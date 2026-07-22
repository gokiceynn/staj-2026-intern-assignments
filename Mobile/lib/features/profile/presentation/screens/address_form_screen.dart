import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/address.dart';
import '../providers/profile_providers.dart';

/// Yeni adres ekleme / mevcut adresi düzenleme formu.
class AddressFormScreen extends ConsumerStatefulWidget {
  const AddressFormScreen({super.key, this.existing});

  final Address? existing;

  @override
  ConsumerState<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends ConsumerState<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _titleController =
      TextEditingController(text: widget.existing?.title);
  late final _nameController =
      TextEditingController(text: widget.existing?.fullName);
  late final _phoneController =
      TextEditingController(text: widget.existing?.phone);
  late final _cityController =
      TextEditingController(text: widget.existing?.city);
  late final _districtController =
      TextEditingController(text: widget.existing?.district);
  late final _addressController =
      TextEditingController(text: widget.existing?.addressLine);
  late final _zipCodeController =
      TextEditingController(text: widget.existing?.zipCode);
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _addressController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(addressActionsProvider).save(
            Address(
              id: widget.existing?.id ?? '',
              title: _titleController.text.trim(),
              fullName: _nameController.text.trim(),
              phone: _phoneController.text.trim(),
              city: _cityController.text.trim(),
              district: _districtController.text.trim(),
              addressLine: _addressController.text.trim(),
              zipCode: _zipCodeController.text.trim(),
            ),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adres kaydedildi.'),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'Yeni Adres' : 'Adresi Düzenle'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Adres Başlığı (örn. Ev, İş)',
                  prefixIcon: Icon(Icons.bookmark_outline),
                ),
                validator: _required,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Ad Soyad',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: _required,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Telefon',
                  hintText: '+90 5xx xxx xx xx',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (value) {
                  final digits =
                      (value ?? '').replaceAll(RegExp(r'\D'), '');
                  return digits.length < 10 ? 'Geçerli bir telefon girin' : null;
                },
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'İl'),
                      validator: _required,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _districtController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'İlçe'),
                      validator: _required,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _zipCodeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Posta Kodu',
                  prefixIcon: Icon(Icons.local_post_office_outlined),
                ),
                validator: _required,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _addressController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Açık Adres',
                  hintText: 'Mahalle, cadde, sokak, bina ve daire no',
                  alignLabelWithHint: true,
                ),
                validator: (value) => (value == null || value.trim().length < 10)
                    ? 'Açık adres en az 10 karakter olmalı'
                    : null,
              ),
              const SizedBox(height: 24),
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
                    : const Text('Kaydet'),
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
