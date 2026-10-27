import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/feature/call/controller/call_flow_controller.dart';
import 'package:iwitnez/feature/call/repository/call_repository.dart';
import 'package:iwitnez/feature/main_user/Chat_section/ChatDetails/controller/chat_details_controller.dart';
import 'package:iwitnez/feature/main_user/Chat_section/ChatDetails/model/contact_profile_model.dart';

const Color _kAccentPurple = Color(0xFF6C4DF6);
const Color _kIconBgPurple = Color(0xFFF1EDFF);
const Color _kCardBorder = Color(0xFFF1F3F7);
const Color _kTextDark = Color(0xFF1E293B);
const Color _kTextSubtitle = Color(0xFF64748B);

class ChatProfileDetailsScreen extends StatefulWidget {
  const ChatProfileDetailsScreen({
    super.key,
    this.contactId,
    this.receiverId,
    this.name = 'Sarah Khan',
    this.avatarUrl = 'https://i.pravatar.cc/150?img=5',
    this.isOnline = true,
    this.relationship = 'Sister',
    this.trustedCircle = 'Family',
    this.phoneNumber,
    this.isSharingEnabled = true,
  });

  factory ChatProfileDetailsScreen.fromExtra(dynamic extra) {
    if (extra is Map<String, dynamic>) {
      return ChatProfileDetailsScreen(
        contactId: extra['contactId'] as String? ?? extra['id'] as String?,
        receiverId:
            extra['receiverId'] as String? ??
            extra['linkedUser'] as String? ??
            extra['targetUserId'] as String?,
        name:
            extra['name'] as String? ??
            extra['contactName'] as String? ??
            'Sarah Khan',
        avatarUrl:
            extra['avatarUrl'] as String? ?? 'https://i.pravatar.cc/150?img=5',
        isOnline: extra['isOnline'] as bool? ?? true,
        relationship: extra['relationship'] as String? ?? 'Sister',
        trustedCircle:
            extra['trustedCircle'] as String? ??
            extra['circleDisplay'] as String? ??
            extra['circle'] as String? ??
            'Family',
        phoneNumber:
            extra['contactPhone'] as String? ??
            extra['phoneNumber'] as String? ??
            extra['phone'] as String?,
        isSharingEnabled: extra['isSharingEnabled'] as bool? ?? true,
      );
    }
    return const ChatProfileDetailsScreen();
  }

  final String? contactId;
  final String? receiverId;
  final String name;
  final String avatarUrl;
  final bool isOnline;
  final String relationship;
  final String trustedCircle;
  final String? phoneNumber;
  final bool isSharingEnabled;

  @override
  State<ChatProfileDetailsScreen> createState() =>
      _ChatProfileDetailsScreenState();
}

class _ChatProfileDetailsScreenState extends State<ChatProfileDetailsScreen> {
  final CallRepository _callRepo = CallRepository();
  final ChatDetailsController _chatDetailsController = ChatDetailsController();

  String? _contactId;
  String? _receiverId;
  late String _name;
  late String _avatarUrl;
  late bool _isOnline;
  late String _relationship;
  late String _circle;
  late String _circleDisplay;
  String? _phoneNumber;
  late bool _isSharingEnabled;

  bool _isLoading = false;
  bool _isUpdatingCircle = false;
  bool _isTogglingSharing = false;
  bool _isStartingChat = false;

  @override
  void initState() {
    super.initState();
    _contactId = widget.contactId;
    _receiverId = widget.receiverId;
    _name = widget.name;
    _avatarUrl = widget.avatarUrl;
    _isOnline = widget.isOnline;
    _relationship = widget.relationship;
    _circle = widget.trustedCircle.toLowerCase();
    _circleDisplay = _capitalize(widget.trustedCircle);
    _phoneNumber = widget.phoneNumber;
    _isSharingEnabled = widget.isSharingEnabled;

    _fetchDetails();
  }

  String _capitalize(String s) {
    if (s.isEmpty) return 'Family';
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  Future<void> _fetchDetails() async {
    // 1. If contactId is missing, resolve it from contacts list
    if (_contactId == null || _contactId!.isEmpty) {
      final resolvedId = await _callRepo.findContactId(
        receiverId: _receiverId,
        name: _name,
      );
      if (resolvedId != null && resolvedId.isNotEmpty && mounted) {
        setState(() {
          _contactId = resolvedId;
        });
      }
    }

    // 2. Fetch Contact Profile: GET /api/v1/contacts/<contact_id>/
    if (_contactId != null && _contactId!.isNotEmpty) {
      setState(() => _isLoading = true);
      final profile = await _callRepo.getContactProfile(_contactId!);
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (profile != null) {
            _updateStateFromProfile(profile);
          }
        });
      }
    }
  }

  void _updateStateFromProfile(ContactProfileModel p) {
    _name = p.name.isNotEmpty ? p.name : _name;
    _avatarUrl = p.avatarUrl.isNotEmpty ? p.avatarUrl : _avatarUrl;
    _relationship = p.relationshipDisplay.isNotEmpty
        ? p.relationshipDisplay
        : _relationship;
    _circle = p.circle;
    _circleDisplay = p.circleDisplay;
    _phoneNumber = p.phoneNumber.isNotEmpty ? p.phoneNumber : _phoneNumber;
    _receiverId = p.linkedUser.isNotEmpty ? p.linkedUser : _receiverId;
    _isOnline = p.isOnline;
    _isSharingEnabled = p.isSharingEnabled;
  }

  /// 3.2 Change Member's Circle ("Family >" row)
  /// `POST /api/v1/contacts/<contact_id>/move/`
  /// Choices: "family", "friends", "partner", "work", "other"
  void _showCirclePicker() {
    final circles = [
      {'key': 'family', 'title': 'Family', 'icon': Icons.groups_rounded},
      {'key': 'friends', 'title': 'Friends', 'icon': Icons.people_alt_rounded},
      {'key': 'partner', 'title': 'Partner', 'icon': Icons.favorite_rounded},
      {
        'key': 'work',
        'title': 'Work',
        'icon': Icons.business_center_rounded,
      },
      {'key': 'other', 'title': 'Other', 'icon': Icons.more_horiz_rounded},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    margin: EdgeInsets.only(bottom: 16.h),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                Text(
                  'Select Trusted Circle',
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: _kTextDark,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Move $_name into a circle for safety sharing and alert routing.',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: _kTextSubtitle,
                  ),
                ),
                SizedBox(height: 16.h),
                ...circles.map((c) {
                  final key = c['key'] as String;
                  final title = c['title'] as String;
                  final icon = c['icon'] as IconData;
                  final isSelected = _circle.toLowerCase() == key;

                  return Container(
                    margin: EdgeInsets.only(bottom: 8.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _kAccentPurple.withValues(alpha: 0.08)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: isSelected ? _kAccentPurple : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 38.r,
                        height: 38.r,
                        decoration: BoxDecoration(
                          color: isSelected ? _kAccentPurple : _kIconBgPurple,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          icon,
                          color: isSelected ? Colors.white : _kAccentPurple,
                          size: 19.sp,
                        ),
                      ),
                      title: Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected ? _kAccentPurple : _kTextDark,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: _kAccentPurple,
                              size: 22.sp,
                            )
                          : null,
                      onTap: () {
                        Navigator.pop(ctx);
                        _handleMoveCircle(key, title);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleMoveCircle(String circleKey, String circleTitle) async {
    if (_contactId == null || _contactId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact ID not found for circle update')),
      );
      return;
    }

    setState(() => _isUpdatingCircle = true);
    final success = await _callRepo.moveCircle(
      contactId: _contactId!,
      circle: circleKey,
    );

    if (mounted) {
      setState(() {
        _isUpdatingCircle = false;
        if (success) {
          _circle = circleKey;
          _circleDisplay = circleTitle;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Moved $_name to $circleTitle circle'
                : 'Failed to move circle. Please try again.',
          ),
          backgroundColor:
              success ? const Color(0xFF10B981) : const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// 3.5 Location Sharing Toggle
  /// Endpoint: POST /api/v1/location/manage-sharing/
  Future<void> _toggleLocationSharing([bool? newValue]) async {
    if (_contactId == null || _contactId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contact ID not found for location sharing'),
        ),
      );
      return;
    }

    final targetVal = newValue ?? !_isSharingEnabled;
    setState(() => _isTogglingSharing = true);

    final success = await _callRepo.manageLocationSharing(
      contactId: _contactId!,
      isSharingEnabled: targetVal,
    );

    if (mounted) {
      setState(() {
        _isTogglingSharing = false;
        if (success) {
          _isSharingEnabled = targetVal;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success ? Icons.check_circle_rounded : Icons.error_outline,
                color: Colors.white,
                size: 20.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  success
                      ? (targetVal
                          ? 'Live location is now shared with $_name'
                          : 'Location sharing stopped for $_name')
                      : 'Failed to update location sharing status',
                ),
              ),
            ],
          ),
          backgroundColor:
              success ? const Color(0xFF10B981) : const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
    }
  }

  /// 3.3 Start Audio Call Action: POST /api/v1/calls/initiate/
  void _startAudioCall() {
    CallFlowController.startAudioCall(
      context,
      name: _name,
      avatarUrl: _avatarUrl,
      receiverId: _receiverId,
      contactPhone: _phoneNumber,
    );
  }

  /// 3.4 Start Video Call Action: POST /api/v1/calls/initiate/
  void _startVideoCall() {
    CallFlowController.startVideoCall(
      context,
      name: _name,
      avatarUrl: _avatarUrl,
      receiverId: _receiverId,
      contactPhone: _phoneNumber,
    );
  }

  /// 3.6 Transition into Direct Chat from Profile
  /// `POST /api/v1/chat/conversations/direct/<target_user_id>/`
  Future<void> _openDirectChat() async {
    if (_receiverId == null || _receiverId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot start chat: user account not linked.'),
        ),
      );
      return;
    }

    setState(() => _isStartingChat = true);
    await _chatDetailsController.startOrOpenDirectChat(
      context,
      targetUserId: _receiverId!,
      contactName: _name,
      avatarUrl: _avatarUrl,
      isOnline: _isOnline,
    );
    if (mounted) {
      setState(() => _isStartingChat = false);
    }
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.share_outlined, color: _kTextDark),
                  title: const Text(
                    'Share Contact',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Contact info copied for $_name'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.notifications_off_outlined,
                    color: _kTextDark,
                  ),
                  title: const Text(
                    'Mute Notifications',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Notifications muted for $_name'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.block_outlined, color: Colors.red),
                  title: const Text(
                    'Block Contact',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Blocked $_name'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFBFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _kTextDark,
            size: 18.sp,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_horiz_rounded,
              color: _kTextDark,
              size: 24.sp,
            ),
            onPressed: () => _showMoreOptions(context),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Column(
        children: [
          if (_isLoading)
            const LinearProgressIndicator(
              minHeight: 2,
              color: _kAccentPurple,
              backgroundColor: Colors.transparent,
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchDetails,
              color: _kAccentPurple,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    SizedBox(height: 8.h),

              // Profile Avatar with concentric soft glowing ring
              Center(
                child: Container(
                  width: 106.r,
                  height: 106.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: _kAccentPurple.withValues(alpha: 0.12),
                      width: 3.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _kAccentPurple.withValues(alpha: 0.08),
                        blurRadius: 18,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(3.w),
                  child: ClipOval(
                    child: _avatarUrl.isNotEmpty
                        ? Image.network(
                            _avatarUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: _kIconBgPurple,
                              child: Icon(
                                Icons.person_rounded,
                                size: 48.sp,
                                color: _kAccentPurple,
                              ),
                            ),
                          )
                        : Container(
                            color: _kIconBgPurple,
                            child: Icon(
                              Icons.person_rounded,
                              size: 48.sp,
                              color: _kAccentPurple,
                            ),
                          ),
                  ),
                ),
              ),

              SizedBox(height: 14.h),

              // Name
              Text(
                _name,
                style: GoogleFonts.inter(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: _kTextDark,
                  letterSpacing: -0.2,
                ),
              ),

              SizedBox(height: 8.h),

              // Online Status Pill
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: _isOnline
                      ? const Color(0xFFE8F8F0)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7.r,
                      height: 7.r,
                      decoration: BoxDecoration(
                        color: _isOnline
                            ? const Color(0xFF10B981)
                            : const Color(0xFF94A3B8),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      _isOnline ? 'Online' : 'Offline',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: _isOnline
                            ? const Color(0xFF10B981)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Card 1: Relationship & Trusted Circle
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(color: _kCardBorder, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Column(
                  children: [
                    // Relationship Row
                    Row(
                      children: [
                        Container(
                          width: 40.w,
                          height: 40.h,
                          decoration: BoxDecoration(
                            color: _kIconBgPurple,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.people_alt_rounded,
                            color: _kAccentPurple,
                            size: 20.sp,
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Text(
                          'Relationship',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: _kTextDark,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _relationship,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: _kTextSubtitle,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 18.h),

                    // Trusted Circle Row ("Family >" row with circle picker)
                    InkWell(
                      onTap: _showCirclePicker,
                      borderRadius: BorderRadius.circular(10.r),
                      child: Row(
                        children: [
                          Container(
                            width: 40.w,
                            height: 40.h,
                            decoration: BoxDecoration(
                              color: _kIconBgPurple,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.groups_rounded,
                              color: _kAccentPurple,
                              size: 20.sp,
                            ),
                          ),
                          SizedBox(width: 14.w),
                          Text(
                            'Trusted Circle',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: _kTextDark,
                            ),
                          ),
                          const Spacer(),
                          if (_isUpdatingCircle)
                            SizedBox(
                              width: 16.r,
                              height: 16.r,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _kAccentPurple,
                              ),
                            )
                          else
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _circleDisplay,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: _kAccentPurple,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: _kAccentPurple,
                                  size: 13.sp,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // Card 2: Action options (Audio call, Video call, Share location)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(color: _kCardBorder, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Column(
                  children: [
                    // Start Audio Call >
                    _buildActionTile(
                      icon: Icons.call_rounded,
                      title: 'Start Audio Call',
                      onTap: _startAudioCall,
                    ),
                    SizedBox(height: 18.h),

                    // Start Video Call >
                    _buildActionTile(
                      icon: Icons.videocam_rounded,
                      title: 'Start Video Call',
                      onTap: _startVideoCall,
                    ),
                    SizedBox(height: 18.h),

                    // Share Location > (With toggle and tap action)
                    InkWell(
                      onTap: _isTogglingSharing ? null : _toggleLocationSharing,
                      borderRadius: BorderRadius.circular(10.r),
                      child: Row(
                        children: [
                          Container(
                            width: 40.w,
                            height: 40.h,
                            decoration: BoxDecoration(
                              color: _kIconBgPurple,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.location_on_rounded,
                              color: _kAccentPurple,
                              size: 20.sp,
                            ),
                          ),
                          SizedBox(width: 14.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Share Location',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: _kTextDark,
                                  ),
                                ),
                                Text(
                                  _isSharingEnabled
                                      ? 'Live location active'
                                      : 'Sharing paused',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: _isSharingEnabled
                                        ? const Color(0xFF10B981)
                                        : _kTextSubtitle,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_isTogglingSharing)
                            SizedBox(
                              width: 20.r,
                              height: 20.r,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _kAccentPurple,
                              ),
                            )
                          else
                            Switch(
                              value: _isSharingEnabled,
                              onChanged: _toggleLocationSharing,
                              activeThumbColor: _kAccentPurple,
                              activeTrackColor:
                                  _kAccentPurple.withValues(alpha: 0.38),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // Primary Action: Transition into Direct Chat
              if (_receiverId != null && _receiverId!.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton.icon(
                    onPressed: _isStartingChat ? null : _openDirectChat,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kAccentPurple,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    icon: _isStartingChat
                        ? SizedBox(
                            width: 18.r,
                            height: 18.r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(Icons.chat_bubble_rounded, size: 19.sp),
                    label: Text(
                      'Direct Chat with $_name',
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    ),
  ],
),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: _kIconBgPurple,
              borderRadius: BorderRadius.circular(12.r),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: _kAccentPurple, size: 20.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: _kTextDark,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: const Color(0xFF94A3B8),
            size: 14.sp,
          ),
        ],
      ),
    );
  }
}
