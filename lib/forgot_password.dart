import 'package:employee_wellness/main.dart';
import 'package:employee_wellness/services/app_localizations.dart';
import 'package:employee_wellness/services/password_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  int _step = 1; // 1 = input email, 2 = input kode + password baru
  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    codeController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF00C368),
      ),
    );
  }

  String? _validatePassword(String value) {
    final loc = AppLocalizations.of(context)!;
    if (value.isEmpty) return loc.translate('password_required');
    if (value.length < 8) return loc.translate('password_min_length');
    if (!RegExp(r'[A-Z]').hasMatch(value)) return loc.translate('password_uppercase');
    if (!RegExp(r'[a-z]').hasMatch(value)) return loc.translate('password_lowercase');
    if (!RegExp(r'[0-9]').hasMatch(value)) return loc.translate('password_digit');
    if (!RegExp(r'[!@#\$&*~%^()_+\-=\[\]{};:"\\|,.<>\/?]').hasMatch(value)) {
      return loc.translate('password_special');
    }
    if (value == '12345678') return loc.translate('password_forbidden');
    return null;
  }

  Future<void> sendCode() async {
    final loc = AppLocalizations.of(context)!;
    final email = emailController.text.trim();
    if (email.isEmpty) {
      showSnackBar(loc.translate('email_required'), isError: true);
      return;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      showSnackBar(loc.translate('email_invalid'), isError: true);
      return;
    }

    setState(() => isLoading = true);
    try {
      final result = await PasswordService.forgotPassword(email: email);
      if (!mounted) return;
      setState(() => isLoading = false);

      if (result["success"]) {
        showSnackBar(result["message"]);
        setState(() => _step = 2);
      } else {
        showSnackBar(result["message"], isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      showSnackBar("${loc.translate('error_occurred')}$e", isError: true);
    }
  }

  Future<void> resendCode() async {
    final loc = AppLocalizations.of(context)!;
    final email = emailController.text.trim();
    if (email.isEmpty) {
      showSnackBar(loc.translate('email_required'), isError: true);
      return;
    }
    setState(() => isLoading = true);
    try {
      final result = await PasswordService.forgotPassword(email: email);
      if (!mounted) return;
      setState(() => isLoading = false);
      if (result["success"]) {
        showSnackBar(result["message"]);
      } else {
        showSnackBar(result["message"], isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      showSnackBar("${loc.translate('error_occurred')}$e", isError: true);
    }
  }

  Future<void> resetPassword() async {
    final loc = AppLocalizations.of(context)!;
    final code = codeController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (code.isEmpty) {
      showSnackBar(loc.translate('otp_required'), isError: true);
      return;
    }
    if (code.length != 6) {
      showSnackBar(loc.translate('otp_invalid_length'), isError: true);
      return;
    }

    final passwordError = _validatePassword(password);
    if (passwordError != null) {
      showSnackBar(passwordError, isError: true);
      return;
    }

    if (password != confirmPassword) {
      showSnackBar(loc.translate('password_mismatch'), isError: true);
      return;
    }

    setState(() => isLoading = true);
    try {
      final result = await PasswordService.resetPassword(
        code: code,
        password: password,
      );
      if (!mounted) return;
      setState(() => isLoading = false);

      if (result["success"]) {
        showSnackBar(loc.translate('reset_success'));
        // Kembali ke halaman login setelah sukses
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        });
      } else {
        showSnackBar(result["message"], isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      showSnackBar("${loc.translate('error_occurred')}$e", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFEDFDF4),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xFF00C97A),
                      child: FaIcon(FontAwesomeIcons.lock, size: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      loc.translate('app_title'),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      loc.translate('app_subtitle'),
                      style: const TextStyle(fontSize: 16, color: Color(0xFF4A5565)),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: _step == 1 ? _buildStepEmail(loc) : _buildStepReset(loc),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepEmail(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          loc.translate('forgot_password_title'),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          loc.translate('forgot_password_subtitle'),
          style: const TextStyle(fontSize: 14, color: Color(0xFF4A5565)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.email_outlined),
            hintText: loc.translate('email_hint'),
            labelText: loc.translate('email_label'),
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: isLoading ? null : sendCode,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: const Color(0xFF7EDFBB),
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    loc.translate('send_code_button'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              loc.translate('back_to_login'),
              style: const TextStyle(fontSize: 16, color: Color(0xFF30B762)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepReset(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          loc.translate('code_sent_title'),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          loc.translate('code_sent_desc'),
          style: const TextStyle(fontSize: 14, color: Color(0xFF4A5565)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: codeController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.pin_outlined),
            hintText: '000000',
            labelText: loc.translate('otp_label'),
            counterText: '',
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                loc.translate('resend_code_prompt'),
                style: const TextStyle(fontSize: 14, color: Color(0xFF4A5565)),
              ),
              GestureDetector(
                onTap: isLoading ? null : resendCode,
                child: Text(
                  loc.translate('resend_code'),
                  style: TextStyle(
                    fontSize: 14,
                    color: isLoading ? Colors.grey : Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
            ),
            hintText: loc.translate('password_hint'),
            labelText: loc.translate('new_password_label'),
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              icon: Icon(_obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
            ),
            hintText: loc.translate('password_hint'),
            labelText: loc.translate('confirm_password_label'),
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: isLoading ? null : resetPassword,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: const Color(0xFF7EDFBB),
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    loc.translate('reset_password_button'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: () => setState(() => _step = 1),
            child: Text(
              loc.translate('back_to_login'),
              style: const TextStyle(fontSize: 16, color: Color(0xFF30B762)),
            ),
          ),
        ),
      ],
    );
  }
}
