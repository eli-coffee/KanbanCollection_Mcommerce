import 'package:flutter/material.dart';
import '../services/voucher_service.dart';
import '../theme/app_theme.dart';
import '../utils/strings.dart';

Future<void> showVoucherPopup(BuildContext context) async {
  List<Voucher> list;
  try {
    list = await VoucherService.claimable();
  } catch (_) {
    return;
  }
  if (list.isEmpty || !context.mounted) return;

  await showDialog<void>(
    context: context,
    builder: (_) => _VoucherPopup(vouchers: list),
  );
}

class _VoucherPopup extends StatefulWidget {
  final List<Voucher> vouchers;
  const _VoucherPopup({required this.vouchers});

  @override
  State<_VoucherPopup> createState() => _VoucherPopupState();
}

class _VoucherPopupState extends State<_VoucherPopup> {
  final _claimed = <String>{};
  final _busy = <String>{};

  String _peso(double v) => '₱${v.toStringAsFixed(0)}';

  String _off(Voucher v) => v.percent != null
      ? '${v.percent!.toStringAsFixed(0)}%'
      : _peso(v.amount ?? 0);

  Future<void> _claim(Voucher v) async {
  setState(() => _busy.add(v.id));
  try {
    await VoucherService.claim(v);
    if (!mounted) return;
    setState(() => _claimed.add(v.id));
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(S.t('$e'))));
  } finally {
    if (mounted) setState(() => _busy.remove(v.id));
  }
}

  Widget _card(Voucher v) {
    final cs = Theme.of(context).colorScheme;
    final done = _claimed.contains(v.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 82,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.indigo,
                borderRadius:
                    BorderRadius.horizontal(left: Radius.circular(13)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_off(v),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0)),
                  const Text('OFF',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1)),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(v.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: cs.onSurface,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0)),
                    const SizedBox(height: 2),
                    Text(
                        v.minSpend > 0
                            ? S.t('Min. spend {amount}',
                                {'amount': _peso(v.minSpend)})
                            : v.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 12,
                            letterSpacing: 0)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: done
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 18),
                        const SizedBox(width: 4),
                        Text(S.t('Claimed'),
                            style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0)),
                      ],
                    )
                  : FilledButton(
                  onPressed: (_busy.contains(v.id) || VoucherService.claimedThisLogin)
                      ? null
                      : () => _claim(v),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.indigo,
                    foregroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(S.t('Claim')),
                ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final maxH = MediaQuery.of(context).size.height * 0.45;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.indigo, AppColors.navy],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.card_giftcard,
                          color: Colors.white, size: 40),
                      const SizedBox(height: 8),
                      Text(S.t('You have vouchers waiting!'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0)),
                      const SizedBox(height: 4),
                      Text(S.t('Claim them now and use them at checkout'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              letterSpacing: 0)),
                    ],
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: IconButton(
                    tooltip: S.t('Close'),
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxH),
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                  children: [for (final v in widget.vouchers) _card(v)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(S.t('Maybe later')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}