import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
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
        final statusText = _provider.status == CallStatus.connected
            ? _provider.formattedDuration
            : 'Calling...';

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
              child: Column(
                children: [
                  SizedBox(height: 48.h),
                  // Glowing avatar
                  Center(
                    child: Container(
                      width: 160.w,
                      height: 160.w,
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
                              size: 80.sp,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 36.h),

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
                              fontSize: 28.sp,
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

                  // Subtitle (Calling... / Duration)
                  Text(
                    statusText,
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF94A3B8),
                    ),
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
                                );
                              },
                            ),
                            CallActionButton(
                              icon: Icons.more_horiz_rounded,
                              label: 'More',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Call options: Hold, Record, Transfer'),
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

                  // Big Glowing Red End Call Button
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
                                color: const Color(0xFFEF4444).withValues(alpha: 0.45),
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
          ),
        );
      },
    );
  }
}
