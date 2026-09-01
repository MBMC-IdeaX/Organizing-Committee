import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/results_repository.dart';
import 'team_result_state.dart';

class TeamResultCubit extends Cubit<TeamResultState> {
  final ResultsRepository _resultsRepository;

  TeamResultCubit({required ResultsRepository resultsRepository})
      : _resultsRepository = resultsRepository,
        super(const TeamResultInitial());

  Future<void> loadTeamResult(int teamId) async {
    emit(const TeamResultLoading());
    try {
      final result = await _resultsRepository.getTeamResult(teamId);
      emit(TeamResultLoaded(teamResult: result));
    } catch (e) {
      emit(TeamResultError(message: _cleanErrorMessage(e)));
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
