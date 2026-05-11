import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:imara_stay/features/host/models/host_booking_model.dart';
import 'package:imara_stay/features/host/repository/host_bookings_repository.dart';

class HostBookingsState {
  const HostBookingsState({
    this.bookings = const [],
    this.pagination,
    this.isLoading = false,
    this.error,
    this.selectedStatus = 'all',
    this.dateFrom,
    this.dateTo,
  });

  final List<HostBooking> bookings;
  final HostBookingsPagination? pagination;
  final bool isLoading;
  final String? error;
  final String selectedStatus;
  final String? dateFrom;
  final String? dateTo;
}

class HostBookingsController extends StateNotifier<HostBookingsState> {
  HostBookingsController(this._repository)
      : super(const HostBookingsState()) {
    loadBookings();
  }

  final HostBookingsRepository _repository;

  Future<void> loadBookings({int page = 1}) async {
    state = HostBookingsState(
      bookings: state.bookings,
      pagination: state.pagination,
      isLoading: true,
      error: null,
      selectedStatus: state.selectedStatus,
      dateFrom: state.dateFrom,
      dateTo: state.dateTo,
    );

    try {
      final result = await _repository.fetchBookings(
        status: state.selectedStatus == 'all' ? null : state.selectedStatus,
        dateFrom: state.dateFrom,
        dateTo: state.dateTo,
        page: page,
      );

      if (result != null) {
        final bookings = page == 1
            ? result.bookings
            : [...state.bookings, ...result.bookings];
        state = HostBookingsState(
          bookings: bookings,
          pagination: result.pagination,
          isLoading: false,
          error: null,
          selectedStatus: state.selectedStatus,
          dateFrom: state.dateFrom,
          dateTo: state.dateTo,
        );
      } else {
        state = HostBookingsState(
          bookings: [],
          pagination: null,
          isLoading: false,
          error: 'Failed to load bookings',
          selectedStatus: state.selectedStatus,
          dateFrom: state.dateFrom,
          dateTo: state.dateTo,
        );
      }
    } catch (e) {
      state = HostBookingsState(
        bookings: state.bookings,
        pagination: state.pagination,
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
        selectedStatus: state.selectedStatus,
        dateFrom: state.dateFrom,
        dateTo: state.dateTo,
      );
    }
  }

  void setStatusFilter(String status) {
    state = HostBookingsState(
      bookings: state.bookings,
      pagination: state.pagination,
      isLoading: state.isLoading,
      error: state.error,
      selectedStatus: status,
      dateFrom: state.dateFrom,
      dateTo: state.dateTo,
    );
    loadBookings(page: 1);
  }

  void setDateRange(String? from, String? to) {
    state = HostBookingsState(
      bookings: state.bookings,
      pagination: state.pagination,
      isLoading: state.isLoading,
      error: state.error,
      selectedStatus: state.selectedStatus,
      dateFrom: from,
      dateTo: to,
    );
    loadBookings(page: 1);
  }

  Future<bool> approveBooking(int id) async {
    final ok = await _repository.approveBooking(id);
    if (ok) loadBookings(page: 1);
    return ok;
  }

  Future<bool> rejectBooking(int id) async {
    final ok = await _repository.rejectBooking(id);
    if (ok) loadBookings(page: 1);
    return ok;
  }

  Future<bool> cancelBooking(int id) async {
    final ok = await _repository.cancelBooking(id);
    if (ok) loadBookings(page: 1);
    return ok;
  }

  Future<HostBooking?> loadBookingDetail(int id) async {
    return _repository.fetchBookingDetail(id);
  }
}

final hostBookingsProvider =
    StateNotifierProvider<HostBookingsController, HostBookingsState>((ref) {
  final repository = ref.watch(hostBookingsRepositoryProvider);
  return HostBookingsController(repository);
});
