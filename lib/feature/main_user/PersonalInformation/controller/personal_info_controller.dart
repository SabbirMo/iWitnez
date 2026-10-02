import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../model/personal_info_model.dart';

class PersonalInfoState {
  final PersonalInfoModel userInfo;
  final bool isEditing;

  PersonalInfoState({required this.userInfo, this.isEditing = false});

  PersonalInfoState copyWith({PersonalInfoModel? userInfo, bool? isEditing}) {
    return PersonalInfoState(
      userInfo: userInfo ?? this.userInfo,
      isEditing: isEditing ?? this.isEditing,
    );
  }
}

class PersonalInfoController extends StateNotifier<PersonalInfoState> {
  PersonalInfoController()
    : super(
        PersonalInfoState(
          userInfo: PersonalInfoModel(
            fullName: 'Sarah Khan',
            phoneNumber: '+880 1712 345678',
            email: 'sarah.khan@email.com',
            dateOfBirth: '12 May 1998',
            gender: 'Female',
            address: 'House 10, Road 5, Dhanmondi,\nDhaka 1205, Bangladesh',
            // Using a placeholder network image
            profileImageUrl: 'https://i.pravatar.cc/150?img=5',
          ),
        ),
      );

  // Update all personal information at once upon save
  void updateUserInfo({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String dateOfBirth,
    required String gender,
    required String address,
    String? profileImageUrl,
  }) {
    state = state.copyWith(
      userInfo: state.userInfo.copyWith(
        fullName: fullName.trim().isNotEmpty ? fullName.trim() : state.userInfo.fullName,
        phoneNumber: phoneNumber.trim().isNotEmpty ? phoneNumber.trim() : state.userInfo.phoneNumber,
        email: email.trim().isNotEmpty ? email.trim() : state.userInfo.email,
        dateOfBirth: dateOfBirth.trim().isNotEmpty ? dateOfBirth.trim() : state.userInfo.dateOfBirth,
        gender: gender.trim().isNotEmpty ? gender.trim() : state.userInfo.gender,
        address: address.trim().isNotEmpty ? address.trim() : state.userInfo.address,
        profileImageUrl: (profileImageUrl != null && profileImageUrl.isNotEmpty)
            ? profileImageUrl
            : state.userInfo.profileImageUrl,
      ),
      isEditing: false,
    );
    debugPrint("Personal info updated and saved!");
  }

  void updateProfileImage(String imageUrl) {
    state = state.copyWith(
      userInfo: state.userInfo.copyWith(profileImageUrl: imageUrl),
    );
  }

  // Update specific fields
  void updateFullName(String name) {
    state = state.copyWith(userInfo: state.userInfo.copyWith(fullName: name));
  }

  void updatePhoneNumber(String phone) {
    state = state.copyWith(
      userInfo: state.userInfo.copyWith(phoneNumber: phone),
    );
  }

  void updateEmail(String email) {
    state = state.copyWith(userInfo: state.userInfo.copyWith(email: email));
  }

  void updateDateOfBirth(String dob) {
    state = state.copyWith(userInfo: state.userInfo.copyWith(dateOfBirth: dob));
  }

  void updateGender(String gender) {
    state = state.copyWith(userInfo: state.userInfo.copyWith(gender: gender));
  }

  void updateAddress(String address) {
    state = state.copyWith(userInfo: state.userInfo.copyWith(address: address));
  }

  void saveChanges() {
    // Logic to save to backend/DB would go here
    state = state.copyWith(isEditing: false);
    debugPrint("Changes saved!");
  }
}
