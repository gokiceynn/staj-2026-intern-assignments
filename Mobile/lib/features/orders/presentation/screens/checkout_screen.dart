import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/feedback_widgets.dart';
import '../../../cart/domain/entities/cart.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../../profile/domain/entities/address.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../providers/order_providers.dart';

/// 3 adımlı checkout: adres → ödeme (simülasyon) → özet & onay.
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _step = 0;
  Address? _selectedAddress;

  final _paymentFormKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _snack(String message, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Future<void> _placeOrder() async {
    final digits = _cardNumberController.text.replaceAll(' ', '');
    try {
      final order =
          await ref.read(checkoutControllerProvider.notifier).placeOrder(
                address: _selectedAddress!,
                cardLast4: digits.substring(digits.length - 4),
              );
      if (!mounted) return;
      context.pushReplacement('/order-success/${order.id}');
    } on AppException catch (e) {
      if (!mounted) return;
      _snack(e.message, color: AppColors.danger);
    }
  }

  void _continue() {
    switch (_step) {
      case 0:
        if (_selectedAddress == null) {
          _snack('Devam etmek için bir teslimat adresi seç.');
          return;
        }
        setState(() => _step = 1);
      case 1:
        if (_paymentFormKey.currentState!.validate()) {
          setState(() => _step = 2);
        }
      case 2:
        _placeOrder();
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = ref.watch(checkoutControllerProvider).isLoading;
    final cartState = ref.watch(cartControllerProvider);
    final cart = cartState.value;

    if (cartState.isLoading && cart == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ödeme')),
        body: const AppLoader(),
      );
    }
    if (cart == null || cart.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ödeme')),
        body: EmptyState(
          icon: Icons.shopping_cart_outlined,
          title: 'Sepetin boş',
          message: 'Sipariş verebilmek için önce sepetine ürün ekle.',
          actionLabel: 'Alışverişe Başla',
          onAction: () => context.go('/home'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ödeme')),
      body: Stepper(
        currentStep: _step,
        onStepContinue: busy ? null : _continue,
        onStepCancel: (_step == 0 || busy)
            ? null
            : () => setState(() => _step -= 1),
        controlsBuilder: (context, details) => Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  key: Key('checkout-continue-${details.stepIndex}'),
                  onPressed: details.onStepContinue,
                  child: busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _step == 2 ? 'Siparişi Tamamla 🔒' : 'Devam Et',
                        ),
                ),
              ),
              if (_step > 0) ...[
                const SizedBox(width: 12),
                TextButton(
                  onPressed: details.onStepCancel,
                  child: const Text('Geri'),
                ),
              ],
            ],
          ),
        ),
        steps: [
          Step(
            title: const Text('Teslimat Adresi'),
            isActive: _step >= 0,
            state: _step > 0 ? StepState.complete : StepState.indexed,
            content: _AddressStep(
              selected: _selectedAddress,
              onSelected: (address) =>
                  setState(() => _selectedAddress = address),
            ),
          ),
          Step(
            title: const Text('Ödeme Bilgileri'),
            isActive: _step >= 1,
            state: _step > 1 ? StepState.complete : StepState.indexed,
            content: _PaymentStep(
              formKey: _paymentFormKey,
              cardNumberController: _cardNumberController,
              cardHolderController: _cardHolderController,
              expiryController: _expiryController,
              cvvController: _cvvController,
            ),
          ),
          Step(
            title: const Text('Özet ve Onay'),
            isActive: _step >= 2,
            content: _SummaryStep(
              cart: cart,
              address: _selectedAddress,
              cardNumber: _cardNumberController.text,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressStep extends ConsumerWidget {
  const _AddressStep({required this.selected, required this.onSelected});

  final Address? selected;
  final ValueChanged<Address> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addresses = ref.watch(addressesProvider);

    return addresses.when(
      data: (items) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Kayıtlı adresin yok. Devam etmek için bir adres ekle.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          for (final address in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _AddressTile(
                address: address,
                selected: selected?.id == address.id,
                onTap: () => onSelected(address),
              ),
            ),
          OutlinedButton.icon(
            onPressed: () => context.push('/addresses/new'),
            icon: const Icon(Icons.add_location_alt_outlined, size: 18),
            label: const Text('Yeni Adres Ekle'),
          ),
        ],
      ),
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => ErrorView(
        message: e is AppException ? e.message : 'Adresler yüklenemedi.',
        onRetry: () => ref.invalidate(addressesProvider),
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  const _AddressTile({
    required this.address,
    required this.selected,
    required this.onTap,
  });

  final Address address;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : theme.dividerTheme.color ?? AppColors.outline,
            width: selected ? 1.6 : 1,
          ),
          color: selected ? AppColors.primary.withValues(alpha: 0.05) : null,
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.check_circle : Icons.location_on_outlined,
              color: selected
                  ? AppColors.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${address.fullName} · ${address.phone}',
                    style: const TextStyle(fontSize: 12.5),
                  ),
                  Text(
                    address.summary,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentStep extends StatelessWidget {
  const _PaymentStep({
    required this.formKey,
    required this.cardNumberController,
    required this.cardHolderController,
    required this.expiryController,
    required this.cvvController,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController cardNumberController;
  final TextEditingController cardHolderController;
  final TextEditingController expiryController;
  final TextEditingController cvvController;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: AppColors.warning),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Bu bir ödeme simülasyonudur — gerçek tahsilat yapılmaz. '
                    'Herhangi bir 16 haneli numara kullanabilirsin.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          TextFormField(
            key: const Key('checkout-card-number'),
            controller: cardNumberController,
            keyboardType: TextInputType.number,
            inputFormatters: [_CardNumberFormatter()],
            decoration: const InputDecoration(
              labelText: 'Kart Numarası',
              hintText: '4242 4242 4242 4242',
              prefixIcon: Icon(Icons.credit_card),
            ),
            validator: (value) =>
                (value ?? '').replaceAll(' ', '').length != 16
                    ? 'Kart numarası 16 haneli olmalı'
                    : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: const Key('checkout-card-holder'),
            controller: cardHolderController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Kart Üzerindeki İsim',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) => (value == null || value.trim().length < 3)
                ? 'Kart sahibinin adı gerekli'
                : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  key: const Key('checkout-expiry'),
                  controller: expiryController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [_ExpiryFormatter()],
                  decoration: const InputDecoration(
                    labelText: 'SKT',
                    hintText: 'AA/YY',
                  ),
                  validator: (value) {
                    final v = value ?? '';
                    if (!RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(v)) {
                      return 'AA/YY biçiminde girin';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  key: const Key('checkout-cvv'),
                  controller: cvvController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 3,
                  decoration: const InputDecoration(
                    labelText: 'CVV',
                    counterText: '',
                  ),
                  validator: (value) => (value ?? '').length != 3
                      ? '3 haneli olmalı'
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryStep extends StatelessWidget {
  const _SummaryStep({
    required this.cart,
    required this.address,
    required this.cardNumber,
  });

  final Cart cart;
  final Address? address;
  final String cardNumber;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final digits = cardNumber.replaceAll(' ', '');
    final last4 = digits.length >= 4 ? digits.substring(digits.length - 4) : '····';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (address != null) ...[
          _summaryTile(
            theme,
            icon: Icons.location_on_outlined,
            title: address!.title,
            subtitle: '${address!.fullName}\n${address!.summary}',
          ),
          const SizedBox(height: 8),
        ],
        _summaryTile(
          theme,
          icon: Icons.credit_card,
          title: 'Kredi/Banka Kartı',
          subtitle: '**** **** **** $last4',
        ),
        const Divider(height: 24),
        for (final item in cart.items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${item.product.name}  ×${item.quantity}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                Text(
                  Formatters.price(item.lineTotal),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        const Divider(height: 24),
        _totalRow('Ara Toplam', Formatters.price(cart.subtotal), theme),
        if (cart.couponDiscount > 0)
          _totalRow(
            'Kupon (${cart.coupon!.code})',
            '-${Formatters.price(cart.couponDiscount)}',
            theme,
            color: AppColors.success,
          ),
        _totalRow(
          'Kargo',
          cart.shippingFee == 0 ? 'Bedava' : Formatters.price(cart.shippingFee),
          theme,
          color: cart.shippingFee == 0 ? AppColors.success : null,
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Ödenecek Tutar',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ),
            Text(
              Formatters.price(cart.grandTotal),
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 17,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _summaryTile(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12.5,
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _totalRow(
    String label,
    String value,
    ThemeData theme, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// 16 haneyi 4'lü gruplara ayırır: "4242 4242 4242 4242".
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 16 ? digits.substring(0, 16) : digits;
    final buffer = StringBuffer();
    for (var i = 0; i < limited.length; i++) {
      buffer.write(limited[i]);
      if ((i + 1) % 4 == 0 && i + 1 != limited.length) buffer.write(' ');
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// "AA/YY" biçimi: 2 haneden sonra otomatik '/' ekler.
class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 4 ? digits.substring(0, 4) : digits;
    final text = limited.length <= 2
        ? limited
        : '${limited.substring(0, 2)}/${limited.substring(2)}';
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
