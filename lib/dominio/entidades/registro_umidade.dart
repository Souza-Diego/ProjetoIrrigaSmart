class RegistroUmidade {
  final int id;
  final DateTime timestamp;
  final int valorPercentual;

  const RegistroUmidade({
    required this.id,
    required this.timestamp,
    required this.valorPercentual,
  });

  factory RegistroUmidade.fromJson(Map<String, dynamic> json) {
    return RegistroUmidade(
      id:              _toInt(json['id']),
      timestamp:       _toDateTime(json['timestamp']),
      valorPercentual: _toInt(json['valor_percentual']),
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static DateTime _toDateTime(dynamic v) {
    try { return DateTime.parse(v.toString()); } catch (_) { return DateTime.now(); }
  }
}