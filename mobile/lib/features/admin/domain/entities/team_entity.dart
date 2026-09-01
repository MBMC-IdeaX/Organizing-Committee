import 'package:equatable/equatable.dart';

class TeamEntity extends Equatable {
  final int id;
  final String teamName;
  final String projectName;
  final String? idea;
  final int displayOrder;
  final bool active;

  const TeamEntity({
    required this.id,
    required this.teamName,
    required this.projectName,
    this.idea,
    required this.displayOrder,
    required this.active,
  });

  @override
  List<Object?> get props => [id, teamName, projectName, idea, displayOrder, active];
}
