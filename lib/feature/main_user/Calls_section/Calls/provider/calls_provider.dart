import 'package:flutter/foundation.dart';
import 'package:iwitnez/feature/main_user/Calls_section/Calls/model/calls_model.dart';



class CallsProvider extends ChangeNotifier {
  List<CallLogEntry> _calls = _dummyCalls;
  bool _isLoading = false;
  String _searchQuery = '';

  List<CallLogEntry> get calls => _searchQuery.isEmpty
      ? _calls
      : _calls
          .where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();

  bool get isLoading => _isLoading;

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchCalls() async {
    _isLoading = true;
    notifyListeners();

    // TODO: replace with real API/local-db call
    await Future.delayed(const Duration(milliseconds: 400));
    _calls = _dummyCalls;

    _isLoading = false;
    notifyListeners();
  }

  static final List<CallLogEntry> _dummyCalls = [
    const CallLogEntry(
      name: 'Sarah Khan',
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
      time: '9:18 AM',
      direction: CallDirection.incoming,
      type: CallType.voice,
    ),
    const CallLogEntry(
      name: 'Ali Raza',
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
      time: '8:45 AM',
      direction: CallDirection.outgoing,
      type: CallType.video,
    ),
    const CallLogEntry(
      name: 'Mom',
      avatarUrl: 'https://i.pravatar.cc/150?img=32',
      time: 'Yesterday',
      direction: CallDirection.missed,
      type: CallType.voice,
      callCount: 2,
    ),
    const CallLogEntry(
      name: 'Brother',
      avatarUrl: 'https://i.pravatar.cc/150?img=15',
      time: 'Yesterday',
      direction: CallDirection.outgoing,
      type: CallType.voice,
    ),
    const CallLogEntry(
      name: 'Anika',
      avatarUrl: 'https://i.pravatar.cc/150?img=9',
      time: 'Mon',
      direction: CallDirection.incoming,
      type: CallType.video,
    ),
  ];
}