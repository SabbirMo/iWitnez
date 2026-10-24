import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/core/network/api_endpoint/api_end_point.dart';
import 'package:iwitnez/core/network/service/api_services.dart';
import 'package:iwitnez/feature/main_user/Home_section/Home/model/trusted_circles_response_model.dart';
import 'package:iwitnez/feature/main_user/TrustedCircle/model/trusted_circle_model.dart';

class TrustedCircleNotifier extends Notifier<List<TrustedCircleItem>> {
  @override
  List<TrustedCircleItem> build() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchCircles();
    });
    return _initialCircles;
  }

  static const List<TrustedCircleItem> _initialCircles = [
    TrustedCircleItem(
      id: 'family',
      title: 'Family',
      memberCount: 0,
      avatars: [],
      badgeBg: Color(0xFFF3E8FF),
      badgeIcon: Icons.groups_rounded,
      badgeIconColor: Color(0xFFA855F7),
      members: [],
    ),
    TrustedCircleItem(
      id: 'friends',
      title: 'Friends',
      memberCount: 0,
      avatars: [],
      badgeBg: Color(0xFFDBEAFE),
      badgeIcon: Icons.people_alt_rounded,
      badgeIconColor: Color(0xFF3B82F6),
      members: [],
    ),
    TrustedCircleItem(
      id: 'partner',
      title: 'Partner',
      memberCount: 0,
      avatars: [],
      badgeBg: Color(0xFFFCE7F3),
      badgeIcon: Icons.favorite_rounded,
      badgeIconColor: Color(0xFFEC4899),
      members: [],
    ),
    TrustedCircleItem(
      id: 'work',
      title: 'Work',
      memberCount: 0,
      avatars: [],
      badgeBg: Color(0xFFDCFCE7),
      badgeIcon: Icons.business_center_rounded,
      badgeIconColor: Color(0xFF10B981),
      members: [],
    ),
    TrustedCircleItem(
      id: 'other',
      title: 'Other',
      memberCount: 0,
      avatars: [],
      badgeBg: Color(0xFFFEF3C7),
      badgeIcon: Icons.more_horiz_rounded,
      badgeIconColor: Color(0xFFD97706),
      members: [],
    ),
  ];

  void setCircles(List<TrustedCircleItem> circles) {
    state = circles;
  }

  Future<void> fetchCircles() async {
    try {
      final response = await ApiServices().get(
        ApiEndPoints.trustedCircles,
        requireAuth: true,
      );

      final data = response.data?['data'];
      if (data is Map<String, dynamic>) {
        final parsed = TrustedCirclesResponseModel.fromJson(data);
        state = parsed.toCircleItems();
      }
    } catch (_) {
      // Retain existing state on error
    }
  }

  void removeMember(String circleTitle, String memberId) {
    state = state.map((circle) {
      if (circle.title.toLowerCase() == circleTitle.toLowerCase()) {
        final updatedMembers =
            circle.members.where((m) => m.id != memberId).toList();
        final updatedAvatars = updatedMembers
            .map((m) => m.avatarUrl)
            .where((url) => url.isNotEmpty)
            .take(3)
            .toList();
        return circle.copyWith(
          members: updatedMembers,
          memberCount: updatedMembers.length,
          avatars: updatedAvatars,
        );
      }
      return circle;
    }).toList();

    try {
      if (memberId.isNotEmpty) {
        ApiServices().delete(
          '${ApiEndPoints.contacts}$memberId/',
          requireAuth: true,
        );
      }
    } catch (_) {}
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
        final updatedAvatars = updatedMembers
            .map((m) => m.avatarUrl)
            .where((url) => url.isNotEmpty)
            .take(3)
            .toList();
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
        final updatedAvatars = updatedMembers
            .map((m) => m.avatarUrl)
            .where((url) => url.isNotEmpty)
            .take(3)
            .toList();
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
