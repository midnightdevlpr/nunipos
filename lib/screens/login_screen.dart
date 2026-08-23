import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import 'registration/registration_wizard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const routeName = '/login';

  static const _topBarColor = Color(0xFFC0392B);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onFieldsChanged);
    _passwordController.addListener(_onFieldsChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_onFieldsChanged);
    _passwordController.removeListener(_onFieldsChanged);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onFieldsChanged() => setState(() {});

  bool get _canSubmit =>
      !_isSubmitting && _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final result = AuthService.instance.login(
      email: _emailController.text,
      password: _passwordController.text,
    );
    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (result.isSuccess) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.errorMessage!)),
      );
    }
  }

  void _goToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RegistrationColors.background,
      body: Column(
        children: [
          Container(height: 4, color: LoginScreen._topBarColor),
          Expanded(
            child: SafeArea(
              top: false,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Login to your account',
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w400),
                          ),
                          const SizedBox(height: 24),
                          const Text('Email', style: TextStyle(color: Colors.white, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            textInputAction: TextInputAction.next,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            cursorColor: RegistrationColors.accent,
                            decoration: _fieldDecoration(),
                            validator: (value) {
                              final text = value?.trim() ?? '';
                              if (text.isEmpty) return 'Enter your email';
                              final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                              if (!emailPattern.hasMatch(text)) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          const Text('Password', style: TextStyle(color: Colors.white, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            autofillHints: const [AutofillHints.password],
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _canSubmit ? _submit() : null,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            cursorColor: RegistrationColors.accent,
                            decoration: _fieldDecoration(),
                            validator: (value) {
                              if ((value ?? '').isEmpty) return 'Enter your password';
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          OutlinedButton(
                            onPressed: _canSubmit ? _submit : null,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              disabledForegroundColor: Colors.white38,
                              side: const BorderSide(color: Color(0xFF6B6B6B)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2.5),
                                  )
                                : const Text('Sign in'),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const Text('Not registered? ', style: TextStyle(color: Colors.white)),
                                GestureDetector(
                                  onTap: _isSubmitting ? null : _goToRegister,
                                  child: Text(
                                    'Sign up now!',
                                    style: TextStyle(
                                      color: RegistrationColors.accent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration() {
    const borderColor = Color(0xFF6B6B6B);
    return InputDecoration(
      filled: true,
      fillColor: RegistrationColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
        borderSide: const BorderSide(color: RegistrationColors.accent, width: 2),
      ),
      errorStyle: const TextStyle(color: RegistrationColors.error),
    );
  }
}
