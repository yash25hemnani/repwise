import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repwise/core/theme/app_colors.dart';
import 'package:repwise/core/utils/workout_format.dart';
import 'package:repwise/core/widgets/plate_button.dart';
import 'package:repwise/features/auth/providers/auth_provider.dart';
import 'package:repwise/features/exercises/screens/exercise_detail_screen.dart';
import 'package:repwise/features/exercises/screens/exercise_picker_screen.dart';
import 'package:repwise/features/plans/models/plan_day_model.dart';
import 'package:repwise/features/plans/models/plan_exercise_model.dart';
import 'package:repwise/features/plans/models/plan_model.dart';
import 'package:repwise/features/plans/providers/plan_provider.dart';
import 'package:repwise/features/plans/services/plan_actions_service.dart';
import 'package:repwise/features/plans/widgets/plan_exercise_card.dart';
import 'package:repwise/features/plans/widgets/plan_sets_card.dart';

enum _DayAction { rest, copy }

// One day of a plan: its title and exercises. Every change saves straight
// away; the title saves on Done, when the field loses focus, or on back
class DayEditorScreen extends ConsumerStatefulWidget {
  const DayEditorScreen({
    super.key,
    required this.planId,
    required this.weekday,
  });

  final String planId;
  final PlanWeekday weekday;

  @override
  ConsumerState<DayEditorScreen> createState() => _DayEditorScreenState();
}

class _DayEditorScreenState extends ConsumerState<DayEditorScreen> {
  final _title = TextEditingController();
  final _titleFocus = FocusNode();

  // Shown until Firestore echoes the write back, so a swiped or dragged
  // card moves in the same frame
  PlanDayModel? _local;
  late PlanDayModel _remote;

  PlanDayModel get _day => _local ?? _remote;

  @override
  void initState() {
    super.initState();
    _remote = _dayOf(ref.read(planProvider(widget.planId)));
    _title.text = _remote.title;
    _titleFocus.addListener(() {
      if (!_titleFocus.hasFocus) _saveTitle();
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _titleFocus.dispose();
    super.dispose();
  }

  PlanDayModel _dayOf(PlanModel? plan) =>
      plan?.day(widget.weekday) ?? PlanDayModel.rest;

  // Keeps the title field in step with changes made elsewhere, unless the
  // user is typing in it
  void _syncTitle(PlanDayModel day) {
    if (!_titleFocus.hasFocus && _title.text != day.title) {
      _title.text = day.title;
    }
  }

  // Undo restores the day as it was before this change. Only the latest
  // SnackBar is visible, so it's always the latest change that's undone
  void _save(PlanDayModel day, {String? done, bool undoable = false}) {
    final before = _day;
    final repo = ref.read(planRepositoryProvider);
    final uid = ref.read(currentUidProvider).value;
    final planId = widget.planId;
    final weekday = widget.weekday;

    setState(() => _local = day);
    _syncTitle(day);

    PlanActionsService.write(
      context,
      ref,
      (uid) => repo.updateDay(uid, planId, weekday, day),
      done: done,
      undo: !undoable || uid == null
          ? null
          : SnackBarAction(
              label: 'Undo',
              onPressed: () {
                if (mounted) {
                  _save(before);
                } else {
                  repo.updateDay(uid, planId, weekday, before).ignore();
                }
              },
            ),
    );
  }

  void _saveTitle() {
    if (!mounted) return;
    final title = _title.text.trim();
    if (title == _day.title) return;
    _save(_day.copyWith(title: title));
  }

  void _remove(PlanExerciseModel exercise) {
    _save(
      _day.copyWith(
        exercises: [
          for (final e in _day.exercises)
            if (e.id != exercise.id) e,
        ],
      ),
      done: '${exercise.name} removed',
      undoable: true,
    );
  }

  void _reorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final list = [..._day.exercises];
    list.insert(newIndex, list.removeAt(oldIndex));
    _save(_day.copyWith(exercises: list));
  }

  // The detail page saves sets itself; the listener picks the change up
  void _openExercise(PlanExerciseModel exercise) {
    FocusScope.of(context).unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseDetailScreen(
          exerciseId: exercise.exerciseId,
          name: exercise.name,
          planSection: PlanSetsCard(
            planId: widget.planId,
            weekday: widget.weekday,
            planExerciseId: exercise.id,
          ),
        ),
      ),
    );
  }

  // Picked exercises go to the end of the day, in the order they were
  // tapped, each with starter sets
  Future<void> _addExercise() async {
    FocusScope.of(context).unfocus();
    final picked = await ExercisePickerScreen.show(
      context,
      existingIds: {for (final e in _day.exercises) e.exerciseId},
    );
    if (picked == null || picked.isEmpty || !mounted) return;

    final stamp = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    _save(
      _day.copyWith(
        exercises: [
          ..._day.exercises,
          for (final (i, e) in picked.indexed)
            PlanExerciseModel.fromExercise(e, id: '$stamp-$i'),
        ],
      ),
      done: picked.length == 1
          ? '${picked.first.name} added'
          : '${countLabel(picked.length, 'exercise')} added',
      undoable: true,
    );
  }

  Future<void> _onAction(_DayAction action) async {
    FocusScope.of(context).unfocus();

    switch (action) {
      case _DayAction.rest:
        _save(
          PlanDayModel.rest,
          done: '${widget.weekday.label} is now a rest day',
          undoable: true,
        );

      case _DayAction.copy:
        final source = await _pickSourceDay();
        if (source == null || !mounted) return;
        final plan = ref.read(planProvider(widget.planId));
        if (plan == null) return;
        _save(
          plan.day(source),
          done: 'Copied ${source.label}',
          undoable: true,
        );
    }
  }

  // Only days with exercises are offered
  Future<PlanWeekday?> _pickSourceDay() async {
    final plan = ref.read(planProvider(widget.planId));
    if (plan == null) return null;

    final sources = [
      for (final d in PlanWeekday.values)
        if (d != widget.weekday && !plan.day(d).isRest) d,
    ];
    if (sources.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('No other day has exercises yet')),
        );
      return null;
    }

    return showDialog<PlanWeekday>(
      context: context,
      builder: (context) {
        final c = context.colors;
        final textTheme = Theme.of(context).textTheme;

        return SimpleDialog(
          title: const Text('Copy from'),
          children: [
            for (final d in sources)
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, d),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.day(d).title.isEmpty
                          ? d.label
                          : '${d.label}: ${plan.day(d).title}',
                      style: textTheme.labelLarge?.copyWith(color: c.text),
                    ),
                    Text(
                      countLabel(plan.day(d).exercises.length, 'exercise'),
                      style: textTheme.bodySmall?.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final plan = ref.watch(planProvider(widget.planId));

    ref.listen(planProvider(widget.planId), (_, next) {
      if (next == null) return;
      final day = _dayOf(next);
      setState(() {
        _remote = day;
        _local = null;
      });
      _syncTitle(day);
    });

    final day = _day;

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _saveTitle();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: c.background,
          surfaceTintColor: AppColors.transparent,
          // Context only: the day's title below is the headline
          title: Text(
            widget.weekday.label,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: c.text),
          ),
          actions: [
            if (plan != null)
              PopupMenuButton<_DayAction>(
                tooltip: 'Day options',
                icon: Icon(Icons.more_vert_rounded, color: c.text),
                color: c.card,
                onSelected: _onAction,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _DayAction.rest,
                    enabled: !day.isRest || day.title.isNotEmpty,
                    child: const Text('Make rest day'),
                  ),
                  const PopupMenuItem(
                    value: _DayAction.copy,
                    child: Text('Copy from another day'),
                  ),
                ],
              ),
          ],
        ),
        body: plan == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'This plan isn\'t available. It may have been deleted.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: c.textSecondary,
                    ),
                  ),
                ),
              )
            : ReorderableListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                buildDefaultDragHandles: false,
                onReorder: _reorder,
                // Transparent so the gap under the card doesn't drag along
                // as a band
                proxyDecorator: (child, _, animation) => ScaleTransition(
                  scale: Tween(begin: 1.0, end: 1.03).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  ),
                  child: Material(
                    type: MaterialType.transparency,
                    child: child,
                  ),
                ),
                header: _Header(
                  controller: _title,
                  focusNode: _titleFocus,
                  count: day.exercises.length,
                  onSubmitted: _saveTitle,
                ),
                footer: day.isRest ? const _RestHint() : null,
                children: [
                  for (var i = 0; i < day.exercises.length; i++)
                    Padding(
                      key: ValueKey(day.exercises[i].id),
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Stack(
                        children: [
                          // Sits under the card so its rounded corners slide
                          // over red, not over a straight clipped edge
                          const Positioned.fill(child: _RemoveBackground()),
                          Dismissible(
                            key: ValueKey('dismiss-${day.exercises[i].id}'),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) => _remove(day.exercises[i]),
                            child: PlanExerciseCard(
                              exercise: day.exercises[i],
                              index: i,
                              onTap: () => _openExercise(day.exercises[i]),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
        // Pinned so the main action stays in reach however long the day is
        bottomNavigationBar: plan == null
            ? null
            : SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: PlateButton(
                      label: 'Add exercise',
                      icon: Icons.add_rounded,
                      onPressed: _addExercise,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.controller,
    required this.focusNode,
    required this.count,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final int count;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final textTheme = Theme.of(context).textTheme;

    final headline = textTheme.headlineLarge;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The page's headline, edited in place: no box, an underline only
          // while typing
          TextField(
            controller: controller,
            focusNode: focusNode,
            maxLength: 30,
            minLines: 1,
            maxLines: 2,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onSubmitted(),
            onTapOutside: (_) => focusNode.unfocus(),
            style: headline?.copyWith(color: c.text),
            decoration: InputDecoration(
              filled: false,
              isDense: true,
              hintText: 'Name this day',
              hintStyle: headline?.copyWith(color: c.textSecondary),
              counterText: '',
              contentPadding: const EdgeInsets.only(top: 4, bottom: 8),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: c.ink, width: 2),
              ),
              suffixIcon: IconButton(
                tooltip: 'Rename day',
                onPressed: focusNode.requestFocus,
                icon: Icon(Icons.edit_outlined, color: c.textSecondary),
              ),
            ),
          ),
          if (count > 0) ...[
            const SizedBox(height: 4),
            Text(
              countLabel(count, 'exercise'),
              style: textTheme.bodyMedium?.copyWith(color: c.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class _RestHint extends StatelessWidget {
  const _RestHint();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Rest day. Add an exercise to make it a training day.',
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: context.colors.textSecondary),
    );
  }
}

class _RemoveBackground extends StatelessWidget {
  const _RemoveBackground();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final light = Theme.of(context).brightness == Brightness.light;

    // Plate red fill with black on it, the destructive colour. Inset 1px
    // so no red bleeds past the card's edge at rest
    return Container(
      margin: const EdgeInsets.all(1),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: AppColors.red,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: light ? Border.all(color: c.ink, width: 2) : null,
      ),
      child: const Icon(
        Icons.delete_outline_rounded,
        color: AppColors.onAccent,
        semanticLabel: 'Remove',
      ),
    );
  }
}
