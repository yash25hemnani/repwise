import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:repwise/core/theme/app_colors.dart';
import 'package:repwise/core/utils/workout_format.dart';
import 'package:repwise/core/widgets/plate_button.dart';
import 'package:repwise/features/plans/models/plan_exercise_model.dart';
import 'package:repwise/features/plans/models/plan_set_model.dart';

const _maxSets = 12;

// Edits an exercise's target sets: reps × kg rows, or min:sec rows for
// timed exercises. However the sheet closes, show() resolves with the
// edited sets, or null when nothing changed
class SetsSheet extends StatefulWidget {
  const SetsSheet({super.key, required this.exercise, required this.onChanged});

  final PlanExerciseModel exercise;
  final ValueChanged<List<PlanSetModel>> onChanged;

  static Future<List<PlanSetModel>?> show(
    BuildContext context,
    PlanExerciseModel exercise,
  ) async {
    List<PlanSetModel>? edited;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => SetsSheet(
        exercise: exercise,
        onChanged: (sets) => edited = sets,
      ),
    );

    return edited;
  }

  @override
  State<SetsSheet> createState() => _SetsSheetState();
}

// Two fields per set: reps and kg, or minutes and seconds
class _SetRow {
  _SetRow(String a, String b)
    : a = TextEditingController(text: a),
      b = TextEditingController(text: b);

  final TextEditingController a;
  final TextEditingController b;

  void dispose() {
    a.dispose();
    b.dispose();
  }
}

class _SetsSheetState extends State<SetsSheet> {
  late final bool _timed = widget.exercise.logType == ExerciseLogType.timed;
  late final List<_SetRow> _rows = [
    for (final s in widget.exercise.sets) _rowFor(s),
    if (widget.exercise.sets.isEmpty) _SetRow('', ''),
  ];

  _SetRow _rowFor(PlanSetModel s) {
    if (_timed) {
      final t = s.durationSec;
      return _SetRow(
        t == null ? '' : '${t ~/ 60}',
        t == null ? '' : (t % 60).toString().padLeft(2, '0'),
      );
    }
    return _SetRow(
      s.reps?.toString() ?? '',
      s.weightKg == null ? '' : formatKg(s.weightKg!),
    );
  }

  PlanSetModel _setFor(_SetRow row) {
    if (_timed) {
      final m = int.tryParse(row.a.text);
      final s = int.tryParse(row.b.text);
      if (m == null && s == null) return const PlanSetModel();
      return PlanSetModel(durationSec: (m ?? 0) * 60 + (s ?? 0));
    }
    return PlanSetModel(
      reps: int.tryParse(row.a.text),
      weightKg: double.tryParse(row.b.text.replaceAll(',', '.')),
    );
  }

  void _emit() => widget.onChanged([for (final r in _rows) _setFor(r)]);

  // The new set copies the last one, the usual case for straight sets
  void _add() {
    final last = _rows.last;
    setState(() => _rows.add(_SetRow(last.a.text, last.b.text)));
    _emit();
  }

  // Takes the last set off. Its fields leave the tree first, then dispose
  void _removeLast() {
    final row = _rows.removeLast();
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) => row.dispose());
    _emit();
  }

  @override
  void dispose() {
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.exercise.name,
            style: textTheme.titleLarge?.copyWith(color: c.text),
          ),
          const SizedBox(height: 12),
          _SetCount(
            count: _rows.length,
            onRemove: _rows.length > 1 ? _removeLast : null,
            onAdd: _rows.length < _maxSets ? _add : null,
          ),
          const SizedBox(height: 20),
          _ColumnHeads(
            first: _timed ? 'Min' : 'Reps',
            second: _timed ? 'Sec' : 'Weight (kg)',
          ),
          const SizedBox(height: 6),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (var i = 0; i < _rows.length; i++)
                    _SetRowFields(
                      key: ObjectKey(_rows[i]),
                      number: i + 1,
                      row: _rows[i],
                      timed: _timed,
                      onChanged: _emit,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          PlateButton(
            label: 'Done',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class _SetRowFields extends StatelessWidget {
  const _SetRowFields({
    super.key,
    required this.number,
    required this.row,
    required this.timed,
    required this.onChanged,
  });

  final int number;
  final _SetRow row;
  final bool timed;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final digits = FilteringTextInputFormatter.digitsOnly;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: _numberWidth,
            child: Text(
              '$number',
              style: textTheme.titleMedium?.copyWith(color: c.textSecondary),
            ),
          ),
          Expanded(
            child: _NumberField(
              controller: row.a,
              label: 'Set $number ${timed ? 'minutes' : 'reps'}',
              formatters: [digits, LengthLimitingTextInputFormatter(3)],
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: _gapWidth,
            child: Text(
              timed ? ':' : '×',
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(color: c.textSecondary),
            ),
          ),
          Expanded(
            child: _NumberField(
              controller: row.b,
              label: 'Set $number ${timed ? 'seconds' : 'weight in kg'}',
              decimal: !timed,
              formatters: timed
                  ? [digits, LengthLimitingTextInputFormatter(2)]
                  : [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d{0,3}([.,]\d{0,2})?'),
                      ),
                    ],
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

// Shared by the column heads and the rows so they line up
const _numberWidth = 32.0;
const _gapWidth = 28.0;

// Soft fields with no outline at rest, so only the one being typed in
// gets the ink border
class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    required this.formatters,
    required this.onChanged,
    this.decimal = false,
  });

  final TextEditingController controller;
  final String label;
  final List<TextInputFormatter> formatters;
  final VoidCallback onChanged;
  final bool decimal;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final textTheme = Theme.of(context).textTheme;
    const rest = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide.none,
    );

    return Semantics(
      label: label,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: decimal),
        inputFormatters: formatters,
        textInputAction: TextInputAction.next,
        textAlign: TextAlign.center,
        onChanged: (_) => onChanged(),
        style: textTheme.titleLarge?.copyWith(color: c.text),
        decoration: InputDecoration(
          isDense: true,
          hintText: '–',
          hintStyle: textTheme.titleLarge?.copyWith(color: c.textSecondary),
          border: rest,
          enabledBorder: rest,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

// Named once over the fields instead of a unit in every box
class _ColumnHeads extends StatelessWidget {
  const _ColumnHeads({required this.first, required this.second});

  final String first;
  final String second;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final style = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: c.textSecondary);

    return ExcludeSemantics(
      child: Row(
        children: [
          const SizedBox(width: _numberWidth),
          Expanded(
            child: Text(first, textAlign: TextAlign.center, style: style),
          ),
          const SizedBox(width: _gapWidth),
          Expanded(
            child: Text(second, textAlign: TextAlign.center, style: style),
          ),
        ],
      ),
    );
  }
}

// How many sets, with − and + either side. Removing takes the last set
class _SetCount extends StatelessWidget {
  const _SetCount({
    required this.count,
    required this.onRemove,
    required this.onAdd,
  });

  final int count;
  final VoidCallback? onRemove;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            'Sets',
            style: textTheme.titleMedium?.copyWith(color: c.text),
          ),
        ),
        _StepButton(
          icon: Icons.remove_rounded,
          tooltip: 'Remove a set',
          onPressed: onRemove,
        ),
        SizedBox(
          width: 48,
          child: Text(
            '$count',
            textAlign: TextAlign.center,
            semanticsLabel: '$count sets',
            style: textTheme.headlineSmall?.copyWith(color: c.text),
          ),
        ),
        _StepButton(
          icon: Icons.add_rounded,
          tooltip: 'Add a set',
          onPressed: onAdd,
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        fixedSize: const Size.square(44),
        backgroundColor: c.surface,
        foregroundColor: c.text,
        disabledBackgroundColor: c.surface,
        disabledForegroundColor: c.textSecondary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }
}
