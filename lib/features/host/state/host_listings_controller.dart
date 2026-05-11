import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:imara_stay/features/host/models/host_listing_model.dart';
import 'package:imara_stay/features/host/repository/host_listings_repository.dart';

class HostListingsState {
  const HostListingsState({
    this.listings = const [],
    this.countsByStatus = const {},
    this.countsByType = const {},
    this.pagination,
    this.isLoading = false,
    this.error,
    this.selectedStatus = 'all',
  });

  final List<HostListing> listings;
  final Map<String, int> countsByStatus;
  final Map<String, int> countsByType;
  final HostListingsPagination? pagination;
  final bool isLoading;
  final String? error;
  final String selectedStatus;
}

class HostListingsController extends StateNotifier<HostListingsState> {
  HostListingsController(this._repository)
      : super(const HostListingsState()) {
    loadListings();
  }

  final HostListingsRepository _repository;

  Future<void> loadListings({int page = 1}) async {
    state = HostListingsState(
      listings: state.listings,
      countsByStatus: state.countsByStatus,
      countsByType: state.countsByType,
      pagination: state.pagination,
      isLoading: true,
      error: null,
      selectedStatus: state.selectedStatus,
    );

    try {
      final result = await _repository.fetchListings(
        status: state.selectedStatus == 'all' ? null : state.selectedStatus,
        page: page,
      );

      if (result != null) {
        final listings = page == 1
            ? result.listings
            : [...state.listings, ...result.listings];
        state = HostListingsState(
          listings: listings,
          countsByStatus: result.countsByStatus,
          countsByType: result.countsByType,
          pagination: result.pagination,
          isLoading: false,
          error: null,
          selectedStatus: state.selectedStatus,
        );
      } else {
        state = HostListingsState(
          listings: [],
          countsByStatus: {},
          countsByType: {},
          pagination: null,
          isLoading: false,
          error: 'Failed to load listings',
          selectedStatus: state.selectedStatus,
        );
      }
    } catch (e) {
      state = HostListingsState(
        listings: state.listings,
        countsByStatus: state.countsByStatus,
        countsByType: state.countsByType,
        pagination: state.pagination,
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
        selectedStatus: state.selectedStatus,
      );
    }
  }

  void setStatusFilter(String status) {
    state = HostListingsState(
      listings: state.listings,
      countsByStatus: state.countsByStatus,
      countsByType: state.countsByType,
      pagination: state.pagination,
      isLoading: state.isLoading,
      error: state.error,
      selectedStatus: status,
    );
    loadListings(page: 1);
  }

  Future<bool> changeListingStatus(int id, String statusSlug) async {
    final ok = await _repository.updateStatus(id, statusSlug);
    if (ok) loadListings(page: 1);
    return ok;
  }

  Future<bool> deleteListing(int id) async {
    final ok = await _repository.deleteListing(id);
    if (ok) loadListings(page: 1);
    return ok;
  }
}

final hostListingsProvider =
    StateNotifierProvider<HostListingsController, HostListingsState>((ref) {
  final repository = ref.watch(hostListingsRepositoryProvider);
  return HostListingsController(repository);
});
