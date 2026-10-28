import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/services/ringtone_service.dart';
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
    _provider.addListener(_onCallSessionChanged);
  }

  void _onCallSessionChanged() {
    if (_provider.status == CallStatus.ended && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          CallFlowController.endCall(context);
        }
      });
    }
  }

  @override
  void dispose() {
    _provider.removeListener(_onCallSessionChanged);
    RingtoneService.instance.stopRingtone();
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _provider,
      builder: (context, _) {
        final isConnected = _provider.status == CallStatus.connected;
        final isIncoming =
            widget.arguments.direction == CallDirection.incoming;

        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) {
              RingtoneService.instance.stopRingtone();
              _provider.endCall();
            }
          },
          child: Scaffold(
            backgroundColor: Colors.black,
            body: isConnected
                ? _buildConnectedCallView(context)
                : (isIncoming
                    ? _buildIncomingCallView(context)
                    : _buildOutgoingDialingView(context)),
          ),
        );
      },
    );
  }

  /// 1. Outgoing Video Call Dialing View (Full-Screen Front Camera WhatsApp Style)
  Widget _buildOutgoingDialingView(BuildContext context) {
    final engine = _provider.agoraService.engine;

    return Stack(
      children: [
        // Full-Screen Front Camera Live Preview
        Positioned.fill(
          child: (engine != null && _provider.isVideoEnabled)
              ? AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: engine,
                    canvas: const VideoCanvas(uid: 0),
                  ),
                )
              : Image.network(
                  widget.arguments.avatarUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: const Color(0xFF0F172A),
                    child: Center(
                      child: Icon(
                        Icons.person_rounded,
                        size: 96.sp,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                ),
        ),

        // Dark WhatsApp-style gradient overlays (Top & Bottom scrims)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.28, 0.65, 1.0],
                colors: [
                  Colors.black.withValues(alpha: 0.75),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.85),
                ],
              ),
            ),
          ),
        ),

        // Top Header: Contact Name, Calling Status & Flip Camera Button
        Positioned(
          top: 16.h,
          left: 20.w,
          right: 20.w,
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.arguments.contactName,
                      style: GoogleFonts.inter(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 4.h),
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
                        SizedBox(width: 8.w),
                        Text(
                          'Calling...',
                          style: GoogleFonts.inter(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFE2E8F0),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Flip camera in top right
                InkWell(
                  onTap: _provider.switchCamera,
                  borderRadius: BorderRadius.circular(30.r),
                  child: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Icon(
                      Icons.flip_camera_ios_rounded,
                      color: Colors.white,
                      size: 22.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom WhatsApp Controls Bar
        Positioned(
          bottom: 36.h,
          left: 20.w,
          right: 20.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.65),
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
                    RingtoneService.instance.stopRingtone();
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

  /// 2. Incoming Video Call Ringing View (WhatsApp Style Accept/Decline)
  Widget _buildIncomingCallView(BuildContext context) {
    return Stack(
      children: [
        // Full-screen dimmed background photo with dark blur
        Positioned.fill(
          child: Image.network(
            widget.arguments.avatarUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(color: const Color(0xFF0F172A)),
          ),
        ),

        // Dark WhatsApp-style gradient scrim
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.85),
                  Colors.black.withValues(alpha: 0.65),
                  Colors.black.withValues(alpha: 0.95),
                ],
              ),
            ),
          ),
        ),

        // Main Incoming Call Info & Action Buttons
        SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Header
              Column(
                children: [
                  SizedBox(height: 36.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.videocam_rounded,
                        color: const Color(0xFF22C55E),
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Incoming Video Call',
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFE2E8F0),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Text(
                      widget.arguments.contactName,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  if (widget.arguments.contactPhone != null &&
                      widget.arguments.contactPhone!.isNotEmpty) ...[
                    SizedBox(height: 6.h),
                    Text(
                      widget.arguments.contactPhone!,
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                  SizedBox(height: 10.h),
                  Text(
                    'is calling you...',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF22C55E),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),

              // Glowing WhatsApp Pulsing Avatar in Center
              Center(
                child: Container(
                  width: 175.w,
                  height: 175.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF22C55E),
                      width: 4.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF22C55E).withValues(alpha: 0.5),
                        blurRadius: 36,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.network(
                      widget.arguments.avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: const Color(0xFF1E293B),
                        child: Center(
                          child: Icon(
                            Icons.person_rounded,
                            size: 96.sp,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Actions: WhatsApp Accept (Green) and Decline (Red)
              Padding(
                padding: EdgeInsets.only(bottom: 50.h),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 54.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Decline (Red Button)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () {
                              RingtoneService.instance.stopRingtone();
                              _provider.declineCall();
                              CallFlowController.endCall(context);
                            },
                            borderRadius: BorderRadius.circular(45.r),
                            child: Container(
                              width: 74.w,
                              height: 74.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFEF4444),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFEF4444)
                                        .withValues(alpha: 0.55),
                                    blurRadius: 22,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.call_end_rounded,
                                  size: 36.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            'Decline',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),

                      // Accept (Green Button)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () {
                              RingtoneService.instance.stopRingtone();
                              _provider.acceptCall();
                            },
                            borderRadius: BorderRadius.circular(45.r),
                            child: Container(
                              width: 74.w,
                              height: 74.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF22C55E),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF22C55E)
                                        .withValues(alpha: 0.65),
                                    blurRadius: 26,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.videocam_rounded,
                                  size: 36.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            'Accept',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 3. Active Connected Video Call with PiP Preview & Live Controls
  Widget _buildConnectedCallView(BuildContext context) {
    final engine = _provider.agoraService.engine;
    final remoteUid = _provider.agoraService.remoteUid;
    final channelName = _provider.agoraChannelName ?? '';

    return Stack(
      children: [
        // Main Full Video View: Remote Agora Stream if connected, else Avatar fallback
        Positioned.fill(
          child: (engine != null && remoteUid != null && channelName.isNotEmpty)
              ? AgoraVideoView(
                  controller: VideoViewController.remote(
                    rtcEngine: engine,
                    canvas: VideoCanvas(uid: remoteUid),
                    connection: RtcConnection(channelId: channelName),
                  ),
                )
              : Image.network(
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
          child: SafeArea(
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
                  icon: const Icon(
                    Icons.flip_camera_ios_rounded,
                    color: Colors.white,
                  ),
                  onPressed: _provider.switchCamera,
                ),
              ],
            ),
          ),
        ),

        // Picture-in-Picture Self Camera View (Top Right)
        Positioned(
          top: 80.h,
          right: 18.w,
          child: SafeArea(
            child: Container(
              width: 100.w,
              height: 140.h,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.8),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: (_provider.isVideoEnabled && engine != null)
                    ? AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: engine,
                          canvas: const VideoCanvas(uid: 0),
                        ),
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
