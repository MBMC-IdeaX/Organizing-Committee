import 'package:equatable/equatable.dart';
import '../../domain/entities/admin_summary_entity.dart';

abstract class AdminDashboardState extends Equatable {
  const AdminDashboardState();

  @override
  List<Object?> get props => [];
}

class AdminDashboardInitial extends AdminDashboardState {
  const AdminDashboardInitial();
}

class AdminDashboardLoading extends AdminDashboardState {
  const AdminDashboardLoading();
}

class AdminDashboardLoaded extends AdminDashboardState {
  final AdminSummaryEntity summary;

  const AdminDashboardLoaded({required this.summary});

  @override
  List<Object?> get props => [summary];
}

class AdminDashboardError extends AdminDashboardState {
  final String message;

  const AdminDashboardError({required this.message});

  @override
  List<Object?> get props => [message];
}
