
class TransactionCustom {
  int? id;
  String name;
  double point;
  int createdMillis;
  int? status;

  TransactionCustom({this.id, required this.name, required this.point, required this.createdMillis, status = 0});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'point': point,
      'createdMillis': createdMillis,
      'status': status
    };
  }

  @override
  String toString() {
    return 'TransactionCustom{id: $id, name: $name, point: $point, createdMillis: $createdMillis, status: $status}';
  }
}