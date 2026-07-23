import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ReusableTimelineSelector extends StatefulWidget {
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const ReusableTimelineSelector({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  State<ReusableTimelineSelector> createState() =>
      _ReusableTimelineSelectorState();
}

class _ReusableTimelineSelectorState
    extends State<ReusableTimelineSelector> {
  final ItemScrollController _scrollController = ItemScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollTo(widget.selectedIndex, false);
    });
  }

  @override
  void didUpdateWidget(covariant ReusableTimelineSelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _scrollTo(widget.selectedIndex, true);
    }
  }

  void _scrollTo(int index, bool animated) {
    if (!_scrollController.isAttached) return;

    if (animated) {
      _scrollController.scrollTo(
        index: index,
        alignment: 0.5, // <-- center of screen
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _scrollController.jumpTo(
        index: index,
        alignment: 0.5,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ScrollablePositionedList.builder(
        itemScrollController: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final isSelected = index == widget.selectedIndex;

          return GestureDetector(
            onTap: () => widget.onChanged(index),
            child: Container(
              width: 100,
              alignment: Alignment.center,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: isSelected ? 74 : 50,
                height: isSelected ? 74 : 50,
                decoration: isSelected
                    ? const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                )
                    : null,
                child: isSelected
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.items[index],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Icon(
                      Icons.circle,
                      color: Colors.red,
                      size: 8,
                    )
                  ],
                )
                    : Text(
                  widget.items[index],
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}