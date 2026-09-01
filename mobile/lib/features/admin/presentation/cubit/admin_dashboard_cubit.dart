import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/admin_repository.dart';
import 'admin_dashboard_state.dart';

class AdminDashboardCubit extends Cubit<AdminDashboardState> {
  final AdminRepository _adminRepository;

  AdminDashboardCubit({required AdminRepository adminRepository})
      : _adminRepository = adminRepository,
        super(const AdminDashboardInitial());

  Future<void> loadDashboardSummary() async {
    emit(const AdminDashboardLoading());
    try {
      final summary = await _adminRepository.getDashboardSummary();
      emit(AdminDashboardLoaded(summary: summary));
    } catch (e) {
      emit(AdminDashboardError(message: _cleanErrorMessage(e)));
    }
  }

  Future<bool> resetSystemData({
    required String adminPassword,
    bool clearJudgings = true,
    bool clearJudges = false,
    bool clearTeams = false,
  }) async {
    try {
      await _adminRepository.resetSystemData(
        adminPassword: adminPassword,
        clearJudgings: clearJudgings,
        clearJudges: clearJudges,
        clearTeams: clearTeams,
      );
      await loadDashboardSummary();
      return true;
    } catch (e) {
      rethrow;
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
