# Forms

## When to show errors

| Moment | Behaviour |
|---|---|
| Typing in a field never left | No error |
| Field loses focus | Validate that field |
| Submit | Validate all fields, focus and scroll to the first invalid one |
| Field has already shown an error | Re-validate it live, so the error clears as soon as the input is fixed |

`AutovalidateMode.always` breaks row 1. Use `onUserInteraction` only after the first submit, or switch each field's mode from focus listeners. `AutovalidateMode.onUnfocus` doesn't exist in Flutter 3.24; check the project's SDK constraint before using it.

## Double submit, the usual bug

```dart
Future<void> _submit() async {
  if (_submitting) return;                    // checked and set before the first await
  if (!_formKey.currentState!.validate()) return;
  setState(() => _submitting = true);
  try {
    await api.createAccount(...);
  } catch (e) {
    if (mounted) _showError(e);
  } finally {
    if (mounted) setState(() => _submitting = false);
  }
}
// button: onPressed: _submitting ? null : _submit
```

- Disabling the button alone fails for two taps in the same frame. The flag check in the handler is what stops them.
- An `IgnorePointer` or translucent overlay is not a guard: taps go straight through it.
- Route the keyboard "done" action through the same `_submit`.
- With bloc, the guard lives in the state holder (`if (state is Submitting) return;` or `droppable()`).
- Keep entered values on failure, and map server field errors back onto the fields.

## Field setup

Every field needs a **visible label** (a hint disappears once you type), `keyboardType`, `textInputAction` (`next`/`done`), and `autofillHints`, wrapped in an `AutofillGroup` for auth forms. `onFieldSubmitted` moves focus to the next field.

## Validators

Write them as pure functions in the domain, with messages passed in so the domain stays free of localization:

```dart
typedef Validator = String? Function(String v);
Validator all(List<Validator> vs) => (v) { for (final f in vs) { final e = f(v); if (e != null) return e; } return null; };
```

## Tests

Cover these:
- two taps in the same frame call the API once
- no error while typing the first characters
- submitting empty shows errors and focuses the first field
- fixing a field clears its error
- a failure re-enables the button and keeps the input
