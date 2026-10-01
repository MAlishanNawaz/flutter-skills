# Forms & validation

## Shape

- **Validation rules are pure functions** in the domain (`String? Function(String)`), composed
  and unit-tested. The widget just wires them up.
- **Form state** (values, submit status) lives in the screen's state holder, or a `Form` +
  `GlobalKey<FormState>` for simple forms. Text controllers live in the widget's `State`, and
  are disposed.
- **Submit** sends an intent to the state holder, which calls the repository and returns a
  `Result`. Server-side field errors map back onto fields.

## Validators

```dart
typedef Validator = String? Function(String value);

Validator required(String message) => (v) => v.trim().isEmpty ? message : null;
Validator maxLength(int n, String message) => (v) => v.length > n ? message : null;
Validator matches(RegExp re, String message) => (v) => v.isEmpty || re.hasMatch(v) ? null : message;

Validator all(List<Validator> validators) => (v) {
      for (final validate in validators) {
        final error = validate(v);
        if (error != null) return error;
      }
      return null;
    };
```

Messages are passed **in** (from the project's strings), so the domain stays free of localization.

## When to show errors

Showing errors on every keystroke from the first character is hostile. The usual sequence:

1. Don't show anything while the user types in a field they haven't left yet.
2. Validate a field **when it loses focus** (or `AutovalidateMode.onUserInteraction` after
   first blur).
3. On **submit**, validate everything, show all errors, and **move focus to the first invalid
   field** (and scroll it into view).
4. Once a field has shown an error, re-validate it live so the error clears as soon as the input
   is fixed.

```dart
TextFormField(
  controller: _email,
  focusNode: _emailFocus,
  decoration: InputDecoration(labelText: strings.emailLabel),   // a visible label, not just a hint
  keyboardType: TextInputType.emailAddress,
  textInputAction: TextInputAction.next,
  autofillHints: const [AutofillHints.email],
  autovalidateMode: _submitted ? AutovalidateMode.always : AutovalidateMode.onUserInteraction,
  validator: (v) => emailValidator(v ?? ''),
  onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
)
```

## Keyboard & focus

- Set `keyboardType`, `textInputAction` (`next` / `done`), `textCapitalization`, and
  `autofillHints` on every field. Wrap login/signup in `AutofillGroup`.
- `onFieldSubmitted` moves to the next field; the last field submits.
- Make the form scrollable so the keyboard never hides the active field. Keep the CTA visible
  (pinned above the keyboard or at the end of the scroll).
- Tap outside to dismiss: `GestureDetector(onTap: () => FocusScope.of(context).unfocus())` at
  the screen root.
- Use `inputFormatters` for constrained input (digits only, max length, card or phone masks),
  as well as validation, not instead of it.

## Submitting safely

```dart
FilledButton(
  onPressed: state is Submitting ? null : () => context.read<SignupCubit>().submit(values),
  child: state is Submitting ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(strings.submit),
)
```

- **Disable while in flight**, and also drop repeat taps in the state holder (`droppable()` or
  an `if (state is Submitting) return;` guard). An overlay that doesn't block pointer events is
  not a guard.
- Keep entered values on failure. Show the error next to the field it's about, or in a banner
  for general errors.
- Map server validation errors (`AppError.validation({field: message})`) back onto fields.
- Warn before leaving a form with unsaved changes (`PopScope` with `canPop: !dirty`).
- Trim and normalise input (`email.trim().toLowerCase()`) in one place before sending it.

## Accessibility

- Every field has a **visible label**. Placeholders disappear once you type.
- Error text goes in `errorText`/`validator`, which screen readers announce. Pair it with an icon,
  not colour alone.
- Group related choices (radio sets) with a labelled `Semantics` container.

## Tests

- Unit-test validators and composition (pure, quick).
- Widget-test the flow: submit empty → errors shown and first field focused → fix → error
  clears → submit fires once, even on a double tap.

## Checklist

- [ ] Validators are pure, composed and unit-tested; messages come from the project's strings.
- [ ] Errors appear on blur or submit, not the first keystroke; focus jumps to the first error.
- [ ] Keyboard types, actions, autofill hints and next-field focus set.
- [ ] Scrolls with the keyboard open; CTA reachable.
- [ ] Double-submit impossible; values kept on failure; server errors mapped to fields.
