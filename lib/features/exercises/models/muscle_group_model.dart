// One of the six muscle groups (chest, back, ...), in display order
class MuscleGroupModel {
  final String id;
  final String name;
  final int order;

  const MuscleGroupModel({
    required this.id,
    required this.name,
    this.order = 0,
  });

  factory MuscleGroupModel.fromMap(String id, Map<String, dynamic> map) {
    return MuscleGroupModel(
      id: id,
      name: map['name'] as String? ?? id,
      order: (map['order'] as num?)?.toInt() ?? 0,
    );
  }
}
