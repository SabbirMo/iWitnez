import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:iwitnez/feature/main_user/Profile_section/Profile/repository/profile_repository.dart';
import '../model/personal_info_model.dart';

class PersonalInfoState {
  final PersonalInfoModel userInfo;
  final bool isLoading;
  final bool isSaving;

  const PersonalInfoState({
    required this.userInfo,
    this.isLoading = false,
    this.isSaving = false,
  });

  PersonalInfoState copyWith({
    PersonalInfoModel? userInfo,
    bool? isLoading,
    bool? isSaving,
  }) {
    return PersonalInfoState(
      userInfo: userInfo ?? this.userInfo,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class PersonalInfoController extends StateNotifier<PersonalInfoState> {
  final ProfileRepository _repository;

  PersonalInfoController([ProfileRepository? repository])
    : _repository = repository ?? ProfileRepository(),
      super(
        PersonalInfoState(
          userInfo: ProfileRepository().cachedProfile != null
              ? PersonalInfoModel.fromResponse(
                  ProfileRepository().cachedProfile!,
                )
              : PersonalInfoModel(
                  fullName: '',
                  phoneNumber: '',
                  email: '',
                  dateOfBirth: '',
                  gender: '',
                  address: '',
                  profileImageUrl: '',
                ),
        ),
      ) {
    loadProfile();
  }

  // Pre-fill / load user profile from GET /api/v1/auth/me/
  Future<void> loadProfile({bool forceRefresh = false}) async {
    final cached = _repository.cachedProfile;
    if (cached != null) {
      state = state.copyWith(userInfo: PersonalInfoModel.fromResponse(cached));
    } else {
      state = state.copyWith(isLoading: true);
    }

    try {
      final profile = await _repository.getProfile(forceRefresh: forceRefresh);
      if (profile != null) {
        state = state.copyWith(
          userInfo: PersonalInfoModel.fromResponse(profile),
        );
      }
    } catch (e) {
      debugPrint('[PersonalInfoController] loadProfile error: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Hits PATCH /api/v1/auth/me/ to update personal information on backend
  Future<bool> saveProfile({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String dateOfBirth,
    required String gender,
    required String address,
    File? avatarFile,
  }) async {
    state = state.copyWith(isSaving: true);

    try {
      final formattedDob = _formatDateForApi(dateOfBirth);
      final formattedGender = _formatGenderForApi(gender);

      final updatedProfile = await _repository.updateProfile(
        fullName: fullName.trim(),
        phoneNumber: phoneNumber.trim(),
        email: email.trim(),
        dateOfBirth: formattedDob,
        gender: formattedGender,
        address: address.trim(),
        avatarFile: avatarFile,
      );

      if (updatedProfile != null) {
        state = state.copyWith(
          userInfo: PersonalInfoModel.fromResponse(updatedProfile),
          isSaving: false,
        );
        return true;
      }
      state = state.copyWith(isSaving: false);
      return false;
    } catch (e) {
      debugPrint('[PersonalInfoController] saveProfile error: $e');
      state = state.copyWith(isSaving: false);
      rethrow;
    }
  }

  static String _formatDateForApi(String dob) {
    final clean = dob.trim();
    if (clean.isEmpty) return '';
    final parsed = DateTime.tryParse(clean);
    if (parsed != null) {
      return '${parsed.year.toString().padLeft(4, '0')}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
    }
    final parts = clean.split(RegExp(r'\s+'));
    if (parts.length >= 3) {
      final day = int.tryParse(parts[0]) ?? 1;
      final monthStr = parts[1].toLowerCase();
      const monthNames = [
        'jan',
        'feb',
        'mar',
        'apr',
        'may',
        'jun',
        'jul',
        'aug',
        'sep',
        'oct',
        'nov',
        'dec',
      ];
      final monthIndex = monthNames.indexWhere((m) => monthStr.startsWith(m));
      if (monthIndex != -1) {
        final month = monthIndex + 1;
        final year = int.tryParse(parts[2]) ?? 1998;
        return '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
      }
    }
    return clean;
  }

  static String _formatGenderForApi(String g) {
    final lower = g.trim().toLowerCase();
    if (lower == 'female') return 'female';
    if (lower == 'male') return 'male';
    if (lower == 'other' || lower.contains('prefer') || lower.contains('not')) {
      return 'other';
    }
    if (lower.isNotEmpty) return 'other';
    return '';
  }
}
