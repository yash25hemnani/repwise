import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repwise/core/theme/app_colors.dart';
import 'package:repwise/core/utils/workout_format.dart';
import 'package:repwise/core/widgets/plate_button.dart';
import 'package:repwise/features/exercises/models/exercise_model.dart';
import 'package:repwise/features/exercises/providers/exercise_provider.dart';
import 'package:repwise/features/exercises/screens/exercise_detail_screen.dart';
import 'package:repwise/features/exercises/widgets/exercise_pick_tile.dart';
import 'package:repwise/features/exercises/widgets/muscle_group_chips.dart';

const _pageSize = 30;

// Distance from the end of the list at which the next page loads
const _loadMoreExtent = 600.0;

// Full-screen library browser. Search, filter by muscle group, pick any
// number of exercises; they come back in the order they were tapped
class ExercisePickerScreen extends ConsumerStatefulWidget {
  const ExercisePickerScreen({super.key, this.existingIds = const {}});

  // Library ids already in the day, marked so they aren't added twice by
  // accident. They can still be picked
  final Set<String> existingIds;

  // Null when the picker is closed without adding
  static Future<List<ExerciseModel>?> show(
    BuildContext context, {
    Set<String> existingIds = const {},
  }) {
    return Navigator.push<List<ExerciseModel>>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ExercisePickerScreen(existingIds: existingIds),
      ),
    );
  }

  @override
  ConsumerState<ExercisePickerScreen> createState() =>
      _ExercisePickerScreenState();
}

class _ExercisePickerScreenState extends ConsumerState<ExercisePickerScreen> {
  final _searchText = TextEditingController();
  final _scroll = ScrollController();
  Timer? _debounce;

  String _search = '';
  String? _groupId;
  int _limit = _pageSize;

  // Insertion order is the order they're added to the day
  final _picked = <String, ExerciseModel>{};

  // Last page for the current filters, kept on screen while a bigger
  // limit loads so the list doesn't blank out
  ExercisePage? _shown;
  String? _shownKey;

  ExerciseQuery get _query =>
      (search: _search, muscleGroupId: _groupId, limit: _limit);

  String get _filterKey => '$_search|$_groupId';

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_maybeLoadMore);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchText.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onSearchChanged(String text) {
    setState(() {}); // shows or hides the clear button
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted || text.trim() == _search) return;
      setState(() {
        _search = text.trim();
        _limit = _pageSize;
      });
      _toTop();
    });
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchText.clear();
    setState(() {
      _search = '';
      _limit = _pageSize;
    });
    _toTop();
  }

  void _selectGroup(String? id) {
    if (id == _groupId) return;
    setState(() {
      _groupId = id;
      _limit = _pageSize;
    });
    _toTop();
  }

  void _toTop() {
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  // Raises the limit near the end of the list. Also runs after each frame,
  // so a short page that can't scroll still pulls in the next one
  void _maybeLoadMore() {
    final async = ref.read(exerciseSearchProvider(_query));
    final page = async.value;
    if (page == null || async.isLoading || !page.hasMore) return;
    if (!_scroll.hasClients || _scroll.position.extentAfter > _loadMoreExtent) {
      return;
    }
    setState(() => _limit += _pageSize);
  }

  void _toggle(ExerciseModel exercise) {
    setState(() {
      if (_picked.remove(exercise.id) == null) {
        _picked[exercise.id] = exercise;
      }
    });
  }

  // Picking from the detail page goes back to the list, where the circle
  // shows its place in the order
  void _open(ExerciseModel exercise) {
    FocusScope.of(context).unfocus();
    final picked = _picked.containsKey(exercise.id);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (detail) => ExerciseDetailScreen(
          exerciseId: exercise.id,
          name: exercise.name,
          bottomBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: PlateButton(
                label: picked ? 'Remove from picks' : 'Pick exercise',
                flat: picked,
                onPressed: () {
                  _toggle(exercise);
                  Navigator.pop(detail);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final groups = ref.watch(muscleGroupsProvider).value ?? const [];
    final async = ref.watch(exerciseSearchProvider(_query));

    final latest = async.value;
    if (latest != null) {
      _shown = latest;
      _shownKey = _filterKey;
    }
    final page = latest ?? (_shownKey == _filterKey ? _shown : null);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _maybeLoadMore();
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: c.background,
        surfaceTintColor: AppColors.transparent,
        title: const Text('Add exercises'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: _SearchField(
              controller: _searchText,
              onChanged: _onSearchChanged,
              onClear: _clearSearch,
            ),
          ),
          MuscleGroupChips(
            groups: groups,
            selectedId: _groupId,
            onSelected: _selectGroup,
          ),
          const SizedBox(height: 12),
          Expanded(child: _results(page, async)),
        ],
      ),
      bottomNavigationBar: _picked.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: PlateButton(
                  label: 'Add ${countLabel(_picked.length, 'exercise')}',
                  onPressed: () =>
                      Navigator.pop(context, _picked.values.toList()),
                ),
              ),
            ),
    );
  }

  Widget _results(ExercisePage? page, AsyncValue<ExercisePage> async) {
    void retry() => ref.invalidate(exerciseSearchProvider(_query));

    if (page == null) {
      if (async.hasError) {
        return _Message(
          title: 'Couldn\'t load exercises',
          body: 'Check your connection, then try again.',
          onRetry: retry,
        );
      }
      return const Center(child: CircularProgressIndicator());
    }

    if (page.items.isEmpty && !page.hasMore) {
      return _search.isEmpty
          ? const _Message(
              title: 'No exercises here yet',
              body: 'Pick another muscle group.',
            )
          : _Message(
              title: 'No exercises match "$_search"',
              body: _groupId == null
                  ? 'Try a shorter word, like "curl" or "squat".'
                  : 'Try All, or a shorter word.',
            );
    }

    final groups = ref.watch(muscleGroupsProvider).value ?? const [];
    final groupNames = {for (final g in groups) g.id: g.name};
    final equipment = ref.watch(equipmentNamesProvider).value ?? const {};
    final order = {for (final (i, id) in _picked.keys.indexed) id: i + 1};

    return ListView.builder(
      controller: _scroll,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: page.items.length + (page.hasMore ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == page.items.length) {
          return _LoadMoreFooter(failed: async.hasError, onRetry: retry);
        }

        final e = page.items[i];
        final subtitle = [
          groupNames[e.muscleGroupId],
          equipment[e.equipmentId],
        ].whereType<String>().join(' · ');

        const corner = Radius.circular(16);
        final first = i == 0;
        final last = i == page.items.length - 1 && !page.hasMore;

        // 2 px of background between rows
        return Padding(
          key: ValueKey(e.id),
          padding: EdgeInsets.only(bottom: last ? 0 : 2),
          child: ExercisePickTile(
            exercise: e,
            subtitle: subtitle,
            pickOrder: order[e.id],
            inDay: widget.existingIds.contains(e.id),
            onTap: () => _toggle(e),
            onOpen: () => _open(e),
            borderRadius: BorderRadius.vertical(
              top: first ? corner : Radius.zero,
              bottom: last ? corner : Radius.zero,
            ),
          ),
        );
      },
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: c.text),
      decoration: InputDecoration(
        hintText: 'Search exercises',
        prefixIcon: Icon(Icons.search_rounded, color: c.textSecondary),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                onPressed: onClear,
                tooltip: 'Clear search',
                icon: Icon(Icons.close_rounded, color: c.textSecondary),
              ),
      ),
    );
  }
}

class _LoadMoreFooter extends StatelessWidget {
  const _LoadMoreFooter({required this.failed, required this.onRetry});

  final bool failed;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: failed
            ? TextButton(
                onPressed: onRetry,
                child: const Text('Couldn\'t load more. Try again'),
              )
            : const SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.title, required this.body, this.onRetry});

  final String title;
  final String body;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(color: c.text),
            ),
            const SizedBox(height: 6),
            Text(
              body,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: c.textSecondary),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              TextButton(onPressed: onRetry, child: const Text('Try again')),
            ],
          ],
        ),
      ),
    );
  }
}
