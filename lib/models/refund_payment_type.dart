enum RefundPaymentType { cash, card, check }

extension RefundPaymentTypeLabel on RefundPaymentType {
  String get label {
    switch (this) {
      case RefundPaymentType.cash:
        return 'Cash';
      case RefundPaymentType.card:
        return 'Card';
      case RefundPaymentType.check:
        return 'Check';
    }
  }
}
