import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/core/network/api_endpoint/api_end_point.dart';
import 'package:iwitnez/core/network/service/api_services.dart';
import 'package:iwitnez/feature/main_user/Profile_section/Profile/model/user_profile_response_model.dart';

class ProfileRepository {
  static final ProfileRepository _instance = ProfileRepository._internal(
    ApiServices(),
  );

  factory ProfileRepository([ApiServices? apiServices]) {
    if (apiServices != null) {
      return ProfileRepository._internal(apiServices);
    }
    return _instance;
  }

  ProfileRepository._internal(this._apiServices);

  final ApiServices _apiServices;
  UserProfileResponseModel? _cachedProfile;

  UserProfileResponseModel? get cachedProfile => _cachedProfile;

  void clearCache() {
    _cachedProfile = null;
  }

  /// Fetches user profile from GET /api/v1/auth/me/
  Future<UserProfileResponseModel?> getProfile({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cachedProfile != null) {
      return _cachedProfile;
    }

    try {
      final response = await _apiServices.get(
        ApiEndPoints.getProfile,
        requireAuth: true,
      );

      final data = response.data?['data'];
      if (data is Map<String, dynamic>) {
        final profile = UserProfileResponseModel.fromJson(data);
        _cachedProfile = profile;
        return profile;
      }
      return _cachedProfile;
    } catch (e) {
      debugPrint('[ProfileRepository] Error fetching profile: $e');
      return _cachedProfile;
    }
  }

  /// Updates user profile via PATCH /api/v1/auth/me/
  /// Supports both application/json and multipart/form-data (when avatarFile is provided)
  Future<UserProfileResponseModel?> updateProfile({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String dateOfBirth,
    required String gender,
    required String address,
    File? avatarFile,
  }) async {
    dynamic requestData;
    if (avatarFile != null && await avatarFile.exists()) {
      final fileName = avatarFile.path.split(Platform.pathSeparator).last;
      final map = <String, dynamic>{
        'full_name': fullName,
        'phone_number': phoneNumber,
        'email': email,
        'address': address,
        'avatar': await MultipartFile.fromFile(
          avatarFile.path,
          filename: fileName,
        ),
      };
      if (dateOfBirth.isNotEmpty) {
        map['date_of_birth'] = dateOfBirth;
      }
      if (gender.isNotEmpty) {
        map['gender'] = gender;
      }
      requestData = FormData.fromMap(map);
    } else {
      final map = <String, dynamic>{
        'full_name': fullName,
        'phone_number': phoneNumber,
        'email': email,
        'address': address,
      };
      if (dateOfBirth.isNotEmpty) {
        map['date_of_birth'] = dateOfBirth;
      }
      if (gender.isNotEmpty) {
        map['gender'] = gender;
      }
      requestData = map;
    }

    final response = await _apiServices.patch(
      ApiEndPoints.getProfile,
      data: requestData,
      requireAuth: true,
    );

    final data = response.data?['data'];
    if (data is Map<String, dynamic>) {
      final profile = UserProfileResponseModel.fromJson(data);
      _cachedProfile = profile;
      return profile;
    }
    return _cachedProfile;
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});
