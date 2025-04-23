class Employee {
  final int id;
  final DateTime createdAt;
  final String employeeName;
  final bool active;

  Employee({
    required this.id,
    required this.createdAt,
    required this.employeeName,
    required this.active,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      employeeName: json['employee_name'],
      active: json['active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'employee_name': employeeName,
      'active': active,
    };
  }
}
