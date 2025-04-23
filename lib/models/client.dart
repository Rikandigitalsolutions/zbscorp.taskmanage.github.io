class Client {
  final int id;
  final DateTime createdAt;
  final String clientName;

  Client({
    required this.id,
    required this.createdAt,
    required this.clientName,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      clientName: json['client_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'client_name': clientName,
    };
  }
}
