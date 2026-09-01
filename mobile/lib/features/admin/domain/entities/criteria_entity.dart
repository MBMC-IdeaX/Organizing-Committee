import 'package:equatable/equatable.dart';

class CriteriaEntity extends Equatable {
  final int id;
  final String name;
  final String? description;
  final int maxScore;
  final int displayOrder;
  final bool active;

  const CriteriaEntity({
    required this.id,
    required this.name,
    this.description,
    required this.maxScore,
    required this.displayOrder,
    required this.active,
  });

  @override
  List<Object?> get props => [id, name, description, maxScore, displayOrder, active];
}
