import 'package:flutter/material.dart';
import 'package:repwise/core/theme/app_colors.dart';
import 'package:repwise/core/widgets/plate_button.dart';

// Asks for a plan name; used for New plan and Rename. Pops the trimmed
// name, or null when dismissed
class PlanNameSheet extends StatefulWidget {
  const PlanNameSheet({
    super.key,
    required this.title,
    required this.action,
    this.initial = '',
  });

  final String title;
  final String action;
  final String initial;

  static Future<String?> show(
    BuildContext context, {
    required String title,
    required String action,
    String initial = '',
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) =>
          PlanNameSheet(title: title, action: action, initial: initial),
    );
  }

  @override
  State<PlanNameSheet> createState() => _PlanNameSheetState();
}

class _PlanNameSheetState extends State<PlanNameSheet> {
  late final _controller = TextEditingController(text: widget.initial);

  bool get _canSave => _controller.text.trim().isNotEmpty;

  void _save() {
    if (!_canSave) return;
    Navigator.pop(context, _controller.text.trim());
  }

  @override
  void dispose() {
    _controller.dispose();
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
            widget.title,
            style: textTheme.titleLarge?.copyWith(color: c.text),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: 40,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _save(),
            decoration: const InputDecoration(hintText: 'e.g. Push Pull Legs'),
          ),
          const SizedBox(height: 8),
          PlateButton(
            label: widget.action,
            onPressed: _canSave ? _save : null,
          ),
        ],
      ),
    );
  }
}
