import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repwise/core/theme/app_colors.dart';
import 'package:repwise/features/auth/providers/auth_provider.dart';
import 'package:repwise/features/plans/models/plan_model.dart';
import 'package:repwise/features/plans/providers/plan_provider.dart';
import 'package:repwise/features/plans/sheets/plan_name_sheet.dart';
import 'package:repwise/features/plans/widgets/plan_tile.dart';

// Plan writes and menu actions, shared by the Plan tab and the plan editor
class PlanActionsService {
  const PlanActionsService._();

  // Writes queue offline and only finish once synced, so feedback shows
  // straight away and only a failure comes back later
  static void write(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function(String uid) write, {
    String? done,
    SnackBarAction? undo,
  }) {
    final uid = ref.read(currentUidProvider).value;
    if (uid == null) return;

    final messenger = ScaffoldMessenger.of(context);
    if (done != null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(done), action: undo));
    }

    write(uid).catchError((Object _) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Couldn\'t save that change. Try again.')),
      );
    });
  }

  // onDeleted runs once the user confirms, before the write, so the
  // editor can close itself
  static Future<void> run(
    BuildContext context,
    WidgetRef ref,
    PlanModel plan,
    PlanAction action, {
    VoidCallback? onDeleted,
  }) async {
    final repo = ref.read(planRepositoryProvider);

    switch (action) {
      case PlanAction.setActive:
        write(
          context,
          ref,
          (uid) => repo.setActivePlan(uid, plan.id),
          done: '${plan.name} is now your active plan',
        );

      case PlanAction.rename:
        final name = await PlanNameSheet.show(
          context,
          title: 'Rename plan',
          action: 'Save',
          initial: plan.name,
        );
        if (name == null || name == plan.name || !context.mounted) return;
        write(context, ref, (uid) => repo.renamePlan(uid, plan.id, name));

      case PlanAction.duplicate:
        write(
          context,
          ref,
          (uid) => repo.duplicatePlan(uid, plan),
          done: 'Made a copy of ${plan.name}',
        );

      case PlanAction.delete:
        final confirmed = await _confirmDelete(context, plan);
        if (!confirmed || !context.mounted) return;
        write(
          context,
          ref,
          (uid) => repo.deletePlan(uid, plan.id),
          done: '${plan.name} deleted',
        );
        onDeleted?.call();
    }
  }

  static Future<bool> _confirmDelete(
    BuildContext context,
    PlanModel plan,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${plan.name}?'),
        content: const Text(
          'Its days and exercises are deleted too. This can\'t be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: context.colors.redText),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    return confirmed == true;
  }
}
