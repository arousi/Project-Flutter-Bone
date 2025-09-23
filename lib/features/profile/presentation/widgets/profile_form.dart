import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/profile_cubit.dart';

class ProfileForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController; // deprecated hidden for now
  final FocusNode usernameFocusNode;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final bool isEditable; // New parameter to control editability
  final bool disabled; // Optional parameter to disable fields
  final bool usernameOk; // indicates when username field validated to server UUID
  final bool emailVerified;
  final bool profileEmailVerified;
  final TextEditingController? phoneController;
  final TextEditingController? serverUuidController;
  final VoidCallback? onUpdatePressed;
  final VoidCallback? onRegisterPressed; // when provided, show Register button next to Save
  final VoidCallback? onUsernameSuffixTap;
  final VoidCallback? onVerifyEmailPressed;
  final bool showConfirmPassword;
  final TextEditingController? confirmPasswordController; // deprecated hidden for now

  const ProfileForm({
    super.key,
    required this.formKey,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.usernameFocusNode,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    this.isEditable = true, // Default to editable
    this.disabled = false, // Default to enabled
    this.usernameOk = false,
  this.emailVerified = false,
  this.profileEmailVerified = false,
  this.phoneController,
  this.serverUuidController,
  this.onVerifyEmailPressed,
  this.showConfirmPassword = false,
  this.confirmPasswordController,
    this.onUpdatePressed,
  this.onRegisterPressed,
    this.onUsernameSuffixTap,
  });

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final border = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
    return Card(
      elevation: 2,
      color: theme.cardColor,
      shape: border,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: Form(
          key: widget.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text('Personal Information', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: widget.usernameController,
                      focusNode: widget.usernameFocusNode,
                      enabled: widget.isEditable && !widget.disabled,
                      decoration: const InputDecoration(labelText: 'Username', prefixIcon: Icon(Icons.person)),
                      validator: (value) => (value == null || value.isEmpty) ? 'Enter username' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: widget.serverUuidController,
                      enabled: widget.isEditable && !widget.disabled,
                      decoration: InputDecoration(
                        labelText: 'Server UUID',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.copy),
                          tooltip: 'Copy',
                          onPressed: () {
                            final v = widget.serverUuidController?.text ?? '';
                            if (v.isNotEmpty) {
                              Clipboard.setData(ClipboardData(text: v));
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Server UUID copied')));
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: widget.emailController,
                focusNode: widget.emailFocusNode,
                enabled: widget.isEditable && !widget.disabled,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  suffixIcon: Icon(widget.emailVerified ? Icons.check_circle : Icons.cancel, color: widget.emailVerified ? Colors.green : Colors.red),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              if (!widget.emailVerified && widget.onVerifyEmailPressed != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: widget.onVerifyEmailPressed,
                    icon: const Icon(Icons.verified),
                    label: const Text('Verify Email'),
                  ),
                ),
              ],
              if (widget.phoneController != null) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: widget.phoneController,
                  enabled: widget.isEditable && !widget.disabled,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: const Icon(Icons.phone),
                    suffixIcon: Icon(widget.profileEmailVerified ? Icons.check_circle : Icons.cancel, color: widget.profileEmailVerified ? Colors.green : Colors.red),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.save),
                      onPressed: (!widget.disabled && widget.isEditable)
                          ? (widget.onUpdatePressed ?? () {
                              if (widget.formKey.currentState!.validate()) {
                                context.read<ProfileCubit>().updateProfile(
                                      widget.usernameController.text,
                                      widget.emailController.text,
                                      widget.passwordController.text,
                                    );
                              }
                            })
                          : null,
                      label: const Text('Save Changes'),
                    ),
                  ),
                  if (widget.onRegisterPressed != null) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        icon: const Icon(Icons.person_add),
                        onPressed: widget.onRegisterPressed,
                        label: const Text('Register & Keep Data'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
