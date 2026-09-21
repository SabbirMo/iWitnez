import 'package:flutter/foundation.dart';
import 'package:iwitnez/feature/main_user/Profile_section/Profile/model/profile_model.dart';

class ProfileProvider extends ChangeNotifier {
  UserProfile _profile = _dummyProfile;
  bool _isLoading = false;

  UserProfile get profile => _profile;
  bool get isLoading => _isLoading;

  Future<void> fetchProfile() async {
    _isLoading = true;
    notifyListeners();

    // TODO: replace with real API/local-db call
    await Future.delayed(const Duration(milliseconds: 300));
    _profile = _dummyProfile;

    _isLoading = false;
    notifyListeners();
  }

  static const UserProfile _dummyProfile = UserProfile(
    name: 'Sarah Khan',
    phone: '+880 1712 345678',
    avatarUrl: 'https://i.pravatar.cc/150?img=5',
    isOnline: true,
  );
}