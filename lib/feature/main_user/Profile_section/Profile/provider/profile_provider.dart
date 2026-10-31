import 'package:flutter/foundation.dart';
import 'package:iwitnez/feature/main_user/Profile_section/Profile/model/profile_model.dart';
import 'package:iwitnez/feature/main_user/Profile_section/Profile/model/user_profile_response_model.dart';
import 'package:iwitnez/feature/main_user/Profile_section/Profile/repository/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repository;
  UserProfile _profile = _initialProfile;
  UserProfileResponseModel? _rawProfile;
  bool _isLoading = false;

  ProfileProvider([ProfileRepository? repository])
      : _repository = repository ?? ProfileRepository() {
    final cached = _repository.cachedProfile;
    if (cached != null) {
      _rawProfile = cached;
      _profile = UserProfile.fromResponse(cached);
    }
  }

  UserProfile get profile => _profile;
  UserProfileResponseModel? get rawProfile => _rawProfile;
  bool get isLoading => _isLoading;

  Future<void> fetchProfile({bool forceRefresh = false}) async {
    if (_rawProfile == null) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final data = await _repository.getProfile(forceRefresh: forceRefresh);
      if (data != null) {
        _rawProfile = data;
        _profile = UserProfile.fromResponse(data);
      }
    } catch (e) {
      debugPrint('[ProfileProvider] fetchProfile error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  static const UserProfile _initialProfile = UserProfile(
    name: '',
    phone: '',
    avatarUrl: '',
    isOnline: false,
  );
}
