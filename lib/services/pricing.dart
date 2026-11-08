import 'voucher_service.dart';

enum PaymentMethod { cod, card, online }

String paymentLabel(PaymentMethod m) {
  switch (m) {
    case PaymentMethod.cod:
      return 'Cash on Delivery';
    case PaymentMethod.card:
      return 'Credit / Debit Card';
    case PaymentMethod.online:
      return 'Online Banking';
  }
}

class OrderTotals {
  final double subtotal;
  final double voucherDiscount;
  final double prepaidBonus;
  final double shipping;
  final double shippingDiscount;

  const OrderTotals({
    required this.subtotal,
    required this.voucherDiscount,
    required this.prepaidBonus,
    required this.shipping,
    required this.shippingDiscount,
  });

  double get total =>
      subtotal - voucherDiscount - prepaidBonus + shipping - shippingDiscount;
}

class Pricing {
  static const shippingFee = 100.0;
  static const codFreeShippingThreshold = 3000.0;
  static const prepaidBonusPercent = 3.0;
  static const prepaidBonusCap = 200.0;

  static bool isPrepaid(PaymentMethod m) => m != PaymentMethod.cod;

  static OrderTotals compute(
      double subtotal, PaymentMethod method, Voucher? voucher) {
    final vDisc = voucher?.discountFor(subtotal) ?? 0;
    final afterVoucher = subtotal - vDisc;

    var bonus = 0.0;
    if (isPrepaid(method)) {
      bonus = afterVoucher * prepaidBonusPercent / 100;
      if (bonus > prepaidBonusCap) bonus = prepaidBonusCap;
    }

    final shipDisc = (method == PaymentMethod.cod &&
            afterVoucher >= codFreeShippingThreshold)
        ? shippingFee
        : 0.0;

    return OrderTotals(
      subtotal: subtotal,
      voucherDiscount: vDisc,
      prepaidBonus: bonus,
      shipping: shippingFee,
      shippingDiscount: shipDisc,
    );
  }
}