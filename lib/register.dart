import 'package:employee_wellness/home.dart';
import 'package:employee_wellness/main.dart';
import 'package:employee_wellness/verify_email.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:employee_wellness/config/api_config.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController companyTokenController = TextEditingController();
  bool isLoading = false;
  bool _obscurePassword = true;

  Future<void> register() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final token = companyTokenController.text.trim();

    setState(() {
      isLoading = true;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const VerifyEmail()),
    );

    // try {
    //   final response = await http.post(
    //     Uri.parse("${ApiConfig.baseUrl}/api/register"),
    //     headers: {"Content-Type": "application/json"},
    //     body: jsonEncode({
    //       "email": email,
    //       "password": password,
    //       "token": token,
    //     }),
    //   );
    //
    //   setState(() {
    //     isLoading = false;
    //   });
    //
    //   if (response.statusCode == 200) {
    //     final data = jsonDecode(response.body);
    //
    //     if (data["status"] == "success") {
    //       Navigator.pushReplacement(
    //         context,
    //         MaterialPageRoute(builder: (context) => const HomePage()),
    //       );
    //     } else {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         SnackBar(content: Text("Register gagal: ${data["message"]}")),
    //       );
    //     }
    //   } else {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text("Terjadi kesalahan server")),
    //     );
    //   }
    // } catch (e) {
    //   setState(() {
    //     isLoading = false;
    //   });
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text("Gagal terhubung ke server: $e")),
    //   );
    // }
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
                                  color: Colors.black.withOpacity(0.05),
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
