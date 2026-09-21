import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/feature/call/controller/call_flow_controller.dart';
import 'package:iwitnez/feature/call/model/call_session_model.dart';
import 'package:iwitnez/feature/call/provider/call_session_provider.dart';
import 'package:iwitnez/feature/call/widget/call_action_button.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key, required this.arguments});

  final CallArguments arguments;

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  late final CallSessionProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = CallSessionProvider(arguments: widget.arguments);
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _provider,
      builder: (context, _) {
        final isConnected = _provider.status == CallStatus.connected;
        final isIncomingRinging =
            widget.arguments.direction == CallDirection.incoming && !isConnected;

        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF181C3B),
                  Color(0xFF131735),
                  Color(0xFF0E122A),
                ],
              ),
            ),
            child: SafeArea(
              child: isConnected
                  ? _buildConnectedCallView(context)
                  : _buildIncomingOrDialingView(context, isIncomingRinging),
            ),
          ),
        );
      },
    );
  }

  /// Incoming Video Call matching Mockup 2
  Widget _buildIncomingOrDialingView(
      BuildContext context, bool isIncomingRinging) {
    final topTag = isIncomingRinging ? 'Incoming Video Call' : 'Outgoing Video Call';
    final subText = isIncomingRinging ? 'is calling you...' : 'Calling...';

    return Column(
      children: [
        SizedBox(height: 32.h),

        // Header
        Text(
          topTag,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFCBD5E1),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          widget.arguments.contactName,
          style: GoogleFonts.inter(
            fontSize: 32.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          subText,
          style: GoogleFonts.inter(
            fontSize: 15.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF94A3B8),
          ),
        ),

        SizedBox(height: 28.h),

        // Rounded Video Card with "Video Call" Chip Badge
        Center(
          child: Container(
            width: 310.w,
            height: 380.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Video Image / Preview
                ClipRRect(
                  borderRadius: BorderRadius.circular(28.r),
                  child: Image.network(
                    widget.arguments.avatarUrl,
                    width: 310.w,
                    height: 380.h,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: const Color(0xFF1E293B),
                      child: Center(
                        child: Icon(
                          Icons.person_rounded,
                          size: 100.sp,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  ),
                ),

                // Top-Left "Video Call" Badge Chip
                Positioned(
                  top: 14.h,
                  left: 14.w,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.videocam_rounded,
                          size: 14.sp,
                          color: Colors.white,
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          'Video Call',
                          style: GoogleFonts.inter(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const Spacer(),

        // Bottom Action Buttons: Decline (Red) and Accept (Green)
        if (isIncomingRinging)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 56.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Decline
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        _provider.endCall();
                        CallFlowController.endCall(context);
                      },
                      borderRadius: BorderRadius.circular(40.r),
                      child: Container(
                        width: 70.w,
                        height: 70.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFEF4444),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  const Color(0xFFEF4444).withValues(alpha: 0.4),
                              blurRadius: 18,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.call_end_rounded,
                            size: 32.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Decline',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                // Accept
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: _provider.acceptCall,
                      borderRadius: BorderRadius.circular(40.r),
                      child: Container(
                        width: 70.w,
                        height: 70.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF22C55E),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  const Color(0xFF22C55E).withValues(alpha: 0.4),
                              blurRadius: 18,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.videocam_rounded,
                            size: 32.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Accept',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        else
          // Outgoing video call awaiting answer: single End Call button
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  _provider.endCall();
                  CallFlowController.endCall(context);
                },
                borderRadius: BorderRadius.circular(40.r),
                child: Container(
                  width: 70.w,
                  height: 70.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFEF4444),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.call_end_rounded,
                      size: 32.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'End Call',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),

        SizedBox(height: 48.h),
      ],
    );
  }

  /// Active connected video call with PiP preview and live controls
  Widget _buildConnectedCallView(BuildContext context) {
    return Stack(
      children: [
        // Main Full Video View
        Positioned.fill(
          child: Image.network(
            widget.arguments.avatarUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              color: const Color(0xFF0F172A),
              child: Center(
                child: Icon(
                  Icons.person_rounded,
                  size: 120.sp,
                  color: Colors.white38,
                ),
              ),
            ),
          ),
        ),

        // Dark gradient scrims
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.6),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.75),
                ],
              ),
            ),
          ),
        ),

        // Top Bar: Caller Name & Live Timer
        Positioned(
          top: 16.h,
          left: 20.w,
          right: 20.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.arguments.contactName,
                    style: GoogleFonts.inter(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        _provider.formattedDuration,
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.flip_camera_ios_rounded,
                    color: Colors.white),
                onPressed: _provider.switchCamera,
              ),
            ],
          ),
        ),

        // Picture-in-Picture Self Camera View (Top Right)
        Positioned(
          top: 80.h,
          right: 18.w,
          child: Container(
            width: 100.w,
            height: 140.h,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 10,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: _provider.isVideoEnabled
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(color: const Color(0xFF334155)),
                        Center(
                          child: Icon(
                            Icons.face_rounded,
                            size: 40.sp,
                            color: Colors.white70,
                          ),
                        ),
                        Positioned(
                          bottom: 6.h,
                          left: 6.w,
                          child: Text(
                            'You',
                            style: GoogleFonts.inter(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      color: Colors.black87,
                      child: Center(
                        child: Icon(
                          Icons.videocam_off_rounded,
                          size: 28.sp,
                          color: Colors.white60,
                        ),
                      ),
                    ),
            ),
          ),
        ),

        // Bottom Controls Bar
        Positioned(
          bottom: 36.h,
          left: 20.w,
          right: 20.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(36.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CallActionButton(
                  icon: _provider.isMuted
                      ? Icons.mic_off_rounded
                      : Icons.mic_none_rounded,
                  label: 'Mute',
                  isActive: _provider.isMuted,
                  onTap: _provider.toggleMute,
                ),
                CallActionButton(
                  icon: _provider.isVideoEnabled
                      ? Icons.videocam_rounded
                      : Icons.videocam_off_rounded,
                  label: 'Video',
                  isActive: !_provider.isVideoEnabled,
                  onTap: _provider.toggleVideo,
                ),
                CallActionButton(
                  icon: Icons.flip_camera_ios_rounded,
                  label: 'Flip',
                  onTap: _provider.switchCamera,
                ),
                CallActionButton(
                  icon: Icons.call_end_rounded,
                  label: 'End',
                  backgroundColor: const Color(0xFFEF4444),
                  iconColor: Colors.white,
                  onTap: () {
                    _provider.endCall();
                    CallFlowController.endCall(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
