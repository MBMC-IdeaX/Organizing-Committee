import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/judge_repository.dart';
import 'judge_dashboard_state.dart';

class JudgeDashboardCubit extends Cubit<JudgeDashboardState> {
  final JudgeRepository _judgeRepository;

  JudgeDashboardCubit({required JudgeRepository judgeRepository})
      : _judgeRepository = judgeRepository,
        super(const JudgeDashboardInitial());

  Future<void> loadDashboard() async {
    emit(const JudgeDashboardLoading());
    try {
      final dashboard = await _judgeRepository.getDashboard();
      final teams = await _judgeRepository.getTeams();
      emit(JudgeDashboardLoaded(dashboard: dashboard, teams: teams));
    } catch (e) {
      emit(JudgeDashboardError(message: _cleanErrorMessage(e)));
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
