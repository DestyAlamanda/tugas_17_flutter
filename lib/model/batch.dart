class Batch {
  final int id;
  final String batchKe; // contoh: "1", "2"

  Batch({required this.id, required this.batchKe});

  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(id: json['id'], batchKe: json['batch_ke'].toString());
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "batch_ke": batchKe};
  }

  @override
  String toString() => "Batch(id: $id, batchKe: $batchKe)";
}
