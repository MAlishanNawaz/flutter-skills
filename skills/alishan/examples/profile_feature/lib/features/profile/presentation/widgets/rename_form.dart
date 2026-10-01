import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design/tokens.dart';
import '../../domain/profile_rules.dart';
import '../profile_cubit.dart';
import '../profile_state.dart';

abstract final class RenameStrings {
  static const firstName = 'First name';
  static const lastName = 'Last name';
  static const required = 'Required';
  static const tooLong = 'Keep it under 40 characters';
  static const save = 'Save';
}

/// Reference for two form gotchas:
/// - Double submit: the cubit drops a second `rename` while one is in flight (see `ProfileCubit.rename`),
///   so two taps in the same frame still make one request. Disabling the button alone would not.
/// - Error timing: no errors while typing until the first submit, then live re-validation.
class RenameForm extends StatefulWidget {
  const RenameForm({super.key, required this.initialFirst, required this.initialLast});
  final String initialFirst;
  final String initialLast;

  @override
  State<RenameForm> createState() => _RenameFormState();
}

class _RenameFormState extends State<RenameForm> {
  final _formKey = GlobalKey<FormState>();
  late final _first = TextEditingController(text: widget.initialFirst);
  late final _last = TextEditingController(text: widget.initialLast);
  var _autovalidate = AutovalidateMode.disabled;

  static final _name = all([notBlank(RenameStrings.required), maxLength(40, RenameStrings.tooLong)]);

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      return;
    }
    context.read<ProfileCubit>().rename(firstName: _first.text, lastName: _last.text);
  }

  @override
  Widget build(BuildContext context) {
    final saving = context.select(
      (ProfileCubit c) => switch (c.state) {
        ProfileLoaded(:final saving) => saving,
        _ => false,
      },
    );
    return Form(
      key: _formKey,
      autovalidateMode: _autovalidate,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _first,
            decoration: const InputDecoration(labelText: RenameStrings.firstName),
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.givenName],
            validator: (v) => _name(v ?? ''),
          ),
          const SizedBox(height: Spacing.md),
          TextFormField(
            controller: _last,
            decoration: const InputDecoration(labelText: RenameStrings.lastName),
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.familyName],
            validator: (v) => _name(v ?? ''),
            onFieldSubmitted: (_) => _submit(), // same guarded path as the button
          ),
          const SizedBox(height: Spacing.lg),
          FilledButton(onPressed: saving ? null : _submit, child: const Text(RenameStrings.save)),
        ],
      ),
    );
  }
}
