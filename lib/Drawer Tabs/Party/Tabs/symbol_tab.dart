import 'package:flutter/material.dart';

import '../../../Reusable Functions/reusable_functions.dart';

class SymbolTab extends StatefulWidget {
  final Map<String, dynamic> symbolData;

  const SymbolTab({super.key, required this.symbolData});

  @override
  State<SymbolTab> createState() => _SymbolTabState();
}

class _SymbolTabState extends State<SymbolTab> {
  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size.width;
    String label = "";

    if (widget.symbolData["label"] != null) {
      final List<dynamic> ops = widget.symbolData["label"];

      label = ops
          .map((e) => e["insert"]?.toString() ?? "")
          .join();
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              overflow: TextOverflow.ellipsis,
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: ColorScheme.of(context).onSurface,
              letterSpacing: 0.25,
            ),
          ),
          GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: size>400?2:1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.7,
              ),
              itemCount: widget.symbolData["urls"].length,
              itemBuilder: (context, index){
                final symbol = widget.symbolData["urls"][index];
                return  CircleAvatar(
                  radius: 166,
                  backgroundImage: (symbol != null && symbol.isNotEmpty)
                      ? NetworkImage(
                    symbol.startsWith("/api/")
                        ? "$api$symbol"
                        : symbol,
                  )
                      : null,
                  child: (symbol == null || symbol.isEmpty)
                      ? const Icon(
                    Icons.image,
                    size: 50,
                  )
                      : null,
                );
              }),
          SizedBox(width: MediaQuery.of(context).size.width * 0.06),
          InkWell(
            onTap: () async {
              if (widget.symbolData["downloadable"] == true ||
                  widget.symbolData["downloadable"] == "YES") {
                for (final symbol in widget.symbolData["symbols"]) {
                  await downloadImage("$api${symbol["url"]}");
                }
              }
            },
            child: Container(
              constraints: const BoxConstraints(minHeight: 37, minWidth: 127),
              decoration: BoxDecoration(
                color: (widget.symbolData["downloadable"] == true ||
                    widget.symbolData["downloadable"] == "YES")
                    ? null
                    : const Color(0xFF666666),
                gradient: (widget.symbolData["downloadable"] == true ||
                    widget.symbolData["downloadable"] == "YES")
                    ? GradientColors.primaryGradient
                    : null,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
              child: const Center(
                child: Text(
                  "Download Logo",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: 0.37,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
