import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../services/resellers_service.dart';

class ResellersListState {
  final List<Map<String, String>> items;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;
  final String query;
  final bool isInitialLoading;
  final bool isRefreshing;
  final bool isLoadingMore;
  final String? errorMessage;

  const ResellersListState({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
    required this.query,
    required this.isInitialLoading,
    required this.isRefreshing,
    required this.isLoadingMore,
    required this.errorMessage,
  });

  factory ResellersListState.initial() {
    return const ResellersListState(
      items: <Map<String, String>>[],
      currentPage: 1,
      lastPage: 1,
      total: 0,
      perPage: 20,
      query: '',
      isInitialLoading: true,
      isRefreshing: false,
      isLoadingMore: false,
      errorMessage: null,
    );
  }

  ResellersListState copyWith({
    List<Map<String, String>>? items,
    int? currentPage,
    int? lastPage,
    int? total,
    int? perPage,
    String? query,
    bool? isInitialLoading,
    bool? isRefreshing,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ResellersListState(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
      perPage: perPage ?? this.perPage,
      query: query ?? this.query,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final resellersServiceProvider = Provider<ResellersService>((ref) {
  return ResellersService();
});

final resellersSummaryProvider = FutureProvider<ResellersSummary>((ref) async {
  return ref.watch(resellersServiceProvider).fetchSummary();
});

class ResellersListController extends StateNotifier<ResellersListState> {
  final ResellersService _service;

  Timer? _searchDebounce;
  CancelToken? _cancelToken;

  static ResellersListState? _cachedState;

  ResellersListController(this._service) : super(ResellersListState.initial()) {
    final cache = _cachedState;
    if (cache != null && cache.items.isNotEmpty) {
      state = cache.copyWith(
        isInitialLoading: false,
        isRefreshing: true,
        clearError: true,
      );
      unawaited(fetchPage(
        page: cache.currentPage,
        perPage: cache.perPage,
        query: cache.query,
        loadingMode: _LoadingMode.refresh,
      ));
    } else {
      unawaited(fetchPage(loadingMode: _LoadingMode.initial));
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _cancelToken?.cancel('Disposed');
    super.dispose();
  }

  Future<void> retry() async {
    await fetchPage(
      page: state.currentPage,
      perPage: state.perPage,
      query: state.query,
      loadingMode: state.items.isEmpty ? _LoadingMode.initial : _LoadingMode.refresh,
    );
  }

  Future<void> refreshCurrentPage() async {
    await fetchPage(
      page: state.currentPage,
      perPage: state.perPage,
      query: state.query,
      loadingMode: _LoadingMode.refresh,
    );
  }

  void onSearchChanged(String value) {
    state = state.copyWith(query: value, clearError: true);
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      unawaited(fetchPage(
        page: 1,
        perPage: state.perPage,
        query: value,
        loadingMode: _LoadingMode.refresh,
      ));
    });
  }

  Future<void> changePerPage(int perPage) async {
    await fetchPage(
      page: 1,
      perPage: perPage,
      query: state.query,
      loadingMode: _LoadingMode.refresh,
    );
  }

  Future<void> goToPage(int page) async {
    if (page < 1 || page > state.lastPage) {
      return;
    }

    final mode = page > state.currentPage ? _LoadingMode.pageChange : _LoadingMode.refresh;
    await fetchPage(
      page: page,
      perPage: state.perPage,
      query: state.query,
      loadingMode: mode,
    );
  }

  Future<void> fetchPage({
    int? page,
    int? perPage,
    String? query,
    _LoadingMode loadingMode = _LoadingMode.refresh,
  }) async {
    _cancelToken?.cancel('New request started');
    _cancelToken = CancelToken();

    final targetPage = page ?? state.currentPage;
    final targetPerPage = perPage ?? state.perPage;
    final targetQuery = query ?? state.query;

    if (loadingMode == _LoadingMode.initial) {
      state = state.copyWith(isInitialLoading: true, clearError: true);
    } else if (loadingMode == _LoadingMode.pageChange) {
      state = state.copyWith(isLoadingMore: true, clearError: true);
    } else {
      state = state.copyWith(isRefreshing: true, clearError: true);
    }

    try {
      final response = await _service.fetchResellersPage(
        page: targetPage,
        perPage: targetPerPage,
        q: targetQuery,
        cancelToken: _cancelToken,
      );

      final nextState = state.copyWith(
        items: response.data,
        currentPage: response.currentPage,
        lastPage: response.lastPage,
        total: response.total,
        perPage: targetPerPage,
        query: targetQuery,
        isInitialLoading: false,
        isRefreshing: false,
        isLoadingMore: false,
        clearError: true,
      );

      state = nextState;
      _cachedState = nextState;
    } on ApiException catch (e) {
      if (e.isCancelled) {
        return;
      }
      state = state.copyWith(
        isInitialLoading: false,
        isRefreshing: false,
        isLoadingMore: false,
        errorMessage: _mapErrorMessage(e),
      );
    } catch (_) {
      state = state.copyWith(
        isInitialLoading: false,
        isRefreshing: false,
        isLoadingMore: false,
        errorMessage: 'Unexpected error occurred. Please try again.',
      );
    }
  }

  String _mapErrorMessage(ApiException e) {
    final code = e.statusCode;
    if (code == 401) {
      return 'Unauthorized. Please log in again.';
    }
    if (code == 404) {
      return 'Requested data was not found.';
    }
    if (code == 422) {
      return e.message.isNotEmpty ? e.message : 'Validation failed.';
    }
    if (code == 500) {
      return 'Server error. Please try again later.';
    }
    return e.message;
  }
}

enum _LoadingMode { initial, refresh, pageChange }

final resellersListControllerProvider =
    StateNotifierProvider<ResellersListController, ResellersListState>((ref) {
  return ResellersListController(ref.watch(resellersServiceProvider));
});

final resellersDataProvider = FutureProvider<List<Map<String, String>>>((ref) async {
  final page = await ref.watch(resellersServiceProvider).fetchResellersPage(page: 1, perPage: 20);
  return page.data;
});

/// Provider for adding a reseller
final addResellerProvider =
    FutureProvider.autoDispose.family<void, Map<String, String>>((ref, resellerData) async {
  await ref.watch(resellersServiceProvider).addReseller(
        companyName: resellerData['companyName'] ?? '',
        address: resellerData['address'] ?? '',
        email: resellerData['email'] ?? '',
        phoneNumber: resellerData['phoneNumber'] ?? '',
      );
});
