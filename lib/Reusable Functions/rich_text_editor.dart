import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'package:flutter_bloc/flutter_bloc.dart';

///-------------------------Bloc------------------------------------------
// EVENTS

abstract class RichTextEvent {
  const RichTextEvent();
}

class ExpandRichText extends RichTextEvent {
  const ExpandRichText();
}

class CollapseRichText extends RichTextEvent {
  const CollapseRichText();
}

class ResetRichText extends RichTextEvent {
  const ResetRichText();
}


// STATE


class RichTextState {
  final bool expanded;

  const RichTextState({
    this.expanded = false,
  });

  RichTextState copyWith({
    bool? expanded,
  }) {
    return RichTextState(
      expanded: expanded ?? this.expanded,
    );
  }
}



// BLOC


class RichTextBloc extends Bloc<RichTextEvent, RichTextState> {
  RichTextBloc() : super(const RichTextState()) {
    on<ExpandRichText>((event, emit) {
      emit(
        state.copyWith(
          expanded: true,
        ),
      );
    });

    on<CollapseRichText>((event, emit) {
      emit(
        state.copyWith(
          expanded: false,
        ),
      );
    });

    on<ResetRichText>((event, emit) {
      emit(
        const RichTextState(
          expanded: false,
        ),
      );
    });
  }
}
///------------------------------------------------------------------------------------


// ============================================================================
// TEXT STYLE RANGE
// ============================================================================

class TextStyleRange {
  int start;
  int end;

  bool bold;
  bool italic;
  bool underline;

  TextStyleRange({
    required this.start,
    required this.end,
    this.bold = false,
    this.italic = false,
    this.underline = false,
  });

  TextStyleRange copy() {
    return TextStyleRange(
      start: start,
      end: end,
      bold: bold,
      italic: italic,
      underline: underline,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start,
      'end': end,
      'bold': bold,
      'italic': italic,
      'underline': underline,
    };
  }

  factory TextStyleRange.fromJson(
      Map<String, dynamic> json,
      ) {
    return TextStyleRange(
      start: json['start'] ?? 0,
      end: json['end'] ?? 0,
      bold: json['bold'] ?? false,
      italic: json['italic'] ?? false,
      underline: json['underline'] ?? false,
    );
  }
}


// ============================================================================
// RICH TEXT VALUE
// ============================================================================

class RichTextValue {
  final String text;
  final List<TextStyleRange> styles;

  const RichTextValue({
    required this.text,
    required this.styles,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'styles': styles
          .map((e) => e.toJson())
          .toList(),
    };
  }

  String encode() {
    return jsonEncode(toJson());
  }

  factory RichTextValue.decode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return const RichTextValue(
        text: '',
        styles: [],
      );
    }

    try {
      final decoded = jsonDecode(value);

      if (decoded is Map<String, dynamic>) {
        return RichTextValue(
          text: decoded['text'] ?? '',
          styles: (decoded['styles'] as List? ?? [])
              .map(
                (e) => TextStyleRange.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
              .toList(),
        );
      }
    } catch (_) {
      // Backward compatibility with plain text.
    }

    return RichTextValue(
      text: value,
      styles: [],
    );
  }
}


// ============================================================================
// RICH TEXT EDITING CONTROLLER
// ============================================================================

class RichTextEditingController
    extends TextEditingController {
  RichTextEditingController({
    String? text,
    List<TextStyleRange>? styles,
  })  : styles = styles ?? [],
        super(text: text);

  final List<TextStyleRange> styles;

  bool get boldActive {
    return _isStyleActive(
      selection.start,
      selection.end,
          (s) => s.bold,
    );
  }

  bool get italicActive {
    return _isStyleActive(
      selection.start,
      selection.end,
          (s) => s.italic,
    );
  }

  bool get underlineActive {
    return _isStyleActive(
      selection.start,
      selection.end,
          (s) => s.underline,
    );
  }

  bool _isStyleActive(
      int start,
      int end,
      bool Function(TextStyleRange) checker,
      ) {
    if (start == end) {
      final position = start;

      for (final range in styles) {
        if (position >= range.start &&
            position <= range.end &&
            checker(range)) {
          return true;
        }
      }

      return false;
    }

    for (final range in styles) {
      if (range.start <= start &&
          range.end >= end &&
          checker(range)) {
        return true;
      }
    }

    return false;
  }

  void toggleBold() {
    _toggleStyle(
          (range) => range.bold,
          (range, value) => range.bold = value,
    );
  }

  void toggleItalic() {
    _toggleStyle(
          (range) => range.italic,
          (range, value) => range.italic = value,
    );
  }

  void toggleUnderline() {
    _toggleStyle(
          (range) => range.underline,
          (range, value) => range.underline = value,
    );
  }

  void _toggleStyle(
      bool Function(TextStyleRange) getter,
      void Function(TextStyleRange, bool) setter,
      ) {
    final start = selection.start;
    final end = selection.end;

    if (start == end) {
      return;
    }

    final active = _isStyleActive(
      start,
      end,
      getter,
    );

    for (int i = start; i < end; i++) {
      TextStyleRange? existing;

      for (final range in styles) {
        if (i >= range.start &&
            i < range.end) {
          existing = range;
          break;
        }
      }

      if (existing == null) {
        final range = TextStyleRange(
          start: i,
          end: i + 1,
        );

        setter(range, !active);
        styles.add(range);
      } else {
        setter(existing, !active);
      }
    }

    _cleanupStyles();

    notifyListeners();
  }

  void _cleanupStyles() {
    styles.removeWhere(
          (range) =>
      range.start >= range.end ||
          (!range.bold &&
              !range.italic &&
              !range.underline),
    );

    styles.sort(
          (a, b) => a.start.compareTo(b.start),
    );

    final merged = <TextStyleRange>[];

    for (final range in styles) {
      if (merged.isEmpty) {
        merged.add(range.copy());
        continue;
      }

      final previous = merged.last;

      if (previous.end == range.start &&
          previous.bold == range.bold &&
          previous.italic == range.italic &&
          previous.underline == range.underline) {
        previous.end = range.end;
      } else {
        merged.add(range.copy());
      }
    }

    styles
      ..clear()
      ..addAll(merged);
  }

  RichTextValue get valueAsRichText {
    return RichTextValue(
      text: text,
      styles: styles
          .map((e) => e.copy())
          .toList(),
    );
  }

  String get jsonValue {
    return valueAsRichText.encode();
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    if (text.isEmpty) {
      return TextSpan(
        text: '',
        style: style,
      );
    }

    final children = <TextSpan>[];

    for (int i = 0; i < text.length; i++) {
      TextStyle currentStyle =
          style ?? const TextStyle();

      for (final range in styles) {
        if (i >= range.start &&
            i < range.end) {
          currentStyle = currentStyle.copyWith(
            fontWeight: range.bold
                ? FontWeight.bold
                : null,
            fontStyle: range.italic
                ? FontStyle.italic
                : null,
            decoration: range.underline
                ? TextDecoration.underline
                : TextDecoration.none,
          );

          break;
        }
      }

      children.add(
        TextSpan(
          text: text[i],
          style: currentStyle,
        ),
      );
    }

    return TextSpan(
      style: style,
      children: children,
    );
  }
}


// ============================================================================
// APP RICH TEXT EDITOR
// ============================================================================

class AppRichTextEditor extends StatefulWidget {
  final String fieldKey;
  final String? value;

  final void Function(
      String fieldKey,
      String value,
      )? onChanged;

  final bool readOnly;

  final String placeholder;

  final double editorHeight;

  final bool autofocus;

  const AppRichTextEditor({
    super.key,
    required this.fieldKey,
    this.value,
    this.onChanged,
    this.readOnly = false,
    this.placeholder = 'Write here...',
    this.editorHeight = 250,
    this.autofocus = false,
  });

  @override
  State<AppRichTextEditor> createState() =>
      _AppRichTextEditorState();
}

class _AppRichTextEditorState
    extends State<AppRichTextEditor> {
  late RichTextEditingController _controller;

  late FocusNode _focusNode;

  bool _internalChange = false;

  @override
  void initState() {
    super.initState();

    final value = RichTextValue.decode(
      widget.value,
    );

    _controller = RichTextEditingController(
      text: value.text,
      styles: value.styles,
    );

    _focusNode = FocusNode();

    _controller.addListener(
      _handleTextChange,
    );

    if (widget.autofocus &&
        !widget.readOnly) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  void _handleTextChange() {
    if (_internalChange) {
      return;
    }

    widget.onChanged?.call(
      widget.fieldKey,
      _controller.jsonValue,
    );
  }

  void _toggleBold() {
    if (widget.readOnly) return;

    _controller.toggleBold();

    _focusNode.requestFocus();

    _emitChange();
  }

  void _toggleItalic() {
    if (widget.readOnly) return;

    _controller.toggleItalic();

    _focusNode.requestFocus();

    _emitChange();
  }

  void _toggleUnderline() {
    if (widget.readOnly) return;

    _controller.toggleUnderline();

    _focusNode.requestFocus();

    _emitChange();
  }

  void _emitChange() {
    widget.onChanged?.call(
      widget.fieldKey,
      _controller.jsonValue,
    );
  }

  @override
  void didUpdateWidget(
      covariant AppRichTextEditor oldWidget,
      ) {
    super.didUpdateWidget(oldWidget);

    if (widget.value == oldWidget.value) {
      return;
    }

    final incoming =
    RichTextValue.decode(widget.value);

    if (incoming.text == _controller.text &&
        _sameStyles(
          incoming.styles,
          _controller.styles,
        )) {
      return;
    }

    _internalChange = true;

    _controller.value = TextEditingValue(
      text: incoming.text,
      selection: TextSelection.collapsed(
        offset: incoming.text.length,
      ),
    );

    _controller.styles
      ..clear()
      ..addAll(
        incoming.styles.map(
              (e) => e.copy(),
        ),
      );

    _internalChange = false;
  }

  bool _sameStyles(
      List<TextStyleRange> a,
      List<TextStyleRange> b,
      ) {
    if (a.length != b.length) {
      return false;
    }

    for (int i = 0; i < a.length; i++) {
      final x = a[i];
      final y = b[i];

      if (x.start != y.start ||
          x.end != y.end ||
          x.bold != y.bold ||
          x.italic != y.italic ||
          x.underline != y.underline) {
        return false;
      }
    }

    return true;
  }

  // ==========================================================================
  // READ ONLY
  // ==========================================================================

  Widget _buildReadOnlyView() {
    final richValue =
    RichTextValue.decode(widget.value);

    if (richValue.text.isEmpty) {
      return const SizedBox.shrink();
    }

    return BlocProvider(
      create: (_) => RichTextBloc(),
      child: _ReadOnlyRichText(
        value: richValue,
        textStyle: const TextStyle(
          fontSize: 15,
          height: 1.5,
          color: Colors.black87,
        ),
      ),
    );
  }

  // ==========================================================================
  // TOOLBAR
  // ==========================================================================

  Widget _toolbarButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool active,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed:
        widget.readOnly ? null : onPressed,
        icon: Icon(
          icon,
          color: active
              ? Theme.of(context)
              .colorScheme
              .primary
              : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    if (widget.readOnly) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        _toolbarButton(
          icon: Icons.format_bold,
          tooltip: 'Bold',
          active: _controller.boldActive,
          onPressed: _toggleBold,
        ),
        _toolbarButton(
          icon: Icons.format_italic,
          tooltip: 'Italic',
          active: _controller.italicActive,
          onPressed: _toggleItalic,
        ),
        _toolbarButton(
          icon: Icons.format_underlined,
          tooltip: 'Underline',
          active: _controller.underlineActive,
          onPressed: _toggleUnderline,
        ),
      ],
    );
  }

  // ==========================================================================
  // EDITOR
  // ==========================================================================

  Widget _buildEditor() {
    return Column(
      children: [
        _buildToolbar(),

        const Divider(
          height: 1,
          color: Colors.black,
        ),

        SizedBox(
          height: widget.editorHeight,
          child: Shortcuts(
            shortcuts: const {
              SingleActivator(
                LogicalKeyboardKey.keyB,
                control: true,
              ): _BoldIntent(),

              SingleActivator(
                LogicalKeyboardKey.keyI,
                control: true,
              ): _ItalicIntent(),

              SingleActivator(
                LogicalKeyboardKey.keyU,
                control: true,
              ): _UnderlineIntent(),
            },
            child: Actions(
              actions: {
                _BoldIntent:
                CallbackAction<_BoldIntent>(
                  onInvoke: (_) {
                    _toggleBold();
                    return null;
                  },
                ),
                _ItalicIntent:
                CallbackAction<_ItalicIntent>(
                  onInvoke: (_) {
                    _toggleItalic();
                    return null;
                  },
                ),
                _UnderlineIntent:
                CallbackAction<_UnderlineIntent>(
                  onInvoke: (_) {
                    _toggleUnderline();
                    return null;
                  },
                ),
              },
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: widget.autofocus,
                cursorColor: Colors.black,
                maxLines: null,
                expands: true,
                textAlignVertical:
                TextAlignVertical.top,
                keyboardType:
                TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: widget.placeholder,
                  border: InputBorder.none,
                  contentPadding:
                  const EdgeInsets.all(16),
                ),
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    if (widget.readOnly) {
      return _buildReadOnlyView();
    }

    return _buildEditor();
  }

  // ==========================================================================
  // DISPOSE
  // ==========================================================================

  @override
  void dispose() {
    _controller.removeListener(
      _handleTextChange,
    );

    _controller.dispose();
    _focusNode.dispose();

    super.dispose();
  }
}


// ============================================================================
// READ ONLY RICH TEXT
// ============================================================================

class _ReadOnlyRichText extends StatelessWidget {
  final RichTextValue value;

  final TextStyle textStyle;

  const _ReadOnlyRichText({
    required this.value,
    required this.textStyle,
  });

  List<TextSpan> _buildSpans() {
    final text = value.text;

    if (text.isEmpty) {
      return [];
    }

    final spans = <TextSpan>[];

    final positions = <int>{
      0,
      text.length,
    };

    for (final range in value.styles) {
      positions.add(
        range.start.clamp(
          0,
          text.length,
        ),
      );

      positions.add(
        range.end.clamp(
          0,
          text.length,
        ),
      );
    }

    final sortedPositions =
    positions.toList()..sort();

    for (
    int i = 0;
    i < sortedPositions.length - 1;
    i++
    ) {
      final start = sortedPositions[i];
      final end = sortedPositions[i + 1];

      if (start >= end) {
        continue;
      }

      bool bold = false;
      bool italic = false;
      bool underline = false;

      for (final range in value.styles) {
        if (start >= range.start &&
            start < range.end) {
          bold = range.bold;
          italic = range.italic;
          underline = range.underline;
          break;
        }
      }

      spans.add(
        TextSpan(
          text: text.substring(
            start,
            end,
          ),
          style: textStyle.copyWith(
            fontWeight: bold
                ? FontWeight.bold
                : null,
            fontStyle: italic
                ? FontStyle.italic
                : null,
            decoration: underline
                ? TextDecoration.underline
                : TextDecoration.none,
          ),
        ),
      );
    }

    return spans;
  }

  bool _hasMoreThanThreeLines(
      BuildContext context,
      double maxWidth,
      ) {
    final painter = TextPainter(
      text: TextSpan(
        children: _buildSpans(),
      ),
      textDirection:
      Directionality.of(context),
      maxLines: 3,
    );

    painter.layout(
      maxWidth: maxWidth,
    );

    return painter.didExceedMaxLines;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
        RichTextBloc,
        RichTextState>(
      buildWhen: (previous, current) =>
      previous.expanded !=
          current.expanded,
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final hasMore =
            _hasMoreThanThreeLines(
              context,
              constraints.maxWidth,
            );

            return Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: _buildSpans(),
                  ),
                  maxLines:
                  state.expanded
                      ? null
                      : 3,
                  overflow:
                  state.expanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                ),

                if (hasMore)
                  Padding(
                    padding:
                    const EdgeInsets.only(
                      top: 4,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        if (state.expanded) {
                          context
                              .read<RichTextBloc>()
                              .add(
                            const CollapseRichText(),
                          );
                        } else {
                          context
                              .read<RichTextBloc>()
                              .add(
                            const ExpandRichText(),
                          );
                        }
                      },
                      child: Text(
                        state.expanded
                            ? 'Read Less'
                            : 'Read More',
                        style:
                        const TextStyle(
                          fontSize: 14,
                          fontWeight:
                          FontWeight.w600,
                          color: Color(0xFFFE3A31),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}


// ============================================================================
// KEYBOARD INTENTS
// ============================================================================

class _BoldIntent extends Intent {
  const _BoldIntent();
}

class _ItalicIntent extends Intent {
  const _ItalicIntent();
}

class _UnderlineIntent extends Intent {
  const _UnderlineIntent();
}
