import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/widgets/logoutButton.dart';
import '../../logic/profile_cubit.dart';
import '../../logic/profile_state.dart';



typedef LogoutCallback = void Function();

// Fire-and-forget helper to silence unhandled future lints
extension _IgnoreFuture<T> on Future<T> {
  void ignore() {}
}

class ProfileBottomActions extends StatefulWidget {
  final LogoutCallback? onLogout;
  const ProfileBottomActions({super.key, this.onLogout});

  @override
  State<ProfileBottomActions> createState() => _ProfileBottomActionsState();
}

class _ProfileBottomActionsState extends State<ProfileBottomActions> {
  bool _processing = false;
  @override
  Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final buttonStyle = FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    );
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileArchived) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account archived.')));
        } else if (state is ProfileDeleted) {
          setState(() => _processing = false);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account deleted.')));
        } else if (state is ProfileLoggedOut) {
          setState(() => _processing = false);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logged out.')));
        } else if (state is ProfileError) {
          setState(() => _processing = false);
          final msg = state.message.isNotEmpty ? state.message : 'Account action failed';
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
        } else if (state is ProfileLoading) {
          setState(() => _processing = true);
        }
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    style: buttonStyle,
                    icon: const Icon(Icons.mail_outline),
                    onPressed: _processing ? null : () => context.read<ProfileCubit>().sendFeedback(),
                    label: const Text('Send Feedback'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: widget.onLogout == null
                        ? const LogoutButton()
                        : ElevatedButton.icon(
                            icon: const Icon(Icons.logout, color: Colors.white),
                            label: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.error,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 2,
                            ),
                            onPressed: _processing ? null : () async {
                              widget.onLogout?.call();
                            },
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: theme.colorScheme.outlineVariant, height: 24, thickness: 1),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  foregroundColor: Colors.redAccent,
                  minimumSize: const Size.fromHeight(46),
                ),
                onPressed: _processing ? null : () => _showModifyAccountDialog(context),
                label: _processing
                    ? const SizedBox(height:16,width:16,child:CircularProgressIndicator(strokeWidth:2))
                    : const Text('Archive or Delete Account'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showModifyAccountDialog(BuildContext context) async {
    final cubit = context.read<ProfileCubit>();
    final reasonController = TextEditingController();
    bool hardDelete = false; // false => archive
    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: const Text('Close Your Account'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Choose an option below. Archiving disables access and schedules deletion in ~30 days. Deleting removes your account immediately.\n There is no gurantee your account data will be removed from our past DB Backups!',
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: reasonController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Reason / Feedback (optional)',
                        border: OutlineInputBorder(),
                        hintText: 'Tell us why you are leaving...'
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Permanently Delete Now'),
                      subtitle: const Text('Turn off to archive instead'),
                      value: hardDelete,
                      onChanged: (v) => setState(() => hardDelete = v),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: hardDelete ? Colors.red : Colors.orange),
                  onPressed: _processing ? null : () async {
                    final reason = reasonController.text.trim();
                    Navigator.of(ctx).pop();
                    await cubit.modifyAccount(delete: hardDelete, reason: reason);
                  },
                  child: Text(hardDelete ? 'Delete Now' : 'Archive'),
                )
              ],
            );
          },
        );
      },
    );
  }
}
