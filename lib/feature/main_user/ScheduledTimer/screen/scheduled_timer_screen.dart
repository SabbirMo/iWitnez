import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/widgets/custom_button.dart';
import 'package:iwitnez/feature/main_user/ScheduledTimer/provider/scheduled_timer_provider.dart';
import 'package:iwitnez/feature/main_user/ScheduledTimer/widget/check_in_note_card.dart';
import 'package:iwitnez/feature/main_user/ScheduledTimer/widget/check_in_timer_card.dart';
import 'package:iwitnez/feature/main_user/ScheduledTimer/widget/how_it_works_card.dart';
import 'package:iwitnez/feature/main_user/ScheduledTimer/widget/scheduled_timer_switch_card.dart';

class ScheduledTimerScreen extends ConsumerStatefulWidget {
  const ScheduledTimerScreen({super.key});

  @override
  ConsumerState<ScheduledTimerScreen> createState() =>
      _ScheduledTimerScreenState();
}

class _ScheduledTimerScreenState extends ConsumerState<ScheduledTimerScreen> {
  late final FixedExtentScrollController _hoursScrollController;
  late final FixedExtentScrollController _minutesScrollController;
  late final FixedExtentScrollController _secondsScrollController;
  late final TextEditingController _noteController;

  final List<String> _quickSuggestions = [
    "I'm at Office",
    "At Work",
    "In Meeting",
    "Walking home",
    "At Gym",
    "Heading home",
  ];

  @override
  void initState() {
    super.initState();
    final initial = ref.read(scheduledTimerProvider);
    _hoursScrollController = FixedExtentScrollController(
      initialItem: initial.hours,
    );
    _minutesScrollController = FixedExtentScrollController(
      initialItem: initial.minutes,
    );
    _secondsScrollController = FixedExtentScrollController(
      initialItem: initial.seconds,
    );
    _noteController = TextEditingController(text: initial.note);
  }

  @override
  void dispose() {
    _hoursScrollController.dispose();
    _minutesScrollController.dispose();
    _secondsScrollController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onStartTimer() {
    ref.read(scheduledTimerProvider.notifier).startTimer();
    final durationStr = ref.read(scheduledTimerProvider).formattedDuration;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Scheduled check-in timer set for $durationStr'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (context.canPop()) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scheduledTimerProvider);
    final notifier = ref.read(scheduledTimerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left_rounded,
            size: 32.sp,
            color: const Color(0xFF111827),
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
        centerTitle: true,
        title: Text(
          'Scheduled Check-In',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
            letterSpacing: -0.2,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Subtitle
              Center(
                child: Column(
                  children: [
                    Text(
                      "Set a check-in timer. If you don't check in on",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "time, your trusted circles will be notified.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // 1. Check-In Timer Card
              CheckInTimerCard(
                hours: state.hours,
                minutes: state.minutes,
                seconds: state.seconds,
                hoursController: _hoursScrollController,
                minutesController: _minutesScrollController,
                secondsController: _secondsScrollController,
                onHoursChanged: (val) {
                  notifier.setHours(val);
                },
                onMinutesChanged: (val) {
                  notifier.setMinutes(val % 60);
                },
                onSecondsChanged: (val) {
                  notifier.setSeconds(val % 60);
                },
              ),
              SizedBox(height: 14.h),

              // 2. Add a Note Card
              CheckInNoteCard(
                controller: _noteController,
                suggestions: _quickSuggestions,
                onSuggestionSelected: (suggestion) {
                  _noteController.text = suggestion;
                  _noteController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _noteController.text.length),
                  );
                  notifier.setNote(suggestion);
                },
                onChanged: () {
                  notifier.setNote(_noteController.text);
                },
              ),
              SizedBox(height: 14.h),

              // 3. How it works Card
              const HowItWorksCard(),
              SizedBox(height: 14.h),

              // 4. Remind me before time ends Switch Card
              ScheduledTimerSwitchCard(
                title: 'Remind me before time ends',
                subtitle: 'Get a reminder 5 minutes before the timer ends.',
                value: state.remindBeforeTimeEnds,
                onChanged: (val) {
                  notifier.toggleRemindBeforeTimeEnds(val);
                },
              ),
              SizedBox(height: 14.h),

              // 5. Notify if I don't check in Switch Card
              ScheduledTimerSwitchCard(
                title: "Notify if I don't check in",
                subtitle:
                    'Your trusted circles will be notified automatically.',
                value: state.notifyIfNotCheckedIn,
                onChanged: (val) {
                  notifier.toggleNotifyIfNotCheckedIn(val);
                },
              ),
              SizedBox(height: 22.h),

              // 6. Start Timer CustomButton
              CustomButton(
                text: 'Start Timer',
                icon: Icons.check_rounded,
                isLeadingIcon: true,
                height: 52.h,
                borderRadius: 26.r,
                onTap: _onStartTimer,
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}
