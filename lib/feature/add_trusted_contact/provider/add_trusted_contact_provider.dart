import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/core/network/error/api_error_handler.dart';
import 'package:iwitnez/feature/add_trusted_contact/model/trusted_contact_model.dart';
import 'package:iwitnez/feature/add_trusted_contact/repository/trusted_contact_repository.dart';

class TrustedContactsState {
  final List<TrustedContactModel> contacts;
  final bool isLoading;
  final bool isActionLoading;
  final String? errorMessage;

  const TrustedContactsState({
    this.contacts = const [],
    this.isLoading = false,
    this.isActionLoading = false,
    this.errorMessage,
  });

  bool get isEmpty => contacts.isEmpty;
  bool get isNotEmpty => contacts.isNotEmpty;
  int get length => contacts.length;
  TrustedContactModel operator [](int index) => contacts[index];
  TrustedContactModel get last => contacts.last;

  TrustedContactsState copyWith({
    List<TrustedContactModel>? contacts,
    bool? isLoading,
    bool? isActionLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TrustedContactsState(
      contacts: contacts ?? this.contacts,
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Notifier to manage the list of all saved trusted contacts via API
class TrustedContactListNotifier extends Notifier<TrustedContactsState> {
  @override
  TrustedContactsState build() => const TrustedContactsState();

  TrustedContactRepository get _repository =>
      ref.read(trustedContactRepositoryProvider);

  /// Fetch contacts from GET /api/v1/contacts/
  Future<void> fetchContacts() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final contacts = await _repository.fetchContacts();
      state = state.copyWith(contacts: contacts, isLoading: false);
    } catch (e) {
      debugPrint('[TrustedContactsProvider] Error fetching contacts: $e');
      final msg = e is ApiError ? e.message : 'Failed to load contacts.';
      state = state.copyWith(isLoading: false, errorMessage: msg);
    }
  }

  /// Add a contact via POST /api/v1/contacts/
  Future<TrustedContactModel?> addContact(
    TrustedContactModel contact, {
    String? avatarFilePath,
  }) async {
    state = state.copyWith(isActionLoading: true, clearError: true);
    try {
      final created = await _repository.addContact(
        contact,
        avatarFilePath: avatarFilePath,
      );
      state = state.copyWith(
        contacts: [...state.contacts, created],
        isActionLoading: false,
      );
      return created;
    } catch (e) {
      debugPrint('[TrustedContactsProvider] Error adding contact: $e');
      final msg = e is ApiError ? e.message : 'Failed to add contact.';
      state = state.copyWith(isActionLoading: false, errorMessage: msg);
      rethrow;
    }
  }

  /// Update contact via PATCH /api/v1/contacts/{contact_id}/
  Future<TrustedContactModel?> updateContact(
    String contactId,
    Map<String, dynamic> data, {
    String? avatarFilePath,
  }) async {
    state = state.copyWith(isActionLoading: true, clearError: true);
    try {
      final updated = await _repository.updateContact(
        contactId,
        data,
        avatarFilePath: avatarFilePath,
      );
      state = state.copyWith(
        contacts: state.contacts
            .map((c) => c.id == contactId ? updated : c)
            .toList(),
        isActionLoading: false,
      );
      return updated;
    } catch (e) {
      debugPrint('[TrustedContactsProvider] Error updating contact: $e');
      final msg = e is ApiError ? e.message : 'Failed to update contact.';
      state = state.copyWith(isActionLoading: false, errorMessage: msg);
      rethrow;
    }
  }

  /// Delete contact via DELETE /api/v1/contacts/{contact_id}/
  Future<void> deleteContact(String contactId) async {
    state = state.copyWith(isActionLoading: true, clearError: true);
    try {
      await _repository.deleteContact(contactId);
      state = state.copyWith(
        contacts: state.contacts.where((c) => c.id != contactId).toList(),
        isActionLoading: false,
      );
    } catch (e) {
      debugPrint('[TrustedContactsProvider] Error deleting contact: $e');
      final msg = e is ApiError ? e.message : 'Failed to delete contact.';
      state = state.copyWith(isActionLoading: false, errorMessage: msg);
      rethrow;
    }
  }

  void saveOrUpdateContactLocally(TrustedContactModel contact) {
    final index = state.contacts.indexWhere((c) => c.id == contact.id);
    if (index != -1) {
      final updated = [
        for (int i = 0; i < state.contacts.length; i++)
          if (i == index) contact else state.contacts[i],
      ];
      state = state.copyWith(contacts: updated);
    } else {
      state = state.copyWith(contacts: [...state.contacts, contact]);
    }
  }
}

final trustedContactsProvider =
    NotifierProvider<TrustedContactListNotifier, TrustedContactsState>(
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
    circle: 'family',
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
    final circle = TrustedContactModel.defaultCircleFor(relationship);
    state = state.copyWith(relationship: relationship, circle: circle);
  }

  void updateCircle(String circle) {
    state = state.copyWith(circle: circle);
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
