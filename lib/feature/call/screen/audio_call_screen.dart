import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/services/ringtone_service.dart';
import 'package:iwitnez/feature/call/controller/call_flow_controller.dart';
import 'package:iwitnez/feature/call/model/call_session_model.dart';
import 'package:iwitnez/feature/call/provider/call_session_provider.dart';
import 'package:iwitnez/feature/call/widget/audio_waveform_widget.dart';
import 'package:iwitnez/feature/call/widget/call_action_button.dart';
import 'package:iwitnez/feature/call/widget/keypad_bottom_sheet.dart';

class AudioCallScreen extends StatefulWidget {
  const AudioCallScreen({super.key, required this.arguments});

  final CallArguments arguments;

  @override
  State<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  late final CallSessionProvider _provider;
  bool _hasEndedOrPopped = false;

  @override
  void initState() {
    super.initState();
    _provider = CallSessionProvider(arguments: widget.arguments);
    _provider.addListener(_onCallSessionChanged);
  }

  void _onCallSessionChanged() {
    if (_provider.status == CallStatus.ended && mounted && !_hasEndedOrPopped) {
      _hasEndedOrPopped = true;
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
        final isIncomingRinging =
            widget.arguments.direction == CallDirection.incoming &&
            !isConnected;

        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) {
              _hasEndedOrPopped = true;
              RingtoneService.instance.stopRingtone();
              _provider.endCall();
            }
          },
          child: Scaffold(
            backgroundColor: const Color(0xFF0F172A),
            body: isConnected
                ? _buildConnectedCallView(context)
                : _buildIncomingOrDialingView(context, isIncomingRinging),
          ),
        );
      },
    );
  }

  /// Full-Screen WhatsApp Style Incoming or Outgoing Voice Calling View
  Widget _buildIncomingOrDialingView(
    BuildContext context,
    bool isIncomingRinging,
  ) {
    final topTag = isIncomingRinging
        ? 'Incoming Audio Call'
        : 'Outgoing Audio Call';
    final subText = isIncomingRinging ? 'is calling you...' : 'Calling...';

    return Stack(
      children: [
        // 1. Full-screen dimmed background photo with blur effect
        Positioned.fill(
          child: Image.network(
            widget.arguments.avatarUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                Container(color: const Color(0xFF0F172A)),
          ),
        ),

        // 2. Dark WhatsApp-style gradient scrim
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.85),
                  Colors.black.withValues(alpha: 0.70),
                  Colors.black.withValues(alpha: 0.95),
                ],
              ),
            ),
          ),
        ),

        // 3. Main Call Info & Action Buttons
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
                        Icons.call_rounded,
                        color: isIncomingRinging
                            ? const Color(0xFF22C55E)
                            : const Color(0xFF38BDF8),
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        topTag,
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
                    subText,
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: isIncomingRinging
                          ? const Color(0xFF22C55E)
                          : const Color(0xFF38BDF8),
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
                      color: isIncomingRinging
                          ? const Color(0xFF22C55E)
                          : const Color(0xFF38BDF8),
                      width: 4.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (isIncomingRinging
                                    ? const Color(0xFF22C55E)
                                    : const Color(0xFF38BDF8))
                                .withValues(alpha: 0.5),
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
                child: isIncomingRinging
                    ? Padding(
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
                                          color: const Color(
                                            0xFFEF4444,
                                          ).withValues(alpha: 0.55),
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
                                          color: const Color(
                                            0xFF22C55E,
                                          ).withValues(alpha: 0.65),
                                          blurRadius: 26,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.call_rounded,
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
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () {
                              RingtoneService.instance.stopRingtone();
                              _provider.endCall();
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
                                    color: const Color(
                                      0xFFEF4444,
                                    ).withValues(alpha: 0.55),
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
                            'End Call',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Active Connected Voice Call View with Live Controls & Duration
  Widget _buildConnectedCallView(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF181C3B), Color(0xFF131735), Color(0xFF0E122A)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 48.h),

            // Glowing Connected Avatar
            Center(
              child: Container(
                width: 150.w,
                height: 150.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF7C3AED),
                    width: 3.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.5),
                      blurRadius: 30,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    widget.arguments.avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: const Color(0xFF334155),
                      child: Icon(
                        Icons.person_rounded,
                        size: 76.sp,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 32.h),

            // Waveforms and Contact Name
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const AudioWaveformWidget(
                    isReversed: true,
                    color: Color(0xFF7C3AED),
                  ),
                  SizedBox(width: 14.w),
                  Flexible(
                    child: Text(
                      widget.arguments.contactName,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  const AudioWaveformWidget(
                    isReversed: false,
                    color: Color(0xFF7C3AED),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),

            // Call Duration
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),

            const Spacer(),

            // 2x3 Action Buttons Grid
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 28.w),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                        icon: _provider.isSpeakerOn
                            ? Icons.volume_up_rounded
                            : Icons.volume_down_rounded,
                        label: 'Speaker',
                        isActive: _provider.isSpeakerOn,
                        onTap: _provider.toggleSpeaker,
                      ),
                      CallActionButton(
                        icon: Icons.dialpad_rounded,
                        label: 'Keypad',
                        onTap: () => KeypadBottomSheet.show(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CallActionButton(
                        icon: Icons.add_rounded,
                        label: 'Add Call',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Add call clicked'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                      CallActionButton(
                        icon: Icons.videocam_rounded,
                        label: 'Video Call',
                        onTap: () {
                          _provider.endCall();
                          CallFlowController.startVideoCall(
                            context,
                            name: widget.arguments.contactName,
                            avatarUrl: widget.arguments.avatarUrl,
                            contactPhone: widget.arguments.contactPhone,
                            receiverId: widget.arguments.receiverId,
                          );
                        },
                      ),
                      CallActionButton(
                        icon: Icons.more_horiz_rounded,
                        label: 'More',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Call options: Hold, Record, Transfer',
                              ),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 40.h),

            // End Call (Red Button)
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
                    width: 72.w,
                    height: 72.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFEF4444),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFFEF4444,
                          ).withValues(alpha: 0.45),
                          blurRadius: 24,
                          spreadRadius: 3,
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

            SizedBox(height: 36.h),
          ],
        ),
      ),
    );
  }
}

