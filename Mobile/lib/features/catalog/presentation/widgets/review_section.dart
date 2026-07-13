import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/primitives.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/catalog_providers.dart';

/// Ürün detayındaki değerlendirme listesi + yorum yazma akışı.
class ReviewSection extends ConsumerWidget {
  const ReviewSection({super.key, required this.productId});

  final String productId;

  Future<void> _openReviewSheet(BuildContext context, WidgetRef ref) async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Yorum yazmak için giriş yapmalısın.'),
          action: SnackBarAction(
            label: 'Giriş Yap',
            onPressed: () => context.push('/login'),
          ),
        ),
      );
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _AddReviewSheet(productId: productId, userName: user.name),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviews = ref.watch(reviewsProvider(productId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Değerlendirmeler'
                  '${reviews.value == null ? '' : ' (${reviews.value!.length})'}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _openReviewSheet(context, ref),
                icon: const Icon(Icons.rate_review_outlined, size: 18),
                label: const Text('Yorum Yaz'),
              ),
            ],
          ),
        ),
        reviews.when(
          data: (items) {
            if (items.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Bu ürün için henüz değerlendirme yok. İlk yorumu sen yaz!',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }
            return Column(
              children: [
                for (final review in items)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor:
                                  AppColors.primary.withValues(alpha: 0.15),
                              child: Text(
                                review.userName.characters.first.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    review.userName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    Formatters.date(review.createdAt),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            RatingStars(rating: review.rating.toDouble()),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          review.comment,
                          style: const TextStyle(fontSize: 13.5, height: 1.4),
                        ),
                        const SizedBox(height: 4),
                        const Divider(),
                      ],
                    ),
                  ),
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                SkeletonRow(),
                SizedBox(height: 12),
                SkeletonRow(),
              ],
            ),
          ),
          error: (_, _) => const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Değerlendirmeler yüklenemedi.'),
          ),
        ),
      ],
    );
  }
}

/// Yorumlar yüklenirken gösterilen iki satırlık iskelet.
class SkeletonRow extends StatelessWidget {
  const SkeletonRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonLine(width: 140),
        SizedBox(height: 6),
        SkeletonLine(width: double.infinity),
      ],
    );
  }
}

class SkeletonLine extends StatelessWidget {
  const SkeletonLine({super.key, required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 12,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class _AddReviewSheet extends ConsumerStatefulWidget {
  const _AddReviewSheet({required this.productId, required this.userName});

  final String productId;
  final String userName;

  @override
  ConsumerState<_AddReviewSheet> createState() => _AddReviewSheetState();
}

class _AddReviewSheetState extends ConsumerState<_AddReviewSheet> {
  final _commentController = TextEditingController();
  int _rating = 5;
  bool _submitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final comment = _commentController.text.trim();
    if (comment.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yorum en az 5 karakter olmalı.')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await ref.read(catalogRepositoryProvider).addReview(
            productId: widget.productId,
            userName: widget.userName,
            rating: _rating,
            comment: comment,
          );
      ref.invalidate(reviewsProvider(widget.productId));
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Değerlendirmen yayınlandı, teşekkürler!'),
          backgroundColor: AppColors.success,
        ),
      );
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AppColors.danger),
      );
    }
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
            'Ürünü Değerlendir',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  onPressed: () => setState(() => _rating = i),
                  icon: Icon(
                    i <= _rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 34,
                    color: AppColors.warning,
                  ),
                  tooltip: '$i yıldız',
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _commentController,
            maxLines: 4,
            maxLength: 300,
            decoration: const InputDecoration(
              hintText: 'Ürün hakkındaki deneyimini paylaş...',
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Gönder'),
            ),
          ),
        ],
      ),
    );
  }
}
