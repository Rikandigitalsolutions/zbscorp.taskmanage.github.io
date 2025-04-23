class BillingFirm {
  final int id;
  final String billingFirm;
  final DateTime createdAt;

  BillingFirm({
    required this.id,
    required this.billingFirm,
    required this.createdAt,
  });

  factory BillingFirm.fromJson(Map<String, dynamic> json) {
    return BillingFirm(
      id: json['id'],
      billingFirm: json['billingfirm'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'billing_firm': billingFirm,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
