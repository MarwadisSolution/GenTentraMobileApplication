import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import '../../../../Reusable Functions/reusable_functions.dart';
import '../../party_page_data.dart';
import '../../reusable_functions.dart';
import 'attendance_count_page.dart';
import 'event_modal.dart';
import 'package:intl/intl.dart';

import 'event_tab_bloc.dart';
import 'event_tab_event.dart';
import 'event_tab_state.dart';
String emptyMessage(int selectedTab) {
  switch (selectedTab) {
    case 0:
      return "No events found";

    case 1:
      return "You haven't created any events yet";

    case 2:
      return "No private events found";

    case 3:
      return "No past events found";

    default:
      return "No events found";
  }
}

Widget buildEventTabs(
    BuildContext context,
    EventTabState state,
    ) {
  final tabs = [
    "All",
    "My Events",
    "Private Events",
    "Past Events",
  ];

  final w = MediaQuery.of(context).size.width;

  return SizedBox(
    width: double.infinity,
    height: w*0.1,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(
        horizontal: w * 0.035,
      ),
      itemCount: tabs.length,
      itemBuilder: (context, index) {
        return ReusableFilterChip(
          title: tabs[index],
          isSelected: state.selectedTab == index,
          onTap: () {
            context.read<EventsBloc>().add(
              ChangeTabEvent(index),
            );
          },
        );
      },
    ),
  );
}



///----------Media showing

class ReusableMediaWidget<T> extends StatelessWidget {
  final List<T> media;

  /// Builds the actual image/video preview.
  final Widget Function(T item) mediaPreview;

  /// Returns true when the media is a video.
  final bool Function(T item) isVideo;

  /// Opens the full-screen viewer.
  final void Function(BuildContext context, int initialIndex)? onMediaTap;

  final double singleMediaHeight;
  /// Height for 2-media layout.
  final double twoMediaHeight;

  /// Height for 3+ media layout.
  final double threeOrMoreMediaHeight;

  /// Gap between media items.
  final double spacing;

  /// Optional border radius.
  final BorderRadius borderRadius;

  const ReusableMediaWidget({
    super.key,
    required this.media,
    required this.mediaPreview,
    required this.isVideo,
    this.onMediaTap,
    this.singleMediaHeight=300,
    this.twoMediaHeight = 300,
    this.threeOrMoreMediaHeight = 360,
    this.spacing = 3,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  Widget build(BuildContext context) {
    if (media.isEmpty) {
      return const SizedBox.shrink();
    }

    switch (media.length) {
      case 1:
        return _buildSingleMedia(context);

      case 2:
        return _buildTwoMedia(context);

      default:
        return _buildThreeOrMoreMedia(context);
    }
  }

  // ============================================================
  // 1 MEDIA
  // ============================================================

  Widget _buildSingleMedia(BuildContext context) {
    return SizedBox(
      height: singleMediaHeight,
      width: double.infinity,
      child: _mediaTile(
        context: context,
        index: 0,
      ),
    );
  }

  // ============================================================
  // 2 MEDIA
  // ============================================================

  Widget _buildTwoMedia(BuildContext context) {
    return SizedBox(
      height: twoMediaHeight,
      child: Row(
        children: [
          Expanded(
            child: _mediaTile(
              context: context,
              index: 0,
            ),
          ),

          SizedBox(width: spacing),

          Expanded(
            child: _mediaTile(
              context: context,
              index: 1,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 3 OR MORE MEDIA
  // ============================================================

  Widget _buildThreeOrMoreMedia(BuildContext context) {
    final remaining = media.length - 3;

    return SizedBox(
      height: threeOrMoreMediaHeight,
      child: Column(
        children: [
          // ------------------------------------------------------
          // TOP LARGE MEDIA
          // ------------------------------------------------------

          Expanded(
            flex: 2,
            child: _mediaTile(
              context: context,
              index: 0,
            ),
          ),

          SizedBox(height: spacing),

          // ------------------------------------------------------
          // BOTTOM TWO MEDIA
          // ------------------------------------------------------

          Expanded(
            flex: 1,
            child: Row(
              children: [
                Expanded(
                  child: _mediaTile(
                    context: context,
                    index: 1,
                  ),
                ),

                SizedBox(width: spacing),

                Expanded(
                  child: _mediaTile(
                    context: context,
                    index: 2,
                    overlayCount: remaining > 0 ? remaining : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COMMON MEDIA TILE
  // ============================================================

  Widget _mediaTile({
    required BuildContext context,
    required int index,
    int? overlayCount,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onMediaTap == null
          ? null
          : () => onMediaTap!(context, index),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ExcludeSemantics(
              child: mediaPreview(media[index]),
            ),

            if (overlayCount != null)
              IgnorePointer(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.55),
                  alignment: Alignment.center,
                  child: Text(
                    "+$overlayCount",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            if (isVideo(media[index]))
              Positioned(
                top: 10,
                right: 10,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}


class ReusableMediaViewer<T> extends StatefulWidget {
  final List<T> media;
  final int initialIndex;

  /// Returns true when the media item is a video.
  final bool Function(T item) isVideo;

  /// Returns the video widget for the given media item.
  final Widget Function(T item) videoBuilder;

  /// Returns the image URL for the given media item.
  final String? Function(T item) imageUrlBuilder;

  const ReusableMediaViewer({
    super.key,
    required this.media,
    required this.initialIndex,
    required this.isVideo,
    required this.videoBuilder,
    required this.imageUrlBuilder,
  });

  @override
  State<ReusableMediaViewer<T>> createState() =>
      _ReusableMediaViewerState<T>();
}

class _ReusableMediaViewerState<T>
    extends State<ReusableMediaViewer<T>> {
  late final PageController pageController;
  late int currentIndex;

  @override
  void initState() {
    super.initState();

    currentIndex = widget.initialIndex;

    pageController = PageController(
      initialPage: widget.initialIndex,
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,

        title: Text(
          "${currentIndex + 1} / ${widget.media.length}",
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),

      body: PageView.builder(
        controller: pageController,
        itemCount: widget.media.length,

        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        itemBuilder: (context, index) {
          final item = widget.media[index];

          // VIDEO
          if (widget.isVideo(item)) {
            return widget.videoBuilder(item);
          }

          // IMAGE
          final imageUrl = widget.imageUrlBuilder(item);

          if (imageUrl == null || imageUrl.isEmpty) {
            return const Center(
              child: Icon(
                Icons.image,
                color: Colors.white,
                size: 60,
              ),
            );
          }

          return InteractiveViewer(
            minScale: 1,
            maxScale: 4,

            child: Center(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,

                errorBuilder: (
                    context,
                    error,
                    stackTrace,
                    ) {
                  return const Icon(
                    Icons.image,
                    color: Colors.white,
                    size: 60,
                  );
                },

                loadingBuilder: (
                    context,
                    child,
                    loadingProgress,
                    ) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
///--------------------------------




class EventDateRangeField extends StatelessWidget {
  final DateTime? fromDate;
  final DateTime? toDate;
  final ValueChanged<DateTime> onFromDateSelected;
  final ValueChanged<DateTime> onToDateSelected;

  const EventDateRangeField({
    super.key,
    required this.fromDate,
    required this.toDate,
    required this.onFromDateSelected,
    required this.onToDateSelected,
  });


  Future<void> _selectDate(
      BuildContext context, {
        required bool isFromDate,
      }) async {
    final DateTime minDate = isFromDate
        ? DateTime.now()
        : fromDate ?? DateTime.now();

    final DateTime maxDate = isFromDate
        ? (toDate != null && !toDate!.isBefore(minDate)
        ? toDate!
        : DateTime(2100))
        : DateTime(2100);

    DateTime initialDate = isFromDate
        ? fromDate ?? DateTime.now()
        : toDate ?? fromDate ?? DateTime.now();

    // Keep initial date within the allowed range.
    if (initialDate.isBefore(minDate)) {
      initialDate = minDate;
    } else if (initialDate.isAfter(maxDate)) {
      initialDate = maxDate;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    DateTime tempDate = initialDate;

    final DateTime? selectedDate = await showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.width*0.7,
          decoration:  BoxDecoration(
            color: ColorScheme.of(context).surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(MediaQuery.of(context).size.width*0.04),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                // Picker toolbar
                Padding(
                  padding:  EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width*0.06,
                    vertical: MediaQuery.of(context).size.width*0.01,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child:  Text(
                          'Cancel',
                          style: TextStyle(
                            color: ColorScheme.of(context).onSurface.withOpacity(0.6),
                            fontSize: MediaQuery.of(context).size.width*0.05,
                          ),
                        ),
                      ),

                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          Navigator.pop(context, tempDate);
                        },
                        child:  Text(
                          'Done',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width*0.05,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.activeBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // iOS wheel date picker
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: initialDate,
                    minimumDate: minDate,
                    maximumDate: maxDate,
                    dateOrder: DatePickerDateOrder.mdy,
                    backgroundColor: CupertinoColors.white,
                    onDateTimeChanged: (DateTime newDate) {
                      tempDate = newDate;
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedDate == null) return;

    if (isFromDate) {
      onFromDateSelected(selectedDate);
    } else {
      onToDateSelected(selectedDate);
    }
  }


  String _formatDate(DateTime? date) {
    if (date == null) return 'Select date';
    return DateFormat('dd MMM yyyy').format(date);
  }

  Widget _dateField({
    required BuildContext context,
    required String label,
    required String subtitle,
    required DateTime? date,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final bool isSelected = date != null;
final w=MediaQuery.of(context).size.width;
final h=MediaQuery.of(context).size.height;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 15,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest
                .withOpacity(0.45),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:  ColorScheme.of(context).onSurface.withValues(alpha: 0.3)
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 17,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
               SizedBox(height:w*0.02),
              Text(
                _formatDate(date),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).hintColor,
                ),
              ),
               SizedBox(height: w*0.02),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: w*0.035,fontWeight: FontWeight.w600,
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w=MediaQuery.of(context).size.width;
    final h=MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Event Date',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 5),
            const Text(
              '*',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
         SizedBox(height: w*0.02),
        Row(
          children: [
            _dateField(
              context: context,
              label: 'FROM DATE',
              subtitle: 'Start date',
              date: fromDate,
              icon: Icons.calendar_month_rounded,
              onTap: () => _selectDate(
                context,
                isFromDate: true,
              ),
            ),
            const SizedBox(width: 10),
            _dateField(
              context: context,
              label: 'TO DATE',
              subtitle: 'End date',
              date: toDate,
              icon: Icons.event_available_rounded,
              onTap: () => _selectDate(
                context,
                isFromDate: false,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
///------------------------------------------------------------------

class EventTimeRangeField extends StatelessWidget {
  final TimeOfDay? fromTime;
  final TimeOfDay? toTime;

  final ValueChanged<TimeOfDay> onFromTimeSelected;
  final ValueChanged<TimeOfDay> onToTimeSelected;

  const EventTimeRangeField({
    super.key,
    required this.fromTime,
    required this.toTime,
    required this.onFromTimeSelected,
    required this.onToTimeSelected,
  });


  Future<void> _selectTime(
      BuildContext context, {
        required bool isFromTime,
      }) async {
    FocusManager.instance.primaryFocus?.unfocus();

    final TimeOfDay initialTime = isFromTime
        ? fromTime ?? TimeOfDay.now()
        : toTime ?? fromTime ?? TimeOfDay.now();

    int selectedHour = initialTime.hourOfPeriod == 0
        ? 12
        : initialTime.hourOfPeriod;

    int selectedMinute = initialTime.minute;

    bool isPM = initialTime.period == DayPeriod.pm;

    final TimeOfDay? selectedTime =
    await showCupertinoModalPopup<TimeOfDay>(
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.width*0.7,
          decoration:  BoxDecoration(
            color: ColorScheme.of(context).surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(MediaQuery.of(context).size.width*0.04),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                // Header
                Padding(
                  padding:  EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width*0.06,
                    vertical: MediaQuery.of(context).size.width*0.01,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child:  Text(
                          'Cancel',
                          style: TextStyle(
                            color: ColorScheme.of(context).onSurface.withOpacity(0.6),
                            fontSize: MediaQuery.of(context).size.width*0.05,
                          ),
                        ),
                      ),

                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          int hour = selectedHour % 12;

                          if (isPM) {
                            hour += 12;
                          }

                          Navigator.pop(
                            context,
                            TimeOfDay(
                              hour: hour,
                              minute: selectedMinute,
                            ),
                          );
                        },
                        child:  Text(
                          'Done',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width*0.05,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.activeBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Cupertino wheel picker
                Expanded(
                  child: Row(
                    children: [
                      // Hour
                      Expanded(
                        child: CupertinoPicker(
                          scrollController:
                          FixedExtentScrollController(
                            initialItem: selectedHour - 1,
                          ),
                          itemExtent: 42,
                          onSelectedItemChanged: (index) {
                            selectedHour = index + 1;
                          },
                          children: List.generate(
                            12,
                                (index) => Center(
                              child: Text(
                                '${index + 1}',
                                style:  TextStyle(
                                  fontSize:   MediaQuery.of(context).size.width*0.06,
                                  color: ColorScheme.of(context).onSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Minute
                      Expanded(
                        child: CupertinoPicker(
                          scrollController:
                          FixedExtentScrollController(
                            initialItem: selectedMinute,
                          ),
                          itemExtent: 42,
                          onSelectedItemChanged: (index) {
                            selectedMinute = index;
                          },
                          children: List.generate(
                            60,
                                (index) => Center(
                              child: Text(
                                index.toString().padLeft(2, '0'),
                                style:  TextStyle(
                                  fontSize: MediaQuery.of(context).size.width*0.06,
                                  color: ColorScheme.of(context).onSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // AM / PM
                      Expanded(
                        child: CupertinoPicker(
                          scrollController:
                          FixedExtentScrollController(
                            initialItem: isPM ? 1 : 0,
                          ),
                          itemExtent: 42,
                          onSelectedItemChanged: (index) {
                            isPM = index == 1;
                          },
                          children:  [
                            Center(
                              child: Text(
                                'AM',
                                style: TextStyle(
                                  fontSize:  MediaQuery.of(context).size.width*0.05,
                                  color: ColorScheme.of(context).onSurface,
                                ),
                              ),
                            ),
                            Center(
                              child: Text(
                                'PM',
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width*0.05,
                                  color: ColorScheme.of(context).onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedTime == null) return;

    if (isFromTime) {
      onFromTimeSelected(selectedTime);
    } else {
      onToTimeSelected(selectedTime);
    }
  }


  Widget _timeField({
    required BuildContext context,
    required String label,
    required String subtitle,
    required TimeOfDay? time,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final bool isSelected = time != null;
    final w=MediaQuery.of(context).size.width;
    final h=MediaQuery.of(context).size.height;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 15,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withOpacity(0.45),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: ColorScheme.of(context).onSurface.withValues(alpha: 0.3)
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 17,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
               SizedBox(height: w*0.02),
              Text(
                time?.format(context) ?? 'Select time',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).hintColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                  style: TextStyle(
                    fontSize: w*0.035,fontWeight: FontWeight.w600,
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Event Time',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 5),
            const Text(
              '*',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _timeField(
              context: context,
              label: 'FROM TIME',
              subtitle: 'Start time',
              time: fromTime,
              icon: Icons.access_time_rounded,
              onTap: () => _selectTime(
                context,
                isFromTime: true,
              ),
            ),
            const SizedBox(width: 10),
            _timeField(
              context: context,
              label: 'TO TIME',
              subtitle: 'End time',
              time: toTime,
              icon: Icons.timer_outlined,
              onTap: () => _selectTime(
                context,
                isFromTime: false,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
///-------------------------------------------------------
class TimeOfDayRange {
  final TimeOfDay start;
  final TimeOfDay end;

  const TimeOfDayRange({
    required this.start,
    required this.end,
  });
}

//-------------- Radio buttons
Widget radioButtons(
    String name,
    bool value,
    bool? selectedValue,
    double screenHeight,
    ValueChanged<bool?> onChanged,
    ) {
  final bool isSelected = selectedValue == value;

  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Radio<bool>(
        value: value,
        groupValue: selectedValue,
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFFFF2164);
          }
          return Colors.grey;
        }),
        onChanged: onChanged,
      ),

      Text(
        name,
        style: TextStyle(
          fontSize: screenHeight * 0.02,
          fontWeight: isSelected
              ? FontWeight.bold
              : FontWeight.w400,
        ),
      ),
    ],
  );
}
///-------------Image adder
class ReusableImagePicker extends StatelessWidget {
  final List<File> mediaFiles;
  final VoidCallback onAddMedia;
  final ValueChanged<int> onRemoveMedia;
  final String title;
  final double height;

  const ReusableImagePicker({
    super.key,
    required this.mediaFiles,
    required this.onAddMedia,
    required this.onRemoveMedia,
    this.title = "Add Media",
    required this.height,
  });

  bool _isVideo(File file) {
    final extension = file.path.split('.').last.toLowerCase();

    return [
      'mp4',
      'mov',
      'avi',
      'mkv',
      'webm',
    ].contains(extension);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: height,
      ),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFBFC1CC),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(2),
      ),
      child: mediaFiles.isEmpty
          ? _buildEmptyPicker(context)
          : _buildMediaGrid(context),
    );
  }

  Widget _buildEmptyPicker(BuildContext context) {
    return SizedBox(
      height: height - 20,
      child: Center(
        child: _buildAddButton(context),
      ),
    );
  }

  Widget _buildMediaGrid(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ...List.generate(
          mediaFiles.length,
              (index) {
            return _buildMediaItem(
              context,
              mediaFiles[index],
              index,
            );
          },
        ),

        // Add Media button
        _buildAddButton(context),
      ],
    );
  }

  Widget _buildMediaItem(
      BuildContext context,
      File file,
      int index,
      ) {
    final bool isVideo = _isVideo(file);

    return SizedBox(
      width: 85,
      height: 85,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 85,
              height: 85,
              color: const Color(0xFFF0F0F0),
              child: isVideo
                  ? const Center(
                child: Icon(
                  Icons.play_circle_outline,
                  size: 38,
                  color: Color(0xFFFF2164),
                ),
              )
                  : Image.file(
                file,
                width: 85,
                height: 85,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Delete button
          Positioned(
            top: 4,
            right: 4,
            child: InkWell(
              onTap: () {
                onRemoveMedia(index);
              },
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Video label
          if (isVideo)
            Positioned(
              left: 5,
              bottom: 5,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  "VIDEO",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return InkWell(
      onTap: onAddMedia,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width:  MediaQuery.of(context).size.width*0.35,
        height:  MediaQuery.of(context).size.height*0.05,
        decoration: BoxDecoration(
          color: const Color(0xFF000000).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(  MediaQuery.of(context).size.width * 0.05),
        ),
        child:  Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          SvgPicture.asset(
              width: MediaQuery.of(context).size.width * 0.055,
              PartyPageData.addImageIcon
          ),
            SizedBox(width: MediaQuery.of(context).size.width*0.02 ),
            Text(
              "Add Media",
              style: TextStyle(
                fontSize:   MediaQuery.of(context).size.width * 0.035,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1,
    this.dashWidth = 5,
    this.dashSpace = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Top
    double x = 0;
    while (x < size.width) {
      path.moveTo(x, 0);
      path.lineTo(
        (x + dashWidth).clamp(0, size.width),
        0,
      );
      x += dashWidth + dashSpace;
    }

    // Bottom
    x = 0;
    while (x < size.width) {
      path.moveTo(x, size.height);
      path.lineTo(
        (x + dashWidth).clamp(0, size.width),
        size.height,
      );
      x += dashWidth + dashSpace;
    }

    // Left
    double y = 0;
    while (y < size.height) {
      path.moveTo(0, y);
      path.lineTo(
        0,
        (y + dashWidth).clamp(0, size.height),
      );
      y += dashWidth + dashSpace;
    }

    // Right
    y = 0;
    while (y < size.height) {
      path.moveTo(size.width, y);
      path.lineTo(
        size.width,
        (y + dashWidth).clamp(0, size.height),
      );
      y += dashWidth + dashSpace;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
///---------------------------------Attendence
class EventAttendeesPreview extends StatelessWidget {
  final List<AttendeePreview>? attendees;
  final int attendeeCount;
  final double size;

  const EventAttendeesPreview({
    super.key,
    required this.attendees,
    required this.attendeeCount,
    this.size = 42,
  });

  @override
  Widget build(BuildContext context) {
    final List<AttendeePreview> preview =
    (attendees ?? []).take(5).toList();

    if (attendeeCount <= 0 || preview.isEmpty) {
      return const SizedBox.shrink();
    }

    final int remainingCount =
    attendeeCount > preview.length
        ? attendeeCount - preview.length
        : 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: size,
          width: preview.length * (size * 0.62) + size * 0.38,
          child: Stack(
            children: List.generate(
              preview.length,
                  (index) {
                final attendee = preview[index];

                return Positioned(
                  left: index * (size * 0.62),
                  child: Container(
                    width: size,
                    height: size,
                    padding: const EdgeInsets.all(1.5),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: buildImageWidget(
                        attendee.user?.imageUrl ?? "",
                        width: size,
                        height: size,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        if (remainingCount > 0) ...[
          SizedBox(width: (size * 0.15).clamp(3.0, 6.0)),

          Text(
            "+${formatAttendeeCount(remainingCount)}",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: (size * 0.42).clamp(10.0, 14.0),
            ),
          ),
        ],
      ],
    );
  }

  String formatAttendeeCount(int count) {
    if (count >= 1000000) {
      return "${(count / 1000000).toStringAsFixed(1)}M";
    }

    if (count >= 1000) {
      return "${(count / 1000).toStringAsFixed(1)}K";
    }

    return count.toString();
  }
}
//---------------------------
String dateFormating(String date) {
  DateTime parsedDate = DateTime.parse(date);

  String formattedDate = DateFormat('dd MMM yyyy').format(parsedDate);

  return formattedDate;
}
String timingConversionAccordingToPMAM(String fromTime) {
  final match = RegExp(r'TimeOfDay\((\d{1,2}):(\d{2})\)').firstMatch(fromTime);

  if (match == null) return fromTime;

  int hour = int.parse(match.group(1)!);
  final int minute = int.parse(match.group(2)!);

  final String period = hour >= 12 ? 'PM' : 'AM';

  hour = hour % 12;
  if (hour == 0) {
    hour = 12;
  }

  return '$hour:${minute.toString().padLeft(2, '0')} $period';
}

class ReusableEventCard extends StatelessWidget {
  final dynamic eventData;

  final bool isAdmin;
  final String fromTime;

  final bool isJoining;

  final VoidCallback? onShare;
  final VoidCallback? onJoin;

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final String fromWhichPage;
  final bool isPolitician;
  const ReusableEventCard({
    super.key,
    required this.eventData,
    required this.isAdmin,
    required this.fromTime,
    required this.isJoining,

    this.onShare,
    this.onJoin,
    this.onEdit,
    this.onDelete,
    required this.fromWhichPage,
    required this.isPolitician,
  });
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final w = size.width;
    final h = size.height;

    return Card(

      shadowColor: Colors.black.withValues(alpha: 0.2),

      key: ValueKey(eventData.id),

      margin: const EdgeInsets.symmetric(horizontal: 12),

      color: ColorScheme.of(context).surface,

      elevation: 10,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(w*0.055),
        side: BorderSide(color: Colors.black.withValues(alpha: 0.1))
      ),

      child: Padding(
        padding:  EdgeInsets.only(bottom:  w*0.04),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            ListTile(
              contentPadding:  EdgeInsets.symmetric(
                horizontal: w*0.04,
                vertical: w*0.02,
              ),

              leading: CircleAvatar(
                radius: w * 0.07,

                backgroundColor: Colors.white,

                child: ClipOval(
                  child: buildImageWidget(
                    eventData.author?.photoUrl ?? "",
                    width: w * 0.14,
                    height: w * 0.14,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              title: Text(
                eventData.title,

                maxLines: 3,

                overflow: TextOverflow.ellipsis,

                style: TextStyle(
                  height: 1.15,
                  fontWeight: FontWeight.w600,
                  fontSize: w * 0.04,
                  color: ColorScheme.of(context).onSurface,

                ),
              ),

            ),

            // ======================================
            // DATE + TIME
            // ======================================
            Padding(
              padding: EdgeInsets.only(

                left: w * 0.087,
                right: w * 0.04,
              ),

              child: Row(
                children: [
                  SvgPicture.asset(
                    PartyPageData.calenderIcon,
                    color: ColorScheme.of(context).secondary.withValues(alpha: 0.4),
                    width: w * 0.045,
                  ),

                  SizedBox(width: w * 0.04),

                  Text(
                    dateFormating(
                      eventData.eventFrom
                          .toString()
                          .substring(0, 10),
                    ),

                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                     fontSize: w * 0.04,
                      color: ColorScheme.of(context).secondary,
                    ),
                  ),

                  SizedBox(width: w * 0.08),

                  SvgPicture.asset(
                    PartyPageData.clock,
                    color: ColorScheme.of(context).secondary.withValues(alpha: 0.4),
                    width: w * 0.045,
                  ),

                  SizedBox(width: w * 0.04),

                  Text(
                   timingConversionAccordingToPMAM(fromTime),

                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: w * 0.04,
                      color: ColorScheme.of(context).secondary,
                    ),
                  ),
                ],
              ),
            ),

            // ======================================
            // LOCATION
            // ======================================
            Padding(
              padding: EdgeInsets.only(
                top: h * 0.015,
                left: w * 0.087,
                right: w * 0.04,
              ),

              child: InkWell(
                onTap: () => _openLocation(context),

                child: Row(
                  children: [
                    SvgPicture.asset(
                      PartyPageData.addressIcon,
                      color: ColorScheme.of(context).secondary.withValues(alpha: 0.4),
                      width: w * 0.04,
                    ),

                    SizedBox(width: w * 0.04),

                    Expanded(
                      child: Text(maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        eventData.address?.addressText ?? "-",

                        style:  TextStyle(
                         fontSize: w * 0.04,
                          color:  eventData.address?.addressLink!=""?Colors.blue:ColorScheme.of(context).secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ======================================
            // ATTENDEES + SHARE + JOIN
            // ======================================
            Padding(
              padding: EdgeInsets.only(
                left: w * 0.05,
                top: h * 0.015,
              ),

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,

                children: [
                  // ATTENDEES
                  GestureDetector(
                    onTap: () {
                      if (eventData.id == null) return;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AttendanceCountPage(
                            eventId: eventData.id!,
                          ),
                        ),
                      );
                    },
                    child: EventAttendeesPreview(
                      attendees: eventData.attendeesPreview,
                      attendeeCount: eventData.attendeeCount ?? 0,
                      size: (w * 0.075).clamp(26.0, 32.0),
                    ),
                  ),

                  const Spacer(),
                  if(isAdmin||( isPolitician==true && fromWhichPage=="Politician"))...[
                    InkWell(
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                      onTap: () {
                        _showAdminMenu(context);
                      },

                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: w * 0.02,
                          vertical: h * 0.005,
                        ),
                        child: SvgPicture.asset(
                          PartyPageData.threeDots,
                          width: w * 0.045,
                        ),
                      ),
                    ),
                    SizedBox(width: w * 0.015),
                  ],

                  // SHARE
                  InkWell(
                    onTap: onShare,

                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: w * 0.01,
                        vertical: h * 0.005,
                      ),
                      child: SvgPicture.asset(
                        PartyPageData.share,
                        width: w * 0.045,
                      ),
                    ),
                  ),

                  SizedBox(width: w * 0.035),

                  // JOIN
                  if (eventData.displayJoinButton == true)
                    _buildJoinButton(
                      context,
                      w,
                      h,
                    ),
                ],
              ),
            ),
            if(eventData.displayJoinButton == false)
              SizedBox(height:w*0.009 ,),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CHECK EVENT ENDED
  // ============================================================

  bool _hasEventEnded(EventModel event) {
    DateTime? endDateTime;
    if (event.eventTo != null) {
      final t = event.timeTo ?? const TimeOfDay(hour: 23, minute: 59);
      endDateTime = DateTime(
        event.eventTo!.year,
        event.eventTo!.month,
        event.eventTo!.day,
        t.hour,
        t.minute,
      );
    } else if (event.eventFrom != null) {
      final t = event.timeTo ?? event.timeFrom ?? const TimeOfDay(hour: 23, minute: 59);
      endDateTime = DateTime(
        event.eventFrom!.year,
        event.eventFrom!.month,
        event.eventFrom!.day,
        t.hour,
        t.minute,
      );
    }

    if (endDateTime == null) return false;

    return DateTime.now().isAfter(endDateTime) ||
        DateTime.now().isAtSameMomentAs(endDateTime);
  }

  // ============================================================
  // JOIN BUTTON
  // ============================================================

  Widget _buildJoinButton(
      BuildContext context,
      double w,
      double h,
      ) {
    final bool hasEnded = _hasEventEnded(eventData);
    final isJoined =
        eventData.isRequestorAttending == true;

    return InkWell(
      onTap: (isJoining || hasEnded) ? null : onJoin,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      child: Container(
        height: h * 0.05,
        width: w * 0.20,

        decoration: BoxDecoration(
              gradient: GradientColors.primaryGradient,

          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(w * 0.08),
            bottomLeft: Radius.circular(w * 0.08),
          ),
        ),

        child: Center(
          child: isJoining
              ? SizedBox(
            height: h * 0.025,
            width: h * 0.025,

            child: CircularProgressIndicator(
              strokeWidth: 2.5,

              color: ColorScheme.of(context).surface,
            ),
          )

              : FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.015),
              child: Text(
                hasEnded
                    ? "ENDED"
                    : (isJoined ? "JOINED" : "JOIN"),

                textAlign: TextAlign.center,

                style: TextStyle(
                  color: ColorScheme.of(context).surface,

                  fontWeight: FontWeight.w700,
                  fontSize: w * 0.035,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOCATION
  // ============================================================

  Future<void> _openLocation(
      BuildContext context,
      ) async {
    final link =
        eventData.address?.addressLink ?? "";

    if (link.isEmpty) {
      return;
    }

    final url = Uri.parse(link);

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } else {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not open the map.',
          ),
        ),
      );
    }
  }

  // ============================================================
  // ADMIN MENU
  // ============================================================

  void _showAdminMenu(
      BuildContext context,
      ) {
    showGeneralDialog(
      context: context,

      barrierDismissible: true,

      barrierLabel: 'Close',

      barrierColor:
      Colors.black.withValues(alpha: 0.4),

      pageBuilder: (
          context,
          animation,
          secondaryAnimation,
          ) {
        return Stack(
          children: [
            Positioned(
              bottom:
              MediaQuery.of(context).size.height *
                  0.03 +
                  MediaQuery.of(context).size.width *
                      0.2 +
                  70,

              left: 0,
              right: 0,

              child: Center(
                child: VerticalActionMenu(
                  height:
                  MediaQuery.of(context).size.height *
                      0.35,

                  items: [
                    ActionMenuItem(
                      imageIcon:
                      PartyPageData.editIcon,

                      title:
                      PartyPageData.edit,

                      onTap: () {
                        Navigator.of(context).pop();

                        onEdit?.call();
                      },
                    ),

                    ActionMenuItem(
                      imageIcon:
                      PartyPageData.share,

                      title: "Share",

                      onTap: () {
                        Navigator.of(context).pop();

                        onShare?.call();
                      },
                    ),

                    ActionMenuItem(
                      imageIcon:
                      PartyPageData.deleteIcon,

                      title: "Delete",

                      onTap: () {
                        Navigator.of(context).pop();

                        onDelete?.call();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },

      transitionDuration:
      const Duration(milliseconds: 650),

      transitionBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
          ) {
        return SlideTransition(
          position:
          Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve:
              Curves.easeInOutCubic,
            ),
          ),

          child: child,
        );
      },
    );
  }
}

///---------------------------Timing conversation

String timingConversion(String fromDate) {
  String x = fromDate.substring(9);

  x = x.substring(1, 6);

  String firstTwo = x.substring(0, 2);
  String lastTwo = x.substring(3, 5);

  int firstTwoInNumbers = int.parse(firstTwo);

  String finalTime = "";

  if (firstTwoInNumbers > 12) {
    firstTwoInNumbers = firstTwoInNumbers - 12;

    finalTime = "${firstTwoInNumbers.toString()}:$lastTwo PM";
  } else if (firstTwoInNumbers == 12) {
    finalTime = "12 PM";
  } else if (firstTwoInNumbers == 0) {
    finalTime = "12 AM";
  } else {
    finalTime = "${firstTwoInNumbers.toString()}:$lastTwo AM";
  }

  return finalTime;
}


///------------------------------------
/// EXISTING EVENT MEDIA GRID
///------------------------------------
class ExistingEventMediaGrid extends StatelessWidget {
  final List<MediaModel> media;
  final void Function(int index) onRemove;

  const ExistingEventMediaGrid({
    super.key,
    required this.media,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (media.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: media.length,
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final item = media[index];

        final bool isVideo =
            item.mediaType?.toUpperCase() == 'VIDEO';

        return Stack(
          fit: StackFit.expand,
          children: [
            ///--------------------------------
            /// MEDIA
            ///--------------------------------
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: isVideo
                  ? _ExistingVideoPreview(
                videoUrl: item.url ?? '',
              )
                  : buildImageWidget(
                item.url ?? '',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            ///--------------------------------
            /// VIDEO PLAY ICON
            ///--------------------------------
            if (isVideo)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),

            ///--------------------------------
            /// REMOVE BUTTON
            ///--------------------------------
            Positioned(
              top: 5,
              right: 5,
              child: InkWell(
                onTap: () {
                  onRemove(index);
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

///------------------------------------
/// EXISTING VIDEO PREVIEW
///------------------------------------
class _ExistingVideoPreview extends StatefulWidget {
  final String videoUrl;

  const _ExistingVideoPreview({
    required this.videoUrl,
  });

  @override
  State<_ExistingVideoPreview> createState() =>
      _ExistingVideoPreviewState();
}

class _ExistingVideoPreviewState
    extends State<_ExistingVideoPreview> {
  late VideoPlayerController _controller;

  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );

    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      await _controller.initialize();

      if (!mounted) return;

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ///--------------------------------
    /// VIDEO FAILED
    ///--------------------------------
    if (_hasError) {
      return Container(
        color: Colors.black12,
        child: const Center(
          child: Icon(
            Icons.video_library_outlined,
            color: Colors.grey,
            size: 30,
          ),
        ),
      );
    }

    ///--------------------------------
    /// VIDEO LOADING
    ///--------------------------------
    if (!_isInitialized) {
      return Container(
        color: Colors.black12,
        child: const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }

    ///--------------------------------
    /// VIDEO
    ///--------------------------------
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: _controller.value.size.width,
          height: _controller.value.size.height,
          child: VideoPlayer(_controller),
        ),
      ),
    );
  }
}
