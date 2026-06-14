class Wallet {
  final String id;
  final String ownerId;
  final int balancePaise;
  final DateTime updatedAt;

  Wallet({
    required this.id,
    required this.ownerId,
    required this.balancePaise,
    required this.updatedAt,
  });

  double get balanceAmount => balancePaise / 100;

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'],
      ownerId: json['owner_id'],
      balancePaise: json['balance_paise'] ?? 0,
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class WalletTransaction {
  final String id;
  final String walletId;
  final int amountPaise;
  final String type; // credit, debit
  final String purpose; // booking_payment, referral_bonus, topup, withdrawal
  final String? referenceId;
  final DateTime createdAt;

  WalletTransaction({
    required this.id,
    required this.walletId,
    required this.amountPaise,
    required this.type,
    required this.purpose,
    this.referenceId,
    required this.createdAt,
  });

  double get amount => amountPaise / 100;

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'],
      walletId: json['wallet_id'],
      amountPaise: json['amount_paise'],
      type: json['type'],
      purpose: json['purpose'],
      referenceId: json['reference_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
