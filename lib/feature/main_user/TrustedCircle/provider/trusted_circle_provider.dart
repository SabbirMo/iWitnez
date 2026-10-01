import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/feature/main_user/TrustedCircle/model/trusted_circle_model.dart';

class TrustedCircleNotifier extends Notifier<List<TrustedCircleItem>> {
  @override
  List<TrustedCircleItem> build() {
    return _initialCircles;
  }

  static const List<TrustedCircleItem> _initialCircles = [
    TrustedCircleItem(
      id: 'family',
      title: 'Family',
      memberCount: 3,
      avatars: [
        'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150',
        'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      ],
      badgeBg: Color(0xFFF3E8FF),
      badgeIcon: Icons.groups_rounded,
      badgeIconColor: Color(0xFFA855F7),
      members: [
        CircleMember(
          id: '1',
          name: 'Dad',
          phone: '+880 1712 345678',
          email: 'dad@gmail.com',
          relationship: 'Father',
          avatarUrl:
              'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150',
        ),
        CircleMember(
          id: '2',
          name: 'Mom',
          phone: '01405366393',
          email: 'momsgroy6393@gmail.com',
          relationship: 'Sister',
          emergencyAlerts: true,
          avatarUrl:
              'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
        ),
        CircleMember(
          id: '3',
          name: 'Brother',
          phone: '+880 1912 345680',
          email: 'brother@gmail.com',
          relationship: 'Brother',
          avatarUrl:
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        ),
      ],
    ),
    TrustedCircleItem(
      id: 'friends',
      title: 'Friends',
      memberCount: 3,
      avatars: [
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=150',
      ],
      badgeBg: Color(0xFFDBEAFE),
      badgeIcon: Icons.people_alt_rounded,
      badgeIconColor: Color(0xFF3B82F6),
      members: [
        CircleMember(
          id: '4',
          name: 'Sarah Khan',
          phone: '+880 1711 223344',
          avatarUrl:
              'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        ),
        CircleMember(
          id: '5',
          name: 'Amit Sharma',
          phone: '+880 1811 223344',
          avatarUrl:
              'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        ),
        CircleMember(
          id: '6',
          name: 'Priya Patel',
          phone: '+880 1911 223344',
          avatarUrl:
              'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=150',
        ),
      ],
    ),
    TrustedCircleItem(
      id: 'partner',
      title: 'Partner',
      memberCount: 1,
      avatars: [
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      ],
      badgeBg: Color(0xFFFCE7F3),
      badgeIcon: Icons.favorite_rounded,
      badgeIconColor: Color(0xFFEC4899),
      members: [
        CircleMember(
          id: '7',
          name: 'Emma',
          phone: '+880 1712 998877',
          avatarUrl:
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        ),
      ],
    ),
    TrustedCircleItem(
      id: 'work',
      title: 'Work',
      memberCount: 2,
      avatars: [
        'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150',
        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
      ],
      badgeBg: Color(0xFFDCFCE7),
      badgeIcon: Icons.business_center_rounded,
      badgeIconColor: Color(0xFF10B981),
      members: [
        CircleMember(
          id: '8',
          name: 'Alex Johnson',
          phone: '+880 1611 334455',
          avatarUrl:
              'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150',
        ),
        CircleMember(
          id: '9',
          name: 'David Miller',
          phone: '+880 1511 667788',
          avatarUrl:
              'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
        ),
      ],
    ),
  ];

  void removeMember(String circleTitle, String memberId) {
    state = state.map((circle) {
      if (circle.title.toLowerCase() == circleTitle.toLowerCase()) {
        final updatedMembers =
            circle.members.where((m) => m.id != memberId).toList();
        final updatedAvatars =
            updatedMembers.map((m) => m.avatarUrl).take(3).toList();
        return circle.copyWith(
          members: updatedMembers,
          memberCount: updatedMembers.length,
          avatars: updatedAvatars,
        );
      }
      return circle;
    }).toList();
  }

  void updateMember(String circleTitle, CircleMember updatedMember) {
    state = state.map((circle) {
      if (circle.title.toLowerCase() == circleTitle.toLowerCase()) {
        final updatedMembers = circle.members.map((m) {
          if (m.id == updatedMember.id) {
            return updatedMember;
          }
          return m;
        }).toList();
        final updatedAvatars =
            updatedMembers.map((m) => m.avatarUrl).take(3).toList();
        return circle.copyWith(
          members: updatedMembers,
          avatars: updatedAvatars,
        );
      }
      return circle;
    }).toList();
  }

  void addMember(String circleTitle, CircleMember newMember) {
    state = state.map((circle) {
      if (circle.title.toLowerCase() == circleTitle.toLowerCase()) {
        final updatedMembers = [...circle.members, newMember];
        final updatedAvatars =
            updatedMembers.map((m) => m.avatarUrl).take(3).toList();
        return circle.copyWith(
          members: updatedMembers,
          memberCount: updatedMembers.length,
          avatars: updatedAvatars,
        );
      }
      return circle;
    }).toList();
  }
}

final trustedCircleProvider =
    NotifierProvider<TrustedCircleNotifier, List<TrustedCircleItem>>(
  TrustedCircleNotifier.new,
);
