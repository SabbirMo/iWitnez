import 'package:flutter/foundation.dart';
import 'package:iwitnez/feature/main_user/Calls_section/Calls/model/calls_model.dart';

enum CallFilterTab { all, missed, recent }

class CallsProvider extends ChangeNotifier {
  List<CallLogEntry> _calls = _dummyCalls;
  bool _isLoading = false;
  String _searchQuery = '';
  CallFilterTab _currentTab = CallFilterTab.all;

  CallFilterTab get currentTab => _currentTab;

  List<CallLogEntry> get calls {
    List<CallLogEntry> list = _calls;
    if (_currentTab == CallFilterTab.missed) {
      list = list.where((c) => c.direction == CallDirection.missed).toList();
    }
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    return list;
  }

  bool get isLoading => _isLoading;

  void setTab(CallFilterTab tab) {
    if (_currentTab == tab) return;
    _currentTab = tab;
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchCalls() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));
    _calls = _dummyCalls;

    _isLoading = false;
    notifyListeners();
  }

  static final List<CallLogEntry> _dummyCalls = [
    const CallLogEntry(
      name: 'Sarah Khan',
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
      date: 'Today',
      time: '10:45 AM',
      direction: CallDirection.outgoing,
      type: CallType.video,
      duration: '12:34',
    ),
    const CallLogEntry(
      name: 'Ali Raza',
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
      date: 'Today',
      time: '9:20 AM',
      direction: CallDirection.missed,
      type: CallType.video,
    ),
    const CallLogEntry(
      name: 'Mom',
      avatarUrl: 'https://i.pravatar.cc/150?img=32',
      date: 'Yesterday',
      time: '8:15 PM',
      direction: CallDirection.outgoing,
      type: CallType.voice,
      duration: '08:16',
    ),
    const CallLogEntry(
      name: 'Dad',
      avatarUrl: 'https://i.pravatar.cc/150?img=68',
      date: 'Yesterday',
      time: '6:30 PM',
      direction: CallDirection.outgoing,
      type: CallType.video,
      duration: '05:21',
    ),
    const CallLogEntry(
      name: 'Anika',
      avatarUrl: 'https://i.pravatar.cc/150?img=9',
      date: 'Yesterday',
      time: '4:10 PM',
      direction: CallDirection.missed,
      type: CallType.voice,
    ),
    const CallLogEntry(
      name: 'Rohan Mehta',
      avatarUrl: 'https://i.pravatar.cc/150?img=53',
      date: 'Yesterday',
      time: '1:20 PM',
      direction: CallDirection.outgoing,
      type: CallType.voice,
      duration: '03:47',
    ),
    const CallLogEntry(
      name: 'Priya Patel',
      avatarUrl: 'https://i.pravatar.cc/150?img=44',
      date: 'Mon',
      time: '9:30 PM',
      direction: CallDirection.outgoing,
      type: CallType.video,
      duration: '11:02',
    ),
  ];
}