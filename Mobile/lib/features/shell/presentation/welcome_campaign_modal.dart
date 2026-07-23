import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/presentation/providers/auth_providers.dart';

/// Web'deki `WelcomeCampaignModal` bileşeninin mobil karşılığı — misafir
/// kullanıcıya uygulama açılışında bir kez üyelik kampanyası gösterir.
/// Web'in animasyonlu yaprak dekorasyonları (SVG sway) mobilde sadeleştirildi;
/// tek görsel + kayıt butonu yeterli görsel etkiyi verir.
///
/// Not: `MaterialApp.router`'ın `builder` context'i Router/Navigator'ın
/// ÜSTÜNDE kaldığı için `showDialog` orada çalışmaz — bu widget bunun yerine
/// `MainShell` içine (Navigator'ın altında) yerleştirilir.
final _campaignShownProvider = StateProvider<bool>((ref) => false);

class WelcomeCampaignTrigger extends ConsumerStatefulWidget {
  const WelcomeCampaignTrigger({super.key});

  @override
  ConsumerState<WelcomeCampaignTrigger> createState() =>
      _WelcomeCampaignTriggerState();
}

class _WelcomeCampaignTriggerState
    extends ConsumerState<WelcomeCampaignTrigger> {
  @override
  Widget build(BuildContext context) {
    final isLoggedIn = ref.watch(isLoggedInProvider);
    final alreadyShown = ref.watch(_campaignShownProvider);

    if (!isLoggedIn && !alreadyShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(_campaignShownProvider.notifier).state = true;
        _showCampaign(context);
      });
    }

    return const SizedBox.shrink();
  }

  void _showCampaign(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        backgroundColor: Colors.transparent,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/campaign/anaekran.png',
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 20,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  dialogContext.push('/register');
                },
                child: const Text(
                  'HEMEN KAYIT OL',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            Positioned(
              right: -4,
              top: -4,
              child: Material(
                color: Colors.white,
                shape: const CircleBorder(),
                elevation: 3,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.of(dialogContext).pop(),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.close, size: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
