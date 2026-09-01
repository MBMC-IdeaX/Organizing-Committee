import 'package:equatable/equatable.dart';
import '../../domain/entities/results_summary_entity.dart';
import '../../domain/entities/ranking_result_entity.dart';

abstract class ResultsDashboardState extends Equatable {
  const ResultsDashboardState();

  @override
  List<Object?> get props => [];
}

class ResultsDashboardInitial extends ResultsDashboardState {
  const ResultsDashboardInitial();
}

class ResultsDashboardLoading extends ResultsDashboardState {
  const ResultsDashboardLoading();
}

class ResultsDashboardLoaded extends ResultsDashboardState {
  final ResultsSummaryEntity summary;
  final List<RankingResultEntity> ranking;

  const ResultsDashboardLoaded({
    required this.summary,
    required this.ranking,
  });

  @override
  List<Object?> get props => [summary, ranking];
}

class ResultsDashboardNotReady extends ResultsDashboardState {
  final ResultsSummaryEntity summary;

  const ResultsDashboardNotReady({
    required this.summary,
  });

  @override
  List<Object?> get props => [summary];
}

class ResultsDashboardError extends ResultsDashboardState {
  final String message;

  const ResultsDashboardError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}
