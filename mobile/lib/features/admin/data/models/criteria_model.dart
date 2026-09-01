import '../../../../core/utils/json_utils.dart';
import '../../domain/entities/criteria_entity.dart';

class CriteriaModel {
  final int id;
  final String name;
  final String? description;
  final int maxScore;
  final int displayOrder;
  final bool active;

  CriteriaModel({
    required this.id,
    required this.name,
    this.description,
    required this.maxScore,
    required this.displayOrder,
    required this.active,
  });

  factory CriteriaModel.fromJson(dynamic rawJson) {
    final json = asMap(rawJson);
    return CriteriaModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      maxScore: (json['maxScore'] as num?)?.toInt() ?? 0,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      active: json['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'maxScore': maxScore,
      'displayOrder': displayOrder,
    };
  }

  CriteriaEntity toEntity() {
    return CriteriaEntity(
      id: id,
      name: name,
      description: description,
      maxScore: maxScore,
      displayOrder: displayOrder,
      active: active,
    );
  }
}
