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
  final h = MediaQuery.of(context).size.height;

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
                  color: Colors.black.withOpacity(0.55),
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
                      color: Colors.black.withOpacity(0.55),
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

enum EventRangePickerType {
  date,
  time,
}

class EventRangePicker extends StatelessWidget {
  final EventRangePickerType type;

  final String label;
  final bool isRequired;

  // Date
  final DateTime? fromDate;
  final DateTime? toDate;

  // Time
  final TimeOfDay? fromTime;
  final TimeOfDay? toTime;

  // Callbacks
  final ValueChanged<DateTimeRange>? onDateRangeSelected;
  final ValueChanged<TimeOfDayRange>? onTimeRangeSelected;

  const EventRangePicker({
    super.key,
    required this.type,
    required this.label,
    this.isRequired = false,

    this.fromDate,
    this.toDate,

    this.fromTime,
    this.toTime,

    this.onDateRangeSelected,
    this.onTimeRangeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
final w=MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () {
        if (type == EventRangePickerType.date) {
          _selectDateRange(context);
        } else {
          _selectTimeRange(context);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          label: RichText(
            text: TextSpan(
              text: label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
              children: [
                if (isRequired)
                  const TextSpan(
                    text: '*',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey.shade400,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: h * 0.026,
          ),
          suffixIcon: Padding(
            padding:  EdgeInsets.only(right: w*0.09),
            child: SizedBox(
              width: 15,
              height: 15,
              child: SvgPicture.asset(
                type == EventRangePickerType.date
                    ? PartyPageData.dateIcon
                    : PartyPageData.clockIcon,
                color:   type == EventRangePickerType.date?Colors.black.withOpacity(0.44):null,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _fromText(),
                style: TextStyle(
                  fontSize: (MediaQuery.of(context).size.width * 0.045).clamp(14.0, 18.0),
                  fontWeight: FontWeight.w300,
                  letterSpacing: 0.5,
                  color: _isFromEmpty()
                      ? Colors.black.withOpacity(0.5)
                      : Colors.black,
                ),
              ),
            ),

             Text(
              "To",
              style: TextStyle(
                fontSize: (MediaQuery.of(context).size.width * 0.045).clamp(14.0, 18.0),
                fontWeight: FontWeight.w300,
                letterSpacing: 0.5,
                color: Colors.black
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Text(
                _toText(),
                style: TextStyle(
                  fontSize: (MediaQuery.of(context).size.width * 0.045).clamp(14.0, 18.0),
                  fontWeight: FontWeight.w300,
                  letterSpacing: 0.5,
                  color: _isToEmpty()
                      ? Colors.black.withOpacity(0.5)
                      : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DISPLAY TEXT
  // ============================================================

  String _fromText() {
    if (type == EventRangePickerType.date) {
      if (fromDate == null) {
        return "DD MM YYYY";
      }

      return _formatDate(fromDate!);
    }

    if (fromTime == null) {
      return "HH MM";
    }

    return _formatTime(fromTime!);
  }

  String _toText() {
    if (type == EventRangePickerType.date) {
      if (toDate == null) {
        return "DD MM YYYY";
      }

      return _formatDate(toDate!);
    }

    if (toTime == null) {
      return "HH MM";
    }

    return _formatTime(toTime!);
  }

  bool _isFromEmpty() {
    return type == EventRangePickerType.date
        ? fromDate == null
        : fromTime == null;
  }

  bool _isToEmpty() {
    return type == EventRangePickerType.date
        ? toDate == null
        : toTime == null;
  }

  // ============================================================
  // DATE RANGE
  // ============================================================

  Future<void> _selectDateRange(BuildContext context) async {
    final now = DateTime.now();

    // ----------------------------------------------------------
    // 1. SELECT FROM DATE
    // ----------------------------------------------------------

    DateTime tempFromDate = fromDate ?? now;

    final DateTime? selectedFromDate =
    await _showCupertinoDatePicker(
      context: context,
      initialDate: tempFromDate,
      minimumDate: DateTime(
        now.year,
        now.month,
        now.day,
      ),
      title: "Select From Date",
    );

    if (selectedFromDate == null) {
      return;
    }

    // ----------------------------------------------------------
    // 2. SELECT TO DATE
    // ----------------------------------------------------------

    DateTime tempToDate;

    if (toDate != null &&
        !toDate!.isBefore(selectedFromDate)) {
      tempToDate = toDate!;
    } else {
      tempToDate = selectedFromDate;
    }

    final DateTime? selectedToDate =
    await _showCupertinoDatePicker(
      context: context,
      initialDate: tempToDate,
      minimumDate: selectedFromDate,
      title: "Select To Date",
    );

    if (selectedToDate == null) {
      return;
    }

    // ----------------------------------------------------------
    // SEND BOTH DATES TO BLOC
    // ----------------------------------------------------------

    onDateRangeSelected?.call(
      DateTimeRange(
        start: selectedFromDate,
        end: selectedToDate,
      ),
    );
  }

  // ============================================================
  // REUSABLE DATE PICKER
  // ============================================================

  Future<DateTime?> _showCupertinoDatePicker({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime minimumDate,
    required String title,
  }) async {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    DateTime tempDate = initialDate;

    return showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (context) {
        return Container(
          height: h * 0.35,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // ------------------------------------------------
              // TOP BAR
              // ------------------------------------------------

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: w * 0.04,
                  vertical: h * 0.015,
                ),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Color(0xFFFF2164),
                        ),
                      ),
                    ),

                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),

                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Navigator.pop(
                          context,
                          tempDate,
                        );
                      },
                      child: const Text(
                        "Done",
                        style: TextStyle(
                          color: Color(0xFFFF2164),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ------------------------------------------------
              // DATE PICKER
              // ------------------------------------------------

              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: initialDate,
                  minimumDate: minimumDate,
                  maximumDate: DateTime(2100),
                  onDateTimeChanged: (value) {
                    tempDate = value;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // TIME RANGE
  // ============================================================

  Future<void> _selectTimeRange(BuildContext context) async {
    final now = DateTime.now();

    // ----------------------------------------------------------
    // 1. SELECT FROM TIME
    // ----------------------------------------------------------

    final TimeOfDay initialFromTime =
        fromTime ?? TimeOfDay.now();

    final TimeOfDay? selectedFromTime =
    await _showCupertinoTimePicker(
      context: context,
      initialTime: initialFromTime,
      title: "Select From Time",
    );

    if (selectedFromTime == null) {
      return;
    }

    // ----------------------------------------------------------
    // 2. SELECT TO TIME
    // ----------------------------------------------------------

    final TimeOfDay initialToTime =
        toTime ?? _addOneHour(selectedFromTime);

    final TimeOfDay? selectedToTime =
    await _showCupertinoTimePicker(
      context: context,
      initialTime: initialToTime,
      title: "Select To Time",
    );

    if (selectedToTime == null) {
      return;
    }

    // ----------------------------------------------------------
    // VALIDATE TIME
    // ----------------------------------------------------------

    final fromMinutes =
        selectedFromTime.hour * 60 +
            selectedFromTime.minute;

    final toMinutes =
        selectedToTime.hour * 60 +
            selectedToTime.minute;

    if (toMinutes < fromMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "To time cannot be earlier than From time",
          ),
        ),
      );

      return;
    }

    // ----------------------------------------------------------
    // SEND BOTH TIMES TO BLOC
    // ----------------------------------------------------------

    onTimeRangeSelected?.call(
      TimeOfDayRange(
        start: selectedFromTime,
        end: selectedToTime,
      ),
    );
  }

  // ============================================================
  // REUSABLE TIME PICKER
  // ============================================================

  Future<TimeOfDay?> _showCupertinoTimePicker({
    required BuildContext context,
    required TimeOfDay initialTime,
    required String title,
  }) async {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    DateTime tempDateTime = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      initialTime.hour,
      initialTime.minute,
    );

    return showCupertinoModalPopup<TimeOfDay>(
      context: context,
      builder: (context) {
        return Container(
          height: h * 0.35,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // ------------------------------------------------
              // TOP BAR
              // ------------------------------------------------

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: w * 0.04,
                  vertical: h * 0.015,
                ),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Color(0xFFFF2164),
                        ),
                      ),
                    ),

                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),

                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Navigator.pop(
                          context,
                          TimeOfDay(
                            hour: tempDateTime.hour,
                            minute: tempDateTime.minute,
                          ),
                        );
                      },
                      child: const Text(
                        "Done",
                        style: TextStyle(
                          color: Color(0xFFFF2164),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ------------------------------------------------
              // TIME PICKER
              // ------------------------------------------------

              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: tempDateTime,
                  use24hFormat: false,
                  onDateTimeChanged: (value) {
                    tempDateTime = value;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  TimeOfDay _addOneHour(TimeOfDay time) {
    final minutes =
        time.hour * 60 + time.minute + 60;

    return TimeOfDay(
      hour: (minutes ~/ 60) % 24,
      minute: minutes % 60,
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')} "
        "${date.month.toString().padLeft(2, '0')} "
        "${date.year}";
  }

  String _formatTime(TimeOfDay time) {
    final hour =
    time.hourOfPeriod == 0
        ? 12
        : time.hourOfPeriod;

    final minute =
    time.minute.toString().padLeft(2, '0');

    final period =
    time.period == DayPeriod.am
        ? "AM"
        : "PM";

    return "$hour:$minute $period";
  }
}

// ============================================================
// TIME RANGE MODEL
// ============================================================

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
          color: const Color(0xFF000000).withOpacity(0.08),
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
          const SizedBox(width: 6),

          Text(
            "+${formatAttendeeCount(remainingCount)}",
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
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
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final w = size.width;
    final h = size.height;

    return Card(

      shadowColor: Colors.black.withOpacity(0.2),

      key: ValueKey(eventData.id),

      margin: const EdgeInsets.symmetric(horizontal: 12),

      color: ColorScheme.of(context).surface,

      elevation: 10,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(w*0.055),
        side: BorderSide(color: Colors.black.withOpacity(0.1))
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
                  child: SizedBox.expand(
                    child: buildImageWidget(
                      eventData.author?.photoUrl ?? "",
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
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

              // ======================================
              // ADMIN THREE DOTS
              // ======================================

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
                    color: ColorScheme.of(context).secondary.withOpacity(0.4),
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
                    color: ColorScheme.of(context).secondary.withOpacity(0.4),
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
                      color: ColorScheme.of(context).secondary.withOpacity(0.4),
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
                      size: 40,
                    ),
                  ),

                  const Spacer(),
                  if(isAdmin)...[
                    InkWell(
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                      onTap: () {
                        _showAdminMenu(context);
                      },

                      child:  SizedBox(
                        width: w*0.2,
                        height: h*0.04,

                        child: Center(
                            child:SvgPicture.asset(PartyPageData.threeDots,width: w*0.05,)
                        ),
                      ),
                    )
                  ],

                  // SHARE
                  InkWell(
                    onTap: onShare,

                    child: SvgPicture.asset(
                      PartyPageData.share,
                      width: w*0.05,
                    ),
                  ),

                  SizedBox(width: w * 0.06),

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
  // JOIN BUTTON
  // ============================================================

  Widget _buildJoinButton(
      BuildContext context,
      double w,
      double h,
      ) {
    final isJoined =
        eventData.isRequestorAttending == true;

    return InkWell(
      onTap: isJoining ? null : onJoin,
overlayColor: WidgetStateProperty.all(Colors.transparent),
      child: Container(
        height: h * 0.05,
        width: w * 0.20,

        decoration: BoxDecoration(
          gradient: isJoined
              ? null
              : GradientColors.primaryGradient,

          color: isJoined
              ? Colors.red.withOpacity(0.3)
              : null,

          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(w * 0.08),
            bottomLeft: Radius.circular(w * 0.08),
           // bottomRight: Radius.circular(w*0.025),
          ),
        ),

        child: Center(
          child: isJoining
              ? SizedBox(
            height: h * 0.025,
            width: h * 0.025,

            child: CircularProgressIndicator(
              strokeWidth: 2.5,

              color: isJoined
                  ? const Color(0xFFFE3A31)
                  : ColorScheme.of(context).surface,
            ),
          )

              : Text(
            isJoined ? "JOINED" : "JOIN",

            textAlign: TextAlign.center,

            style: TextStyle(
              color: isJoined
                  ? const Color(0xFFFE3A31)
                  : ColorScheme.of(context).surface,

              fontWeight: FontWeight.w700,
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
      Colors.black.withOpacity(0.4),

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

///------------------------------------
/// EXISTING VIDEO PREVIEW
///------------------------------------
// class _ExistingVideoPreview extends StatefulWidget {
//   final String videoUrl;
//
//   const _ExistingVideoPreview({
//     required this.videoUrl,
//   });
//
//   @override
//   State<_ExistingVideoPreview> createState() =>
//       _ExistingVideoPreviewState();
// }
//
// class _ExistingVideoPreviewState
//     extends State<_ExistingVideoPreview> {
//   late VideoPlayerController _controller;
//
//   bool _isInitialized = false;
//   bool _hasError = false;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _controller = VideoPlayerController.networkUrl(
//       Uri.parse(widget.videoUrl),
//     );
//
//     _initializeVideo();
//   }
//
//   Future<void> _initializeVideo() async {
//     try {
//       await _controller.initialize();
//
//       if (!mounted) return;
//
//       setState(() {
//         _isInitialized = true;
//       });
//     } catch (_) {
//       if (!mounted) return;
//
//       setState(() {
//         _hasError = true;
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     ///--------------------------------
//     /// VIDEO FAILED
//     ///--------------------------------
//     if (_hasError) {
//       return Container(
//         color: Colors.black12,
//         child: const Center(
//           child: Icon(
//             Icons.video_library_outlined,
//             color: Colors.grey,
//             size: 30,
//           ),
//         ),
//       );
//     }
//
//     ///--------------------------------
//     /// VIDEO LOADING
//     ///--------------------------------
//     if (!_isInitialized) {
//       return Container(
//         color: Colors.black12,
//         child: const Center(
//           child: SizedBox(
//             width: 22,
//             height: 22,
//             child: CircularProgressIndicator(
//               strokeWidth: 2,
//             ),
//           ),
//         ),
//       );
//     }
//
//     ///--------------------------------
//     /// VIDEO
//     ///--------------------------------
//     return SizedBox.expand(
//       child: FittedBox(
//         fit: BoxFit.cover,
//         clipBehavior: Clip.hardEdge,
//         child: SizedBox(
//           width: _controller.value.size.width,
//           height: _controller.value.size.height,
//           child: VideoPlayer(_controller),
//         ),
//       ),
//     );
//   }
// }
