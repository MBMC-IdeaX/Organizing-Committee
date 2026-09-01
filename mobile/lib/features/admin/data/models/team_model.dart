import '../../../../core/utils/json_utils.dart';
import '../../domain/entities/team_entity.dart';

class TeamModel {
  final int id;
  final String teamName;
  final String projectName;
  final String? idea;
  final int displayOrder;
  final bool active;

  TeamModel({
    required this.id,
    required this.teamName,
    required this.projectName,
    this.idea,
    required this.displayOrder,
    required this.active,
  });

  factory TeamModel.fromJson(dynamic rawJson) {
    final json = asMap(rawJson);
    return TeamModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      teamName: json['teamName'] as String? ?? '',
      projectName: json['projectName'] as String? ?? '',
      idea: json['idea'] as String?,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      active: json['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teamName': teamName,
      'projectName': projectName,
      'idea': idea,
      'displayOrder': displayOrder,
    };
  }

  TeamEntity toEntity() {
    return TeamEntity(
      id: id,
      teamName: teamName,
      projectName: projectName,
      idea: idea,
      displayOrder: displayOrder,
      active: active,
    );
  }
}
