import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/results_summary_entity.dart';
import '../../domain/repositories/results_repository.dart';
import 'results_dashboard_state.dart';

class ResultsDashboardCubit extends Cubit<ResultsDashboardState> {
  final ResultsRepository _resultsRepository;

  ResultsDashboardCubit({required ResultsRepository resultsRepository})
      : _resultsRepository = resultsRepository,
        super(const ResultsDashboardInitial());

  Future<void> loadResultsDashboard() async {
    emit(const ResultsDashboardLoading());
    try {
      final summary = await _resultsRepository.getResultsSummary();
      if (!summary.resultsAvailable) {
        emit(ResultsDashboardNotReady(summary: summary));
      } else {
        try {
          final ranking = await _resultsRepository.getRanking();
          emit(ResultsDashboardLoaded(summary: summary, ranking: ranking));
        } on ConflictException catch (e) {
          if (e.errorCode == 'RESULTS_NOT_READY') {
            emit(ResultsDashboardNotReady(summary: summary));
          } else {
            emit(ResultsDashboardError(message: e.message));
          }
        } catch (e) {
          emit(ResultsDashboardError(message: _cleanErrorMessage(e)));
        }
      }
    } on ConflictException catch (e) {
      if (e.errorCode == 'RESULTS_NOT_READY') {
        emit(const ResultsDashboardNotReady(
          summary: ResultsSummaryEntity(
            totalTeams: 0,
            activeTeams: 0,
            totalJudges: 0,
            activeJudges: 0,
            totalCriteria: 0,
            activeCriteria: 0,
            totalPossibleScorePerJudge: 0,
            totalRequiredEvaluations: 0,
            completedEvaluations: 0,
            remainingEvaluations: 0,
            judgingCompletionPercentage: 0.0,
            judgingComplete: false,
            resultsAvailable: false,
          ),
        ));
      } else {
        emit(ResultsDashboardError(message: e.message));
      }
    } catch (e) {
      emit(ResultsDashboardError(message: _cleanErrorMessage(e)));
    }
  }

  String _cleanErrorMessage(dynamic error) {
    final str = error.toString();
    if (str.startsWith('Exception: ')) {
      return str.substring(11);
    }
    return str;
  }
}
