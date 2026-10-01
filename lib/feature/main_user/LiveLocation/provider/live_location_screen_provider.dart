import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/feature/main_user/LiveLocation/model/live_sharing_model.dart';

class LiveLocationScreenState {
  final bool isSharing;
  final double zoomLevel;
  final String selectedDuration;
  final List<SharingPersonModel> contacts;

  const LiveLocationScreenState({
    this.isSharing = true,
    this.zoomLevel = 1.0,
    this.selectedDuration = 'Until I turn it off',
    this.contacts = const [
      SharingPersonModel(
        id: '1',
        name: 'Emma (You)',
        subtitle: 'Now',
        imageUrl:
            'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150',
        isLive: true,
        fallbackColor: Color(0xFFC084FC),
      ),
      SharingPersonModel(
        id: '2',
        name: 'Sarah Khan',
        subtitle: 'Now • 200 ft away',
        imageUrl:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        fallbackColor: Color(0xFFFDA4AF),
        relativeX: 0.12,
        relativeY: 0.18,
      ),
      SharingPersonModel(
        id: '3',
        name: 'Amit Sharma',
        subtitle: 'Now • 300 ft away',
        imageUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        fallbackColor: Color(0xFF60A5FA),
        relativeX: 0.72,
        relativeY: 0.20,
      ),
      SharingPersonModel(
        id: '4',
        name: 'Priya Patel',
        subtitle: 'Now • 450 ft away',
        imageUrl:
            'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=150',
        fallbackColor: Color(0xFFFB923C),
        relativeX: 0.75,
        relativeY: 0.70,
      ),
      SharingPersonModel(
        id: '5',
        name: 'Rohan Mehta',
        subtitle: 'Now • 600 ft away',
        imageUrl:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        fallbackColor: Color(0xFF10B981),
        isSharingWith: false,
        relativeX: 0.45,
        relativeY: 0.85,
      ),
    ],
  });

  LiveLocationScreenState copyWith({
    bool? isSharing,
    double? zoomLevel,
    String? selectedDuration,
    List<SharingPersonModel>? contacts,
  }) {
    return LiveLocationScreenState(
      isSharing: isSharing ?? this.isSharing,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      selectedDuration: selectedDuration ?? this.selectedDuration,
      contacts: contacts ?? this.contacts,
    );
  }
}

class LiveLocationScreenNotifier extends Notifier<LiveLocationScreenState> {
  @override
  LiveLocationScreenState build() => const LiveLocationScreenState();

  void toggleSharing() {
    state = state.copyWith(isSharing: !state.isSharing);
  }

  void stopSharing() {
    state = state.copyWith(isSharing: false);
  }

  void startSharing() {
    state = state.copyWith(isSharing: true);
  }

  void toggleContactSharing(String id) {
    state = state.copyWith(
      contacts: state.contacts.map((contact) {
        if (contact.id == id) {
          return contact.copyWith(isSharingWith: !contact.isSharingWith);
        }
        return contact;
      }).toList(),
    );
  }

  void zoomIn() {
    if (state.zoomLevel < 2.0) {
      state = state.copyWith(
        zoomLevel: (state.zoomLevel + 0.15).clamp(0.6, 2.0),
      );
    }
  }

  void zoomOut() {
    if (state.zoomLevel > 0.6) {
      state = state.copyWith(
        zoomLevel: (state.zoomLevel - 0.15).clamp(0.6, 2.0),
      );
    }
  }

  void setDuration(String duration) {
    state = state.copyWith(selectedDuration: duration);
  }
}

final liveLocationScreenProvider =
    NotifierProvider.autoDispose<
      LiveLocationScreenNotifier,
      LiveLocationScreenState
    >(LiveLocationScreenNotifier.new);
