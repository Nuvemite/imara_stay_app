import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:imara_stay/features/host/models/host_dashboard_model.dart';
import 'package:imara_stay/features/host/repository/host_dashboard_repository.dart';

class HostDashboardState {
  const HostDashboardState({
    this.data,
    this.isLoading = false,
    this.error,
  });

  final HostDashboardModel? data;
  final bool isLoading;
  final String? error;

  HostDashboardState copyWith({
    HostDashboardModel? data,
    bool? isLoading,
    String? error,
  }) {
    return HostDashboardState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class HostDashboardController extends StateNotifier<HostDashboardState> {
  HostDashboardController(this._repository)
      : super(const HostDashboardState(isLoading: true)) {
    loadDashboard();
  }

  final HostDashboardRepository _repository;

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final data = await _repository.fetchDashboard();
      state = HostDashboardState(
        data: data,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = HostDashboardState(
        data: state.data,
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void refetch() => loadDashboard();
}

final hostDashboardProvider =
    StateNotifierProvider<HostDashboardController, HostDashboardState>((ref) {
  final repository = ref.watch(hostDashboardRepositoryProvider);
  return HostDashboardController(repository);
});
