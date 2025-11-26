import 'package:employee_wellness/main.dart';
import 'package:employee_wellness/verify_email.dart';
import 'package:employee_wellness/services/auth_register_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController companyTokenController = TextEditingController();
  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> register() async {
    // Validation
    if (namaController.text.trim().isEmpty) {
      showSnackBar("Nama lengkap harus diisi");
      return;
    }

    if (emailController.text.trim().isEmpty) {
      showSnackBar("Email harus diisi");
      return;
    }

    if (passwordController.text.trim().isEmpty) {
      showSnackBar("Password harus diisi");
      return;
    }

    if (confirmPasswordController.text.trim().isEmpty) {
      showSnackBar("Konfirmasi password harus diisi");
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      showSnackBar("Password dan konfirmasi password tidak sama");
      return;
    }

    if (companyTokenController.text.trim().isEmpty) {
      showSnackBar("Token perusahaan harus diisi");
      return;
    }

    setState(() {
      isLoading = true;
    });

    // Call register API
    final result = await AuthRegisterService.register(
      namaLengkap: namaController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      confirmPassword: confirmPasswordController.text.trim(),
      tokenPerusahaan: companyTokenController.text.trim(),
    );

    setState(() {
      isLoading = false;
    });

    if (result["success"]) {
      showSnackBar(result["message"]);

      // Navigate to verify email page and remove all previous routes
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => VerifyEmail(
            email: emailController.text.trim(),
          ),
        ),
        (route) => false, // Remove all previous routes
      );
    } else {
      showSnackBar(result["message"]);
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    
    return Scaffold(
      backgroundColor: Color(0xFFEDFDF4),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(0xFF00C97A),
                      child: Icon(FontAwesomeIcons.building, size: 40, color: Colors.white),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Employee Wellness",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      "Kesehatan & Kebahagiaan Karyawan",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF4A5565),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                )
                              ]
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                "Buat akun baru Anda",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 20),

                              // Nama Lengkap Field
                              TextFormField(
                                controller: namaController,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    FontAwesomeIcons.user,
                                    size: 20,
                                  ),
                                  labelText: "Nama Lengkap",
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Nama lengkap wajib diisi';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              TextFormField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    FontAwesomeIcons.envelope,
                                    size: 20,
                                  ),
                                  labelText: "Email",
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Email wajib diisi';
                                  }
                                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                  if (!emailRegex.hasMatch(value)) {
                                    return 'Format email tidak valid';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              TextFormField(
                                controller: passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    FontAwesomeIcons.lock,
                                    size: 20,
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                    icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                  ),
                                  hintText: "Masukan kata sandi",
                                  labelText: "Kata Sandi",
                                  isDense: true,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password wajib diisi';
                                  }
                                  if (value.length < 8) {
                                    return 'Password minimal 8 karakter';
                                  }

                                  // Cek kombinasi password
                                  final hasUppercase = RegExp(r'[A-Z]').hasMatch(value);
                                  final hasLowercase = RegExp(r'[a-z]').hasMatch(value);
                                  final hasDigit = RegExp(r'[0-9]').hasMatch(value);
                                  final hasSpecialChar = RegExp(r'[!@#\$&*~%^()_+\-=\[\]{};:"\\|,.<>\/?]').hasMatch(value);

                                  if (!hasUppercase) {
                                    return 'Password harus mengandung huruf kapital';
                                  }
                                  if (!hasLowercase) {
                                    return 'Password harus mengandung huruf kecil';
                                  }
                                  if (!hasDigit) {
                                    return 'Password harus mengandung angka';
                                  }
                                  if (!hasSpecialChar) {
                                    return 'Password harus mengandung simbol';
                                  }
                                  if (value == '12345678') {
                                    return 'Password tidak boleh 12345678';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              TextFormField(
                                controller: confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    FontAwesomeIcons.lock,
                                    size: 20,
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword = !_obscureConfirmPassword;
                                      });
                                    },
                                    icon: Icon(_obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                  ),
                                  hintText: "Masukan kata sandi",
                                  labelText: "Konfirmasi Kata Sandi",
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Konfirmasi Password wajib diisi';
                                  }
                                  if (value.length < 8) {
                                    return 'Password minimal 8 karakter';
                                  }
                                  if (value != passwordController.text) {
                                    return 'Password tidak cocok';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 16,),

                              TextFormField(
                                controller: companyTokenController,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    FontAwesomeIcons.building,
                                    size: 20,
                                  ),
                                  hintText: "Masukan token perusahaan",
                                  labelText: "Token Perusahaan",
                                  isDense: true,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Token perusahaan wajib diisi';
                                  }
                                  if (value.length < 6) {
                                    return 'Token minimal 6 karakter';
                                  }

                                  return null;
                                },
                              ),

                              SizedBox(height: 24,),

                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : register,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    backgroundColor: Color(0xFF7EDFBB),
                                  ),
                                  child: isLoading
                                      ? const CircularProgressIndicator(color: Colors.white)
                                      : const Text(
                                    "Daftar",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: 24,),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Sudah punya akun? ",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const LoginPage()),
                                      )
                                    },
                                    child: Text(
                                      "Masuk",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.green,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      )
    );
  }
}
