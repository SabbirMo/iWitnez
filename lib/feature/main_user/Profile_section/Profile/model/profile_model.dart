class UserProfile {
  const UserProfile({
    required this.name,
    required this.phone,
    required this.avatarUrl,
    this.isOnline = false,
  });

  final String name;
  final String phone;
  final String avatarUrl;
  final bool isOnline;
}

enum ProfileMenuAction {
  personalInformation,
  accountSettings,
  safetySettings,
  notifications,
  trustedCircle,
  helpSupport,
  about,
  logOut,
}

class ProfileMenuItem {
  const ProfileMenuItem({
    required this.action,
    required this.label,
    required this.icon,
    this.isDestructive = false,
  });

  final ProfileMenuAction action;
  final String label;
  final dynamic icon; // IconData, kept dynamic to avoid importing material in model
  final bool isDestructive;
}