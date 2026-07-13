import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/feedback_widgets.dart';
import '../../../../core/widgets/primitives.dart';
import '../../domain/entities/cart.dart';
import '../providers/cart_providers.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final _couponController = TextEditingController();

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AppColors.danger),
      );
    }
  }

  Future<void> _confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sepeti Temizle'),
        content: const Text('Sepetteki tüm ürünler kaldırılacak. Emin misin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Temizle',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await _run(() => ref.read(cartControllerProvider.notifier).clear());
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cartControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sepetim'
          '${state.value?.totalQuantity == null || state.value!.isEmpty ? '' : ' (${state.value!.totalQuantity})'}',
        ),
        actions: [
          if (state.value != null && !state.value!.isEmpty)
            TextButton(
              onPressed: _confirmClear,
              child: const Text('Temizle'),
            ),
        ],
      ),
      body: state.when(
        data: (cart) {
          if (cart.isEmpty) {
            return EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Sepetin şu an boş',
              message:
                  'Binlerce ürün seni bekliyor. Fırsatları kaçırmadan alışverişe başla!',
              actionLabel: 'Alışverişe Başla',
              onAction: () => context.go('/home'),
            );
          }
          return Column(
            children: [
              _FreeShippingBar(cart: cart),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => _CartItemTile(
                    item: cart.items[i],
                    onQuantityChanged: (quantity) => _run(
                      () => ref
                          .read(cartControllerProvider.notifier)
                          .updateQuantity(cart.items[i].product.id, quantity),
                    ),
                    onRemove: () => _run(
                      () => ref
                          .read(cartControllerProvider.notifier)
                          .remove(cart.items[i].product.id),
                    ),
                  ),
                ),
              ),
              _CartFooter(
                cart: cart,
                couponController: _couponController,
                onApplyCoupon: () => _run(() async {
                  await ref
                      .read(cartControllerProvider.notifier)
                      .applyCoupon(_couponController.text);
                  _couponController.clear();
                }),
                onRemoveCoupon: () => _run(
                  () => ref.read(cartControllerProvider.notifier).removeCoupon(),
                ),
              ),
            ],
          );
        },
        loading: () => const AppLoader(),
        error: (e, _) => ErrorView(
          message: e is AppException ? e.message : 'Sepet yüklenemedi.',
          onRetry: () => ref.invalidate(cartControllerProvider),
        ),
      ),
    );
  }
}

/// "Kargo bedava eşiğine X TL kaldı" ilerleme çubuğu.
class _FreeShippingBar extends StatelessWidget {
  const _FreeShippingBar({required this.cart});

  final Cart cart;

  @override
  Widget build(BuildContext context) {
    final remaining = cart.remainingForFreeShipping;
    final reached = remaining <= 0;
    final progress =
        ((AppConfig.freeShippingThreshold - remaining) /
                AppConfig.freeShippingThreshold)
            .clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: reached
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                reached ? Icons.check_circle : Icons.local_shipping_outlined,
                size: 18,
                color: reached ? AppColors.success : AppColors.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  reached
                      ? 'Tebrikler, kargon bedava! 🎉'
                      : 'Kargo bedava için ${Formatters.price(remaining)} daha ekle',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: reached ? AppColors.success : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          if (!reached) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  final CartItem item;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final product = item.product;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => context.push('/product/${product.id}'),
              child: AppNetworkImage(
                url: product.primaryImage,
                width: 72,
                height: 72,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${product.brand} ${product.name}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Satıcı: ${product.seller}',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      QuantityStepper(
                        value: item.quantity,
                        min: 0,
                        max: product.stock,
                        onChanged: onQuantityChanged,
                      ),
                      const Spacer(),
                      PriceText(price: item.lineTotal, fontSize: 15),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: onRemove,
              tooltip: 'Sepetten çıkar',
            ),
          ],
        ),
      ),
    );
  }
}

class _CartFooter extends StatelessWidget {
  const _CartFooter({
    required this.cart,
    required this.couponController,
    required this.onApplyCoupon,
    required this.onRemoveCoupon,
  });

  final Cart cart;
  final TextEditingController couponController;
  final VoidCallback onApplyCoupon;
  final VoidCallback onRemoveCoupon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.dividerTheme.color ?? AppColors.outline,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (cart.coupon == null)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: couponController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        hintText: 'Kupon kodu (örn. VB10)',
                        prefixIcon: Icon(Icons.confirmation_number_outlined),
                        isDense: true,
                      ),
                      onSubmitted: (_) => onApplyCoupon(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: onApplyCoupon,
                    child: const Text('Uygula'),
                  ),
                ],
              )
            else
              Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  avatar: const Icon(
                    Icons.confirmation_number,
                    size: 16,
                    color: AppColors.success,
                  ),
                  label: Text(
                    '${cart.coupon!.code} · ${cart.coupon!.description}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  onDeleted: onRemoveCoupon,
                ),
              ),
            const SizedBox(height: 10),
            _SummaryRow(label: 'Ara Toplam', value: cart.subtotal),
            if (cart.couponDiscount > 0)
              _SummaryRow(
                label: 'Kupon İndirimi',
                value: -cart.couponDiscount,
                valueColor: AppColors.success,
              ),
            _SummaryRow(
              label: 'Kargo',
              value: cart.shippingFee,
              freeLabel: cart.shippingFee == 0 ? 'Bedava' : null,
            ),
            const Divider(height: 16),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Toplam',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
                Text(
                  Formatters.price(cart.grandTotal),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/checkout'),
                icon: const Icon(Icons.lock_outline, size: 18),
                label: const Text('Sepeti Onayla'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.freeLabel,
  });

  final String label;
  final double value;
  final Color? valueColor;
  final String? freeLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            freeLabel ?? Formatters.price(value),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: freeLabel != null ? AppColors.success : valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
