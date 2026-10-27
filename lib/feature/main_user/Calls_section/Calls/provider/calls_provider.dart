import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:iwitnez/feature/main_user/Calls_section/Calls/model/calls_model.dart';
import 'package:iwitnez/feature/main_user/Calls_section/Calls/repository/calls_repository.dart';

enum CallFilterTab { all, missed, recent }

class CallsProvider extends ChangeNotifier {
  CallsProvider({CallsRepository? callsRepository})
      : _callsRepository = callsRepository ?? CallsRepository();

  final CallsRepository _callsRepository;

  List<CallRecordItem> _calls = [];
  bool _isLoading = false;
  String _searchQuery = '';
  CallFilterTab _currentTab = CallFilterTab.all;
  String? _errorMessage;
  Timer? _debounceTimer;

  CallFilterTab get currentTab => _currentTab;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get errorMessage => _errorMessage;
  List<CallRecordItem> get calls => _calls;

  String get sectionTitle {
    switch (_currentTab) {
      case CallFilterTab.missed:
        return 'Missed calls';
      case CallFilterTab.recent:
      case CallFilterTab.all:
        return 'Recent calls';
    }
  }

  void setTab(CallFilterTab tab) {
    if (_currentTab == tab) return;
    _currentTab = tab;
    notifyListeners();
    fetchCalls();
  }

  /// 300ms debounced search on the Search Call input field
  void search(String query) {
    _searchQuery = query;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      fetchCalls();
    });
  }

  /// Fetch call logs with tab filtering ('all', 'missed', 'recent') and search
  Future<void> fetchCalls() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final tabParam = _currentTab.name; // 'all', 'missed', 'recent'
      final result = await _callsRepository.fetchCallHistory(
        tab: tabParam,
        search: _searchQuery,
      );

      _calls = result;
      _errorMessage = null;
    } catch (e) {
      debugPrint('[CallsProvider] Failed to fetch calls from API: $e. Using local fallback.');
      _errorMessage = e.toString();
      _calls = _filterFallbackCalls();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Local fallback filter when backend is offline
  List<CallRecordItem> _filterFallbackCalls() {
    List<CallRecordItem> list = _dummyCalls;
    if (_currentTab == CallFilterTab.missed) {
      list = list.where((c) => c.isMissed).toList();
    } else if (_currentTab == CallFilterTab.recent) {
      // Calls from the last 7 days
      final now = DateTime.now();
      list = list.where((c) {
        if (c.startedAt == null) return true;
        return now.difference(c.startedAt!).inDays <= 7;
      }).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list
          .where((c) =>
              c.contactName.toLowerCase().contains(q) ||
              c.contactPhone.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  /// Initiate call trigger
  Future<String?> initiateCall({
    required String contactName,
    required String contactPhone,
    required String callType,
    String? receiverId,
  }) async {
    return _callsRepository.initiateCall(
      contactName: contactName,
      contactPhone: contactPhone,
      callType: callType,
      receiverId: receiverId,
    );
  }

  /// End call trigger
  Future<bool> endCall(String callId, int durationSeconds) async {
    return _callsRepository.endCall(callId, durationSeconds: durationSeconds);
  }

  /// Respond to incoming call
  Future<bool> respondCall(String callId, bool accept) async {
    return _callsRepository.respondCall(callId, accept: accept);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  static final List<CallRecordItem> _dummyCalls = [
    CallRecordItem(
      id: '7f09c852-2591-4c5a-bf19-0f66e01a1111',
      contactName: 'Sarah Khan',
      contactPhone: '+12025550188',
      contactAvatarUrl: 'https://i.pravatar.cc/150?img=5',
      callType: 'video',
      status: 'completed',
      durationSeconds: 754,
      formattedDuration: '12:34',
      isOutgoing: true,
      startedAt: DateTime.now().subtract(const Duration(minutes: 42)),
    ),
    CallRecordItem(
      id: 'c8821044-3841-4712-ba22-832104992222',
      contactName: 'Ali Raza',
      contactPhone: '+12025550199',
      contactAvatarUrl: 'https://i.pravatar.cc/150?img=12',
      callType: 'video',
      status: 'missed',
      durationSeconds: 0,
      formattedDuration: '00:00',
      isOutgoing: false,
      startedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    CallRecordItem(
      id: 'd9910f81-5f21-4fae-9d22-127bcf833333',
      contactName: 'Mom',
      contactPhone: '+12025550177',
      contactAvatarUrl: 'https://i.pravatar.cc/150?img=32',
      callType: 'audio',
      status: 'completed',
      durationSeconds: 496,
      formattedDuration: '08:16',
      isOutgoing: true,
      startedAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    ),
    CallRecordItem(
      id: 'e2210f81-5f21-4fae-9d22-127bcf844444',
      contactName: 'Dad',
      contactPhone: '+12025550166',
      contactAvatarUrl: 'https://i.pravatar.cc/150?img=68',
      callType: 'video',
      status: 'completed',
      durationSeconds: 321,
      formattedDuration: '05:21',
      isOutgoing: true,
      startedAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
    ),
    CallRecordItem(
      id: 'a11cd911-3841-4712-ba22-998811224444',
      contactName: 'Anika',
      contactPhone: '+12025550144',
      contactAvatarUrl: 'https://i.pravatar.cc/150?img=9',
      callType: 'audio',
      status: 'missed',
      durationSeconds: 0,
      formattedDuration: '00:00',
      isOutgoing: false,
      startedAt: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
    ),
    CallRecordItem(
      id: 'b55cd911-3841-4712-ba22-998811225555',
      contactName: 'Rohan Mehta',
      contactPhone: '+12025550133',
      contactAvatarUrl: 'https://i.pravatar.cc/150?img=53',
      callType: 'audio',
      status: 'completed',
      durationSeconds: 227,
      formattedDuration: '03:47',
      isOutgoing: true,
      startedAt: DateTime.now().subtract(const Duration(days: 1, hours: 9)),
    ),
    CallRecordItem(
      id: 'c77cd911-3841-4712-ba22-998811226666',
      contactName: 'Priya Patel',
      contactPhone: '+12025550122',
      contactAvatarUrl: 'https://i.pravatar.cc/150?img=44',
      callType: 'video',
      status: 'completed',
      durationSeconds: 662,
      formattedDuration: '11:02',
      isOutgoing: true,
      startedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];
}