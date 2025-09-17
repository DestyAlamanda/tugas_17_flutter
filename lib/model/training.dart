class Training {
  final int id;
  final String title;

  Training({required this.id, required this.title});

  factory Training.fromJson(Map<String, dynamic> json) {
    return Training(id: json['id'], title: json['title'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "title": title};
  }

  @override
  String toString() => "Training(id: $id, title: $title)";
}
