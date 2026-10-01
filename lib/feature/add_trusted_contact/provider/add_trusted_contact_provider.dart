import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/trusted_contact_model.dart';

/// Notifier to manage the list of all saved trusted contacts
class TrustedContactListNotifier extends Notifier<List<TrustedContactModel>> {
  @override
  List<TrustedContactModel> build() => const [];

  void addContact(TrustedContactModel contact) {
    state = [...state, contact];
  }

  void removeContact(String id) {
    state = state.where((c) => c.id != id).toList();
  }

  void updateContact(TrustedContactModel updated) {
    state = state.map((c) => c.id == updated.id ? updated : c).toList();
  }

  void saveOrUpdateContact(TrustedContactModel contact) {
    final index = state.indexWhere((c) => c.id == contact.id);
    if (index != -1) {
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index) contact else state[i],
      ];
    } else {
      state = [...state, contact];
    }
  }
}

final trustedContactsProvider =
    NotifierProvider<TrustedContactListNotifier, List<TrustedContactModel>>(
      TrustedContactListNotifier.new,
    );

/// Notifier to manage the current form state for adding / editing a contact
class AddTrustedContactNotifier extends Notifier<TrustedContactModel> {
  static const _emptyContact = TrustedContactModel(
    id: null,
    fullName: '',
    email: '',
    phoneNumber: '',
    relationship: '',
    emergencyAlerts: true,
    avatarUrl: null,
  );

  @override
  TrustedContactModel build() => _emptyContact;

  /// Sets existing contact for editing
  void setContact(TrustedContactModel contact) {
    state = contact;
  }

  void updateFullName(String name) {
    state = state.copyWith(fullName: name);
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  void updatePhoneNumber(String phone) {
    state = state.copyWith(phoneNumber: phone);
  }

  void updateRelationship(String relationship) {
    state = state.copyWith(relationship: relationship);
  }

  void toggleEmergencyAlerts([bool? value]) {
    state = state.copyWith(emergencyAlerts: value ?? !state.emergencyAlerts);
  }

  void updateAvatarUrl(String? url) {
    state = state.copyWith(avatarUrl: url);
  }

  void resetForm() {
    state = _emptyContact;
  }
}

final addTrustedContactProvider =
    NotifierProvider<AddTrustedContactNotifier, TrustedContactModel>(
      AddTrustedContactNotifier.new,
    );
