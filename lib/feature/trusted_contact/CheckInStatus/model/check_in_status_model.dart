enum CheckInStatusType { checkedIn, notSetUp, notCheckedIn }

class CheckInStatusData {
  final String wardName;
  final String wardAvatarUrl;
  final CheckInStatusType statusType;
  final String note;
  final String address;
  final String checkInTime;
  final String lastCheckInTime;

  const CheckInStatusData({
    this.wardName = 'Emma',
    this.wardAvatarUrl =
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
    this.statusType = CheckInStatusType.checkedIn,
    this.note = 'I am At office',
    this.address = '1200 Park Ave, New York,\nNY 10028, USA',
    this.checkInTime = 'Today, 10:30 AM',
    this.lastCheckInTime = 'Yesterday, 08:15 PM',
  });

  CheckInStatusData copyWith({
    String? wardName,
    String? wardAvatarUrl,
    CheckInStatusType? statusType,
    String? note,
    String? address,
    String? checkInTime,
    String? lastCheckInTime,
  }) {
    return CheckInStatusData(
      wardName: wardName ?? this.wardName,
      wardAvatarUrl: wardAvatarUrl ?? this.wardAvatarUrl,
      statusType: statusType ?? this.statusType,
      note: note ?? this.note,
      address: address ?? this.address,
      checkInTime: checkInTime ?? this.checkInTime,
      lastCheckInTime: lastCheckInTime ?? this.lastCheckInTime,
    );
  }
}
