import 'dart:async';
import 'package:flutter/material.dart';
import '../services/voucher_service.dart';
import '../utils/responsive.dart';
import '../utils/strings.dart';

class VouchersScreen extends StatefulWidget {
  const VouchersScreen({super.key});

  @override
  State<VouchersScreen> createState() => _VouchersScreenState();
}

class _VouchersScreenState extends State<VouchersScreen> {
  StreamSubscription<List<Voucher>>? _a;
  StreamSubscription<Map<String, int>>? _b;
  List<Voucher> _all = [];
  Map<String, int> _claimed = {};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _a = VoucherService.streamAll().listen((l) {
      if (mounted) setState(() { _all = l; _loaded = true; });
    }, onError: (_) {
      if (mounted) setState(() => _loaded = true);
    });
    _b = VoucherService.streamClaimed().listen((m) {
      if (mounted) setState(() => _claimed = m);
    }, onError: (_) {});
  }

  @override
  void dispose() {
    _a?.cancel();
    _b?.cancel();
    super.dispose();
  }

  String _peso(double v) =>
      '₱${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}';

  String _date(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  Future<void> _claim(Voucher v) async {
    try {
      await VoucherService.claim(v);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(S.t('Voucher claimed'))));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(S.t('$e'))));
    }
  }

  Widget _card(Voucher v, {required bool mine}) {
    final count = _claimed[v.id] ?? 0;
    final expired = v.expired;
    final dim = expired || (mine && count == 0);
    final cs = Theme.of(context).colorScheme;
    final off = v.percent !=null? 
    context.tr('{n}% OFF', {'n': v.percent!.toStringAsFixed(0)})
    : context.tr('{amount} OFF', {'amount': _peso(v.amount ?? 0)});

Widget action;
if (expired) {
  action = Text(context.tr('Expired'), style: const TextStyle(color: Colors.red));
} else if (mine) {
  action = Text('x$count',
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
} else {
  action = Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (count > 0)
        Text('x$count',
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.green)),
      ElevatedButton(
        onPressed: VoucherService.claimedThisLogin ? null : () => _claim(v),
        child: Text(context.tr('Claim')),
      ),
    ],
  );
}

    return Opacity(
      opacity: dim ? 0.55 : 1,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 96,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(12)),
                ),
                child: Text(off,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: cs.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(v.title,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (v.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(v.description, style: const TextStyle(fontSize: 12)),
                      ],
                      const SizedBox(height: 6),
                      if (v.minSpend > 0)
                        Text(
                            context.tr('Min. spend {amount}',
                                {'amount': _peso(v.minSpend)}),
                            style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(
                          v.expiresAt > 0
                              ? context.tr('Valid until {date}',
                                  {'date': _date(v.expiresAt)})
                              : context.tr('No expiry'),
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Center(child: action),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _list(List<Voucher> list, String emptyText, {required bool mine}) {
    if (!_loaded) return const Center(child: CircularProgressIndicator());
    if (list.isEmpty) {
      return Center(
          child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(emptyText, textAlign: TextAlign.center),
      ));
    }
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [for (final v in list) _card(v, mine: mine)],
    );
  }

  @override
  Widget build(BuildContext context) {
   final available = _all.where((v) => !v.expired).toList();
   final mine = _all.where((v) => (_claimed[v.id] ?? 0) > 0).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.tr('Vouchers')),
          centerTitle: true,
          bottom: TabBar(tabs: [
            Tab(text: context.tr('Available')),
            Tab(text: context.tr('My Vouchers')),
          ]),
        ),
        body: ResponsiveCenter(
          maxWidth: 700,
          child: TabBarView(children: [
            _list(available, context.tr('No vouchers available right now.'),
                mine: false),
            _list(
                mine,
                context.tr(
                    'You have no vouchers yet. Claim some from the Available tab.'),
                mine: true),
          ]),
        ),
      ),
    );
  }
}