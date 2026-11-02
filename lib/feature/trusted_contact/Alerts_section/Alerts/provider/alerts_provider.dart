import 'package:flutter/material.dart';
import 'package:iwitnez/core/network/error/api_error_handler.dart';
import 'package:iwitnez/feature/trusted_contact/Alerts_section/Alerts/model/active_alert_model.dart';
import 'package:iwitnez/feature/trusted_contact/Alerts_section/Alerts/model/alert_history_model.dart';
import 'package:iwitnez/feature/trusted_contact/Alerts_section/Alerts/repository/alert_history_repository.dart';

export 'package:iwitnez/feature/trusted_contact/Alerts_section/Alerts/model/active_alert_model.dart';
export 'package:iwitnez/feature/trusted_contact/Alerts_section/Alerts/model/alert_history_model.dart';

class AlertsProvider extends ChangeNotifier {
  final AlertHistoryRepository _repository;

  AlertsProvider({AlertHistoryRepository? repository})
      : _repository = repository ?? AlertHistoryRepository();

  // Tabs: 0 = Active, 1 = History
  int _selectedTab = 0;
  int get selectedTab => _selectedTab;

  void selectTab(int index) {
    if (_selectedTab != index) {
      _selectedTab = index;
      notifyListeners();
      if (_selectedTab == 0) {
        fetchActiveAlert();
      } else if (_selectedTab == 1) {
        fetchAlertHistory();
      }
    }
  }

  // ===================== ACTIVE ALERT STATE =====================
  ActiveAlertModel? _activeAlert;
  ActiveAlertModel? get activeAlert => _activeAlert;

  bool _isActiveAlertLoading = false;
  bool get isActiveAlertLoading => _isActiveAlertLoading;

  String? _activeAlertError;
  String? get activeAlertError => _activeAlertError;

  /// Fetches the active emergency alert from GET /api/v1/emergency/alerts/active/
  Future<void> fetchActiveAlert() async {
    debugPrint('[AlertsProvider] Fetching active emergency alert...');
    _isActiveAlertLoading = true;
    _activeAlertError = null;
    notifyListeners();

    try {
      final response = await _repository.getActiveAlert();
      debugPrint(
        '[AlertsProvider] Active alert success: ${response.success}, hasAlert: ${response.data?.hasActiveAlert}',
      );
      if (response.success && response.data != null) {
        _activeAlert = response.data;
        _activeAlertError = null;
      } else {
        _activeAlert = response.data; // might be null or has_active_alert: false
        _activeAlertError = response.message.isNotEmpty
            ? response.message
            : 'Unable to retrieve active alert.';
      }
    } catch (e, st) {
      debugPrint('[AlertsProvider] Error loading active alert: $e\n$st');
      _activeAlertError = ApiErrorHandler.getMessage(e);
    } finally {
      _isActiveAlertLoading = false;
      notifyListeners();
    }
  }

  // ===================== HISTORY ALERT STATE =====================
  // History Filter: 'all', 'sos', 'video', 'audio'
  String _selectedFilter = 'all';
  String get selectedFilter => _selectedFilter;

  List<AlertHistoryModel> _historyAlerts = [];
  List<AlertHistoryModel> get historyAlerts => _historyAlerts;

  bool _isHistoryLoading = false;
  bool get isHistoryLoading => _isHistoryLoading;

  String? _historyError;
  String? get historyError => _historyError;

  /// Changes the active filter and re-fetches history
  void setFilter(String filter) {
    final normalized = filter.toLowerCase().trim();
    if (_selectedFilter != normalized) {
      _selectedFilter = normalized;
      notifyListeners();
      fetchAlertHistory(filter: normalized);
    }
  }

  /// Fetches alert history from GET /api/v1/emergency/alerts/history/?filter={filter}
  Future<void> fetchAlertHistory({String? filter}) async {
    final targetFilter = filter ?? _selectedFilter;
    debugPrint(
      '[AlertsProvider] Fetching alert history with filter: $targetFilter',
    );
    _isHistoryLoading = true;
    _historyError = null;
    notifyListeners();

    try {
      final response = await _repository.getAlertHistory(filter: targetFilter);
      debugPrint(
        '[AlertsProvider] History response success=${response.success}, count=${response.data.length}',
      );
      if (response.success) {
        _historyAlerts = response.data;
        _historyError = null;
      } else {
        _historyError = response.message.isNotEmpty
            ? response.message
            : 'Unable to retrieve alert history.';
      }
    } catch (e, st) {
      debugPrint('[AlertsProvider] Error loading history: $e\n$st');
      _historyError = ApiErrorHandler.getMessage(e);
    } finally {
      _isHistoryLoading = false;
      notifyListeners();
    }
  }
}
