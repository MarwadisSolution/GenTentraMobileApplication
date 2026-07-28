import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ReusableTimelineSelector extends StatefulWidget {
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final ItemScrollController scrollController;

  const ReusableTimelineSelector({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    required this.scrollController
  });

  @override
  State<ReusableTimelineSelector> createState() =>
      _ReusableTimelineSelectorState();
}

class _ReusableTimelineSelectorState
    extends State<ReusableTimelineSelector> {
  // final ItemScrollController _scrollController = ItemScrollController();

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
    if (!widget.scrollController.isAttached) return;

    if (widget.items.isEmpty) return;

    if (index < 0 || index >= widget.items.length) return;

    if (animated) {
      widget.scrollController.scrollTo(
        index: index,
        alignment: 0.5,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.scrollController.jumpTo(
        index: index,
        alignment: 0.5,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const double itemWidth = 110;

    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 90,
      child: Stack(
       alignment: Alignment.center,
        children: [
        Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Selected year
          // Text(
          //   widget.items[widget.selectedIndex],
          //   style: const TextStyle(
          //     fontSize: 20,
          //     fontWeight: FontWeight.bold,
          //     color: Colors.black,
          //   ),
          // ),

          const SizedBox(height: 8),

          // Black circle
          Container(
            width: 74,
            height: 74,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            child: Column(
              children: [
                // Red dot
                SizedBox(height: MediaQuery.of(context).size.height*0.025,),
                Text(
                  widget.items[widget.selectedIndex],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Icon(
                  Icons.circle,
                  color: Colors.red,
                  size: 8,
                ),
              ],
            ),
          ),
        ],
        ),
          // Scrolling timeline underneath


          // Fixed indicator
          Positioned(
           child:  Center(
              child: ScrollablePositionedList.builder(
                itemScrollController: widget.scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: widget.items.length,
                padding: EdgeInsets.symmetric(
                  horizontal:
                  MediaQuery.of(context).size.width / 2 - itemWidth/1.2,
                ),
                itemBuilder: (context, index) {
                  final isSelected = index == widget.selectedIndex;
                  return GestureDetector(
                    onTap: () => widget.onChanged(index),
                    child: SizedBox(
                      width: itemWidth,
                      child: Center(
                        child: Text(

                          widget.items[index],

                          style: TextStyle(
                            color:   isSelected ? Colors.transparent : Colors.grey.shade500,
                            fontSize: 16,
                            fontWeight:  isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

        ],
      ),
    );

    // return SizedBox(
    //   height: 90,
    //   child: ScrollablePositionedList.builder(
    //     itemScrollController: _scrollController,
    //     scrollDirection: Axis.horizontal,
    //     itemCount: widget.items.length,
    //     itemBuilder: (context, index) {
    //       final isSelected = index == widget.selectedIndex;
    //
    //       return GestureDetector(
    //         onTap: () => widget.onChanged(index),
    //         child: Container(
    //           width: 100,
    //           alignment: Alignment.center,
    //           child: AnimatedContainer(
    //             duration: const Duration(milliseconds: 250),
    //             width: isSelected ? 74 : 50,
    //             height: isSelected ? 74 : 50,
    //             decoration: isSelected
    //                 ? const BoxDecoration(
    //               color: Colors.black,
    //               shape: BoxShape.circle,
    //             )
    //                 : null,
    //             child: isSelected
    //                 ? Column(
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               children: [
    //                 Text(
    //                   widget.items[index],
    //                   style: const TextStyle(
    //                     color: Colors.white,
    //                     fontSize: 18,
    //                     fontWeight: FontWeight.w600,
    //                   ),
    //                 ),
    //                 const SizedBox(height: 4),
    //                 const Icon(
    //                   Icons.circle,
    //                   color: Colors.red,
    //                   size: 8,
    //                 )
    //               ],
    //             )
    //                 : Text(
    //               widget.items[index],
    //               style: TextStyle(
    //                 fontSize: 16,
    //                 color: Colors.grey.shade500,
    //               ),
    //             ),
    //           ),
    //         ),
    //       );
    //     },
    //   ),
    // );
  }
}