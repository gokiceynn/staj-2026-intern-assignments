import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/formatters.dart';

/// Fiyat gösterimi: indirim varsa üstü çizili eski fiyat + vurgulu yeni fiyat.
class PriceText extends StatelessWidget {
  const PriceText({
    super.key,
    required this.price,
    this.originalPrice,
    this.fontSize = 15,
    this.compact = false,
  });

  final double price;
  final double? originalPrice;
  final double fontSize;

  /// true iken eski fiyat ve yeni fiyat tek satırda gösterilir.
  final bool compact;

  bool get _hasDiscount => originalPrice != null && originalPrice! > price;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = Text(
      Formatters.price(price),
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        color: _hasDiscount ? AppColors.success : theme.colorScheme.onSurface,
      ),
    );

    if (!_hasDiscount) return current;

    final old = Text(
      Formatters.price(originalPrice!),
      style: TextStyle(
        fontSize: fontSize - 3,
        color: theme.colorScheme.onSurfaceVariant,
        decoration: TextDecoration.lineThrough,
      ),
    );

    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [old, const SizedBox(width: 6), current],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [old, current],
    );
  }
}

/// "%23" biçiminde indirim rozeti.
class DiscountBadge extends StatelessWidget {
  const DiscountBadge({super.key, required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.danger,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '%$percent',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// 5 yıldızlı puan göstergesi + isteğe bağlı değerlendirme sayısı.
class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.reviewCount,
    this.size = 14,
  });

  final double rating;
  final int? reviewCount;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            rating >= i
                ? Icons.star_rounded
                : rating >= i - 0.5
                    ? Icons.star_half_rounded
                    : Icons.star_outline_rounded,
            size: size,
            color: AppColors.warning,
          ),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: size - 2,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        if (reviewCount != null) ...[
          const SizedBox(width: 2),
          Text(
            '($reviewCount)',
            style: TextStyle(
              fontSize: size - 2,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

/// Sepet/detay ekranlarında adet artır-azalt kontrolü.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 99,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerTheme.color ?? AppColors.outline),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: value <= min ? Icons.delete_outline : Icons.remove,
            onTap: value <= min ? null : () => onChanged(value - 1),
          ),
          SizedBox(
            width: 32,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          _StepButton(
            icon: Icons.add,
            onTap: value >= max ? null : () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 18,
          color: onTap == null
              ? Theme.of(context).disabledColor
              : AppColors.primary,
        ),
      ),
    );
  }
}

/// Ana sayfa bölüm başlığı + "Tümünü Gör".
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
          if (onSeeAll != null)
            TextButton(onPressed: onSeeAll, child: const Text('Tümünü Gör')),
        ],
      ),
    );
  }
}
