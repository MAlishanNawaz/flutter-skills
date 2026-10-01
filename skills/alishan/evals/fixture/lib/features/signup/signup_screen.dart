import 'package:flutter/material.dart';

abstract interface class SignupApi {
  Future<void> createAccount({required String email, required String password});
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key, required this.api});
  final SignupApi api;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await widget.api.createAccount(email: _email.text, password: _password.text);
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.always,
          child: Column(
            children: [
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(hintText: 'Email'),
                validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
              ),
              TextFormField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(hintText: 'Password'),
                validator: (v) => (v == null || v.length < 8) ? 'At least 8 characters' : null,
              ),
              Stack(
                children: [
                  ElevatedButton(onPressed: _submit, child: const Text('Create account')),
                  if (_loading) const Positioned.fill(child: IgnorePointer(child: ColoredBox(color: Color(0x22000000)))),
                ],
              ),
            ],
          ),
        ),
      );
}
