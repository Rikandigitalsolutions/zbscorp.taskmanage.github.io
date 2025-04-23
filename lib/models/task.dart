class Task {
  final int? id;
  final DateTime entryDate;
  final DateTime dueDate;
  final String natureOfWork;
  final String workCategory;
  final String priority;
  final String clientName;
  final String assignedTo;
  final double amount;
  final double? turnover;
  final String? billedFromFirm;
  final String? billStatus;
  final String? billInvoice;
  final DateTime? paymentReceivedDate;
  final String taskStatus;
  final String? reviewStatus;
  final String? paymentReceiptStatus;
  final bool active;

  Task({
    this.id,
    required this.entryDate,
    required this.dueDate,
    required this.natureOfWork,
    required this.workCategory,
    required this.priority,
    required this.clientName,
    required this.assignedTo,
    required this.amount,
    this.turnover,
    this.billedFromFirm,
    this.billStatus,
    this.billInvoice,
    this.paymentReceivedDate,
    required this.taskStatus,
    this.reviewStatus,
    this.paymentReceiptStatus,
    required this.active,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      entryDate: DateTime.parse(json['EntryDate']),
      dueDate: DateTime.parse(json['DueDate']),
      natureOfWork: json['NatureOfWork'],
      workCategory: json['WorkCategory'],
      priority: json['Priority'],
      clientName: json['ClientName'],
      assignedTo: json['AssignedTo'],
      amount: (json['Amount'] as num).toDouble(),
      turnover: json['Turnover'] == null
          ? null
          : (json['Turnover'] as num).toDouble(),
      billedFromFirm: json['BilledFromFirm'],
      billStatus: json['BillStatus'],
      billInvoice: json['BillInvoice'],
      paymentReceivedDate: json['PaymentReceivedDate'] != null
          ? DateTime.parse(json['PaymentReceivedDate'])
          : null,
      taskStatus: json['TaskStatus'],
      reviewStatus: json['ReviewStatus'],
      paymentReceiptStatus: json['PaymentReceiptStatus'],
      active: json['Active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'EntryDate': entryDate.toIso8601String(),
      'DueDate': dueDate.toIso8601String(),
      'NatureOfWork': natureOfWork,
      'WorkCategory': workCategory,
      'Priority': priority,
      'ClientName': clientName,
      'AssignedTo': assignedTo,
      'Amount': amount,
      'Turnover': turnover,
      'BilledFromFirm': billedFromFirm,
      'BillStatus': billStatus,
      'BillInvoice': billInvoice,
      'PaymentReceivedDate': paymentReceivedDate?.toIso8601String(),
      'TaskStatus': taskStatus,
      'ReviewStatus': reviewStatus,
      'PaymentReceiptStatus': paymentReceiptStatus,
      'Active': active,
    };
  }

  Map<String, dynamic> toJsonForInsert() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  int get daysPass => DateTime.now().difference(entryDate).inDays;

  int get daysRemaining {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    return difference < 0 ? 0 : difference;
  }

  String? get displayTurnover =>
      taskStatus == 'Completed' ? amount.toStringAsFixed(2) : null;

  String get displayReviewStatus {
    if (taskStatus == 'Completed' && reviewStatus == null) {
      return 'In Progress';
    }
    return reviewStatus ?? '';
  }

  String get displayBillStatus {
    if (taskStatus == 'Completed' && reviewStatus == 'Completed') {
      return 'Bill sent to Client';
    }
    return billStatus ?? '';
  }
}
