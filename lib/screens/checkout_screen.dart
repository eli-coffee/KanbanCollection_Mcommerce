import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';
import '../services/pricing.dart';
import '../services/product_service.dart';
import '../services/voucher_service.dart';
import '../utils/product_image.dart';
import '../utils/responsive.dart';
import '../utils/strings.dart';
import '../utils/validators.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> items;
  final bool fromCart;
  final bool isPreorder;

  const CheckoutScreen({
    super.key,
    required this.items,
    this.fromCart = false,
    this.isPreorder = false,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late List<CartItem> _items;
  bool _placing = false;
  String _fullName = '';
  String _contact = '';
  String _address = '';
  PaymentMethod _method = PaymentMethod.cod;
  Voucher? _voucher;

  @override
  void initState() {
    super.initState();
    _items = widget.items
        .map((i) => CartItem(
              id: i.id,
              name: i.name,
              price: i.price,
              imageUrl: i.imageUrl,
              preorder: i.preorder,
              quantity: i.quantity,
            ))
        .toList();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final p = await AuthService().getProfile();
    if (!mounted) return;
    setState(() {
      _fullName = p['fullName'] ?? '';
      _contact = p['contact'] ?? '';
      _address = p['address'] ?? '';
    });
  }

  String _peso(double v) =>
      '₱${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}';

  double get _subtotal => _items.fold(0.0, (s, i) => s + i.price * i.quantity);
  int get _count => _items.fold(0, (s, i) => s + i.quantity);
  OrderTotals get _totals => Pricing.compute(_subtotal, _method, _voucher);

  void _increase(CartItem item) => setState(() => item.quantity++);

  void _decrease(CartItem item) {
    if (item.quantity > 1) setState(() => item.quantity--);
  }

  void _remove(CartItem item) {
    setState(() => _items.remove(item));
    if (_items.isEmpty) Navigator.of(context).pop();
  }

  // ----------------------------------------------------------- delivery
  Future<void> _editDelivery() async {
    final name = TextEditingController(text: _fullName);
    final contact = TextEditingController(text: _contact);
    final address = TextEditingController(text: _address);
    String? error;
    var saving = false;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
              16, 16, 16, MediaQuery.of(sheetContext).viewInsets.bottom + 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(S.t('Delivery address'),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                TextField(
                  controller: name,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: S.t('Full name'),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contact,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: S.t('Email or Contact Number'),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: address,
                  maxLines: 3,
                  maxLength: Validators.addressMax,
                  decoration: InputDecoration(
                    labelText: S.t('Full address'),
                    helperText: S.t(
                        'House no., street, barangay, city, province, postal code'),
                    errorText: error,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: saving
                        ? null
                        : () async {
                            final e = Validators.address(address.text);
                            if (e != null) {
                              setSheet(() => error = S.t(e));
                              return;
                            }
                            if (contact.text.trim().isEmpty) {
                              setSheet(() => error = S.t(
                                  'Email or contact number cannot be empty'));
                              return;
                            }
                            setSheet(() {
                              error = null;
                              saving = true;
                            });
                            final result = await AuthService().updateProfile(
                              fullName: name.text,
                              contact: contact.text,
                              address: address.text,
                            );
                            if (result != null) {
                              setSheet(() {
                                error = result;
                                saving = false;
                              });
                              return;
                            }
                            if (sheetContext.mounted) {
                              Navigator.pop(sheetContext, true);
                            }
                          },
                    child: Text(S.t('Save address')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (saved == true && mounted) {
      setState(() {
        _fullName = name.text.trim();
        _contact = contact.text.trim();
        _address = address.text.trim();
      });
    }
       Future.delayed(const Duration(milliseconds: 400), () {
      name.dispose();
      contact.dispose();
      address.dispose();
    });
  }

  Widget _deliveryCard() {
    final missing = Validators.address(_address) != null;
    return Card(
      color: missing ? Colors.red.withValues(alpha: 0.06) : null,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.location_on_outlined,
                color: missing ? Colors.red : null),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.tr('Delivery address'),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  if (missing)
                    Text(context.tr('Please add a delivery address'),
                        style: const TextStyle(color: Colors.red))
                  else ...[
                    if (_fullName.isNotEmpty)
                      Text(_fullName,
                          style:
                              const TextStyle(fontWeight: FontWeight.w500)),
                    if (_contact.isNotEmpty) Text(_contact),
                    Text(_address),
                  ],
                ],
              ),
            ),
            TextButton(
              onPressed: _editDelivery,
              child: Text(context.tr(missing ? 'Add' : 'Change')),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------ voucher
  Future<void> _pickVoucher() async {
    List<Voucher> list;
    try {
      list = await VoucherService.usable();
    } catch (e) {
      return;
    }
    if (!mounted) return;

    final subtotal = _subtotal;
    final picked = await showModalBottomSheet<Voucher?>(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: Text(S.t('No voucher')),
              onTap: () => Navigator.pop(ctx, null),
            ),
            if (list.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(S.t('You have no usable vouchers.')),
              ),
            for (final v in list)
              ListTile(
                enabled: subtotal >= v.minSpend,
                leading: const Icon(Icons.local_offer_outlined),
                title: Text(v.title),
                subtitle: Text(subtotal >= v.minSpend
                    ? v.description
                    : S.t('Min. spend {amount}',
                        {'amount': _peso(v.minSpend)})),
                onTap: () => Navigator.pop(ctx, v),
              ),
          ],
        ),
      ),
    );
    // Dismissing the sheet also returns null, which clears the voucher.
    if (mounted) setState(() => _voucher = picked);
  }

  // -------------------------------------------------------------- order
  Future<void> _placeOrder() async {
    if (_items.isEmpty) return;

    // An address is required before anything is charged or deducted.
    if (Validators.address(_address) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.t('Please add a delivery address'))),
      );
      _editDelivery();
      return;
    }

    setState(() => _placing = true);

    final deducted = <CartItem>[];
    var voucherUsed = false;
    final voucher = _voucher;

    try {
      final db = FirebaseDatabase.instance;
      final username = AuthService().currentUsername ?? 'guest';

      Map<String, dynamic> record(List<CartItem> list, String status) => {
            'username': username,
            'items': list
                .map((i) => {
                      'productId': i.id,
                      'name': i.name,
                      'price': i.price,
                      'quantity': i.quantity,
                    })
                .toList(),
            'total': list.fold(0.0, (s, i) => s + i.price * i.quantity),
            'status': status,
            'createdAt': ServerValue.timestamp,
            // Snapshot of where to ship, so later profile edits don't change it.
            'shipTo': {
              'name': _fullName.isEmpty ? username : _fullName,
              'contact': _contact,
              'address': _address,
            },
          };

      final regular = _items.where((i) => !i.preorder).toList();
      final preorders = _items.where((i) => i.preorder).toList();
      final totals = _totals;

      try {
        for (final item in regular) {
          await ProductService.deductStock(item.id, item.quantity);
          deducted.add(item);
        }
        if (voucher != null && totals.voucherDiscount > 0) {
          await VoucherService.use(voucher.id);
          voucherUsed = true;
        }

        // Voucher, bonus and shipping are charged once, on the first record.
        Map<String, dynamic> withTotals(
            List<CartItem> list, String status, bool carriesCharges) {
          final base = record(list, status);
          final sub = base['total'] as double;
          base['subtotal'] = sub;
          base['payment'] = paymentLabel(_method);
          base['paymentStatus'] =
              Pricing.isPrepaid(_method) ? 'Pending' : 'Pay on delivery';
          if (carriesCharges) {
            base['voucherId'] = voucherUsed ? voucher!.id : null;
            base['voucherDiscount'] = totals.voucherDiscount;
            base['prepaidBonus'] = totals.prepaidBonus;
            base['shippingFee'] = totals.shipping;
            base['shippingDiscount'] = totals.shippingDiscount;
            base['total'] = totals.total - (totals.subtotal - sub);
          }
          return base;
        }

        final firstIsRegular = regular.isNotEmpty;
        if (regular.isNotEmpty) {
          await db
              .ref('orders')
              .push()
              .set(withTotals(regular, 'Processing', firstIsRegular));
        }
        if (preorders.isNotEmpty) {
          await db
              .ref('preorders')
              .push()
              .set(withTotals(preorders, 'Pre-order', !firstIsRegular));
        }
      } catch (e) {
        for (final item in deducted) {
          await ProductService.restoreStock(item.id, item.quantity);
        }
        if (voucherUsed) await VoucherService.restore(voucher!.id);
        rethrow;
      }

      if (widget.fromCart) {
        final cart = CartService();
        for (final ordered in _items) {
          for (final inCart in List.of(cart.items)) {
            if (ordered.id == inCart.id) await cart.remove(inCart);
          }
        }
      }

      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: Text(S.t('Order placed!')),
          content: Text(preorders.isNotEmpty && regular.isEmpty
              ? S.t('Your pre-order has been received.')
              : S.t('Your order is now being processed.')),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('${S.t('Could not place order')}: ${S.t('$e')}')),
      );
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  Widget _row(String label, double amount,
      {bool negative = false, bool bold = false, Color? color}) {
    final style = TextStyle(
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        fontSize: bold ? 20 : 14,
        color: color);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Text(label, style: style),
        const Spacer(),
        Text('${negative ? '-' : ''}${_peso(amount)}', style: style),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totals = _totals;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Checkout')), centerTitle: true),
      body: ResponsiveCenter(
        maxWidth: 800,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _deliveryCard(),
            const SizedBox(height: 16),

            Text(context.tr('Order summary'),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            for (final item in _items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 72,
                        height: 72,
                        child: item.imageUrl.isEmpty
                            ? Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.toys),
                              )
                            : buildProductImage(item.imageUrl,
                                width: 72, height: 72),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(_peso(item.price * item.quantity),
                              style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Row(children: [
                            IconButton.outlined(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.remove, size: 16),
                              onPressed: item.quantity > 1
                                  ? () => _decrease(item)
                                  : null,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text('${item.quantity}'),
                            ),
                            IconButton.outlined(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.add, size: 16),
                              onPressed: () => _increase(item),
                            ),
                          ]),
                        ],
                      ),
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _remove(item),
                    ),
                  ],
                ),
              ),
            const Divider(height: 32),

            Text(context.tr('Payment method'),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            RadioGroup<PaymentMethod>(
              groupValue: _method,
              onChanged: (v) => setState(() => _method = v ?? _method),
              child: Column(
                children: [
                  for (final m in PaymentMethod.values)
                    RadioListTile<PaymentMethod>(
                      contentPadding: EdgeInsets.zero,
                      value: m,
                      title: Text(context.tr(paymentLabel(m))),
                      subtitle: m == PaymentMethod.cod
                          ? Text(context.tr(
                              'Free shipping on orders of {amount} or more', {
                              'amount': _peso(Pricing.codFreeShippingThreshold)
                            }))
                          : Text(context.tr('{n}% bonus discount', {
                              'n': Pricing.prepaidBonusPercent
                                  .toStringAsFixed(0)
                            })),
                    ),
                ],
              ),
            ),
            const Divider(height: 32),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.local_offer_outlined),
              title: Text(_voucher?.title ?? context.tr('Select a voucher')),
              subtitle: _voucher != null && totals.voucherDiscount == 0
                  ? Text(context.tr('Minimum spend not met'),
                      style: const TextStyle(color: Colors.red))
                  : null,
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickVoucher,
            ),
            const Divider(height: 32),

            _row(context.tr('Subtotal ({n} items)', {'n': _count}),
                totals.subtotal),
            if (totals.voucherDiscount > 0)
              _row(context.tr('Voucher'), totals.voucherDiscount,
                  negative: true, color: Colors.green),
            if (totals.prepaidBonus > 0)
              _row(context.tr('Payment bonus'), totals.prepaidBonus,
                  negative: true, color: Colors.green),
            _row(context.tr('Shipping fee'), totals.shipping),
            if (totals.shippingDiscount > 0)
              _row(context.tr('Shipping discount'), totals.shippingDiscount,
                  negative: true, color: Colors.green),
            const Divider(height: 24),
            _row(context.tr('Total'), totals.total, bold: true),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton(
            onPressed: _placing ? null : _placeOrder,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: _placing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text(_items.isNotEmpty && _items.every((i) => i.preorder)
                    ? context.tr('Place Pre-order')
                    : context.tr('Place Order')),
          ),
        ),
      ),
    );
  }
}