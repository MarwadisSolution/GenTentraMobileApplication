import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
          suffixIcon: Icon(
            type == EventRangePickerType.date
                ? Icons.calendar_month_outlined
                : Icons.access_time_outlined,
            color: Colors.grey.shade600,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _fromText(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _isFromEmpty()
                      ? Colors.grey
                      : Colors.black,
                ),
              ),
            ),

            const Text(
              "To",
              style: TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Text(
                _toText(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _isToEmpty()
                      ? Colors.grey
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
        return "From Date";
      }

      return _formatDate(fromDate!);
    }

    if (fromTime == null) {
      return "From Time";
    }

    return _formatTime(fromTime!);
  }

  String _toText() {
    if (type == EventRangePickerType.date) {
      if (toDate == null) {
        return "To Date";
      }

      return _formatDate(toDate!);
    }

    if (toTime == null) {
      return "To Time";
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

///--------------Radio buttons
Widget radioButtons(
    String name,
    bool value,
    bool? selectedValue,
    double screenHeight,
    ValueChanged<bool?> onChanged,
    ) {
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
        child: _buildAddButton(),
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
        _buildAddButton(),
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

  Widget _buildAddButton() {
    return InkWell(
      onTap: onAddMedia,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 85,
        height: 85,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFBFC1CC),
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 28,
              color: Color(0xFFFF2164),
            ),
            SizedBox(height: 5),
            Text(
              "Add Media",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
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

