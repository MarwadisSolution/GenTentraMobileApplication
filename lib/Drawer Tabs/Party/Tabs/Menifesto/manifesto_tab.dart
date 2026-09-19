import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'manifesto_bloc.dart';
import 'manifesto_event.dart';
import 'manifesto_model.dart';
import 'manifesto_state.dart';

class ManifestoTab extends StatefulWidget {
  final int partyId;
  final ScrollController scrollController;

  const ManifestoTab({
    super.key,
    required this.partyId,
    required this.scrollController,
  });

  @override
  State<ManifestoTab> createState() => _ManifestoTabState();
}

class _ManifestoTabState extends State<ManifestoTab> {

  @override
  void initState() {
    super.initState();

    // Use the controller provided by PartyFetchedData.
    widget.scrollController.addListener(_onScroll);

    // Initial GET
    context.read<ManifestoBloc>().add(
      GetManifestosEvent(
        partyId: widget.partyId,
      ),
    );
  }

  // ==========================================================
  // PAGINATION
  // ==========================================================

  void _onScroll() {
    if (!widget.scrollController.hasClients) {
      return;
    }

    if (widget.scrollController.position.extentAfter < 500) {
      context.read<ManifestoBloc>().add(
        const LoadMoreManifestosEvent(),
      );
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ManifestoBloc, ManifestoState>(
      // ========================================================
      // LISTENER
      // ========================================================

      listener: (context, state) {

        // ------------------------------------------------------
        // UPLOAD SUCCESS
        // ------------------------------------------------------

        if (state.postStatus ==
            ManifestoActionStatus.success) {

          ScaffoldMessenger.of(context)
              .hideCurrentSnackBar();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Manifesto uploaded successfully",
              ),
            ),
          );
        }

        // ------------------------------------------------------
        // UPLOAD FAILED
        // ------------------------------------------------------

        if (state.postStatus ==
            ManifestoActionStatus.error) {

          ScaffoldMessenger.of(context)
              .hideCurrentSnackBar();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message ??
                    "Failed to upload manifesto",
              ),
            ),
          );
        }

        // ------------------------------------------------------
        // UPDATE SUCCESS
        // ------------------------------------------------------

        if (state.updateStatus ==
            ManifestoActionStatus.success) {

          ScaffoldMessenger.of(context)
              .hideCurrentSnackBar();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Manifesto updated successfully",
              ),
            ),
          );
        }

        // ------------------------------------------------------
        // UPDATE FAILED
        // ------------------------------------------------------

        if (state.updateStatus ==
            ManifestoActionStatus.error) {

          ScaffoldMessenger.of(context)
              .hideCurrentSnackBar();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message ??
                    "Failed to update manifesto",
              ),
            ),
          );
        }

        // ------------------------------------------------------
        // GET FAILED
        // ------------------------------------------------------

        if (state.status ==
            ManifestoStatus.error) {

          ScaffoldMessenger.of(context)
              .hideCurrentSnackBar();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message ??
                    "Failed to load manifestos",
              ),
            ),
          );
        }
      },

      // ========================================================
      // BUILDER
      // ========================================================

      builder: (context, state) {

        // ------------------------------------------------------
        // INITIAL LOADING
        // ------------------------------------------------------

        if (state.status ==
            ManifestoStatus.loading &&
            state.manifestos.isEmpty) {

          return const Center(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: CircularProgressIndicator(),
            ),
          );
        }

        // ------------------------------------------------------
        // ERROR + NO DATA
        // ------------------------------------------------------

        if (state.status ==
            ManifestoStatus.error &&
            state.manifestos.isEmpty) {

          return Center(
            child: Text(
              state.message ??
                  "Failed to load manifesto",
            ),
          );
        }

        // ------------------------------------------------------
        // EMPTY
        // ------------------------------------------------------

        if (state.manifestos.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: Text(
                "No manifesto found",
              ),
            ),
          );
        }

        // ------------------------------------------------------
        // MANIFESTO LIST
        // ------------------------------------------------------

        return ListView.builder(
          // IMPORTANT:
          // Do NOT give another ScrollController here.
          // The parent CustomScrollView owns the scrolling.
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,

          padding: const EdgeInsets.all(16),

          itemCount: state.manifestos.length +
              (state.isLoadingMore ? 1 : 0),

          itemBuilder: (context, index) {

            // --------------------------------------------------
            // PAGINATION LOADER
            // --------------------------------------------------

            if (index == state.manifestos.length) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // --------------------------------------------------
            // MANIFESTO
            // --------------------------------------------------

            final ManifestoModel manifesto =
            state.manifestos[index];

            return _manifestoCard(
              context,
              manifesto,
            );
          },
        );
      },
    );
  }

  // ==========================================================
  // MANIFESTO CARD
  // ==========================================================

  Widget _manifestoCard(
      BuildContext context,
      ManifestoModel manifesto,
      ) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [

            // TITLE
            Text(
              manifesto.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            // YEAR
            if (manifesto.year != null) ...[
              const SizedBox(height: 6),
              Text(
                "Year: ${manifesto.year}",
              ),
            ],

            // KIND
            if (manifesto.kind != null) ...[
              const SizedBox(height: 4),
              Text(
                "Kind: ${manifesto.kind}",
              ),
            ],

            // DESCRIPTION
            if (manifesto.description != null &&
                manifesto.description!
                    .trim()
                    .isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                manifesto.description!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // AUTHOR
            if (manifesto.author?.name != null) ...[
              const SizedBox(height: 8),
              Text(
                "By: ${manifesto.author!.name}",
              ),
            ],

            // FILE
            if (manifesto.fileUrl != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.picture_as_pdf,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      manifesto.fileName ??
                          "Manifesto PDF",
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}