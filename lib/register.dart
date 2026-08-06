import 'package:employee_wellness/main.dart';
import 'package:employee_wellness/verify_email.dart';
import 'package:employee_wellness/services/auth_register_service.dart';
import 'package:employee_wellness/services/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController companyTokenController = TextEditingController();
  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool isPrivacyAccepted = false;

  Future<void> register() async {
    final loc = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!isPrivacyAccepted) {
      showSnackBar(loc.translate('privacy_required'));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Call register API
      final result = await AuthRegisterService.register(
        namaLengkap: namaController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        confirmPassword: confirmPasswordController.text.trim(),
        tokenPerusahaan: companyTokenController.text.trim(),
      );

      if (!mounted) return;

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
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        showSnackBar("${loc.translate('error_occurred')}$e");
      }
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xFF00C97A),
                      child: FaIcon(FontAwesomeIcons.building, size: 40, color: Colors.white),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      loc.translate('app_title'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      loc.translate('app_subtitle'),
                      style: const TextStyle(
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
                              Text(
                                loc.translate('register_title'),
                                style: const TextStyle(
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
                                  prefixIcon: const Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: FaIcon(
                                      FontAwesomeIcons.user,
                                      size: 20,
                                    ),
                                  ),
                                  labelText: loc.translate('full_name_label'),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return loc.translate('full_name_required');
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              TextFormField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  prefixIcon: const Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: FaIcon(
                                      FontAwesomeIcons.envelope,
                                      size: 20,
                                    ),
                                  ),
                                  labelText: loc.translate('email_label'),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return loc.translate('email_required');
                                  }
                                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                  if (!emailRegex.hasMatch(value)) {
                                    return loc.translate('email_invalid');
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              TextFormField(
                                controller: passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  prefixIcon: const Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: FaIcon(
                                      FontAwesomeIcons.lock,
                                      size: 20,
                                    ),
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                    icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                  ),
                                  hintText: loc.translate('password_hint'),
                                  labelText: loc.translate('password_label'),
                                  isDense: true,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return loc.translate('password_required');
                                  }
                                  if (value.length < 8) {
                                    return loc.translate('password_min_length');
                                  }

                                  // Cek kombinasi password
                                  final hasUppercase = RegExp(r'[A-Z]').hasMatch(value);
                                  final hasLowercase = RegExp(r'[a-z]').hasMatch(value);
                                  final hasDigit = RegExp(r'[0-9]').hasMatch(value);
                                  final hasSpecialChar = RegExp(r'[!@#\$&*~%^()_+\-=\[\]{};:"\\|,.<>\/?]').hasMatch(value);

                                  if (!hasUppercase) {
                                    return loc.translate('password_uppercase');
                                  }
                                  if (!hasLowercase) {
                                    return loc.translate('password_lowercase');
                                  }
                                  if (!hasDigit) {
                                    return loc.translate('password_digit');
                                  }
                                  if (!hasSpecialChar) {
                                    return loc.translate('password_special');
                                  }
                                  if (value == '12345678') {
                                    return loc.translate('password_forbidden');
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              TextFormField(
                                controller: confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                decoration: InputDecoration(
                                  prefixIcon: const Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: FaIcon(
                                      FontAwesomeIcons.lock,
                                      size: 20,
                                    ),
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword = !_obscureConfirmPassword;
                                      });
                                    },
                                    icon: Icon(_obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                  ),
                                  hintText: loc.translate('password_hint'),
                                  labelText: loc.translate('confirm_password_label'),
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return loc.translate('confirm_password_required');
                                  }
                                  if (value.length < 8) {
                                    return loc.translate('password_min_length');
                                  }
                                  if (value != passwordController.text) {
                                    return loc.translate('password_mismatch');
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 16,),

                              TextFormField(
                                controller: companyTokenController,
                                decoration: InputDecoration(
                                  prefixIcon: const Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: FaIcon(
                                      FontAwesomeIcons.building,
                                      size: 20,
                                    ),
                                  ),
                                  hintText: loc.translate('company_token_hint'),
                                  labelText: loc.translate('company_token_label'),
                                  isDense: true,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return loc.translate('company_token_required');
                                  }
                                  if (value.length < 6) {
                                    return loc.translate('company_token_min');
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 16,),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Checkbox(
                                    value: isPrivacyAccepted,
                                    onChanged: (value) {
                                      setState(() {
                                        isPrivacyAccepted = value ?? false;
                                      });
                                    },
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      showPrivacyPolicyDialog(context);
                                    },
                                    child: RichText(
                                      text: TextSpan(
                                        text: loc.translate('i_agree'),
                                        style: const TextStyle(color: Colors.black),
                                        children: [
                                          TextSpan(
                                            text: loc.translate('privacy_policy'),
                                            style: const TextStyle(
                                              color: Colors.blue,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                          const SizedBox(height: 24,),

                              // Tombol
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
                                    backgroundColor: const Color(0xFF7EDFBB),
                                  ),
                                  child: isLoading
                                      ? const CircularProgressIndicator(color: Colors.white)
                                      : Text(
                                    loc.translate('register_button'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24,),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    loc.translate('already_have_account'),
                                    style: const TextStyle(
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
                                      loc.translate('login_button'),
                                      style: const TextStyle(
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

void showPrivacyPolicyDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Kebijakan Privasi"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Last updated: January 07, 2026"),
              SizedBox(height: 8,),
              Text("This Privacy Policy describes Our policies and procedures on the collection, use and disclosure of Your information when You use the Service and tells You about Your privacy rights and how the law protects You."),
              SizedBox(height: 8,),
              Text("We use Your Personal data to provide and improve the Service. By using the Service, You agree to the collection and use of information in accordance with this Privacy Policy."),
              SizedBox(height: 8,),
              Text(
                "Interpretation and Definitions",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8,),
              Text(
                "Interpretation",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8,),
              Text("The words whose initial letters are capitalized have meanings defined under the following conditions. The following definitions shall have the same meaning regardless of whether they appear in singular or in plural."),
              SizedBox(height: 8,),
              Text(
                "Definitions",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8,),
              Text("For the purposes of this Privacy Policy:"),
              SizedBox(height: 8,),
              Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Account ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text:
                                'means a unique account created for You to access our Service or parts of our Service.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Affiliate ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text:
                                'means an entity that controls, is controlled by, or is under common control with a party, where &quot;control&quot; means ownership of 50% or more of the shares, equity interest or other securities entitled to vote for election of directors or other managing authority.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Application ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text:
                                'refers to Employee Wellness, the software program provided by the Company.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Company ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text:
                                '(referred to as either "the Company", "We";, "Us" or "Our" in this Agreement) refers to Employee Wellness.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Country ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text:
                                'refers to: Indonesia',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Device ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text:
                                'means any device that can access the Service such as a computer, a cell phone or a digital tablet.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Personal Data ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text:
                                'is any information that relates to an identified or identifiable individual.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Service ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text:
                                'refers to the Application.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Service Provider ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text:
                                'means any natural or legal person who processes the data on behalf of the Company. It refers to third-party companies or individuals employed by the Company to facilitate the Service, to provide the Service on behalf of the Company, to perform services related to the Service or to assist the Company in analyzing how the Service is used.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Usage Data ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text:
                                'refers to data collected automatically, either generated by the use of the Service or from the Service infrastructure itself (for example, the duration of a page visit).',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'You ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text:
                                'means the individual accessing or using the Service, or the company, or other legal entity on behalf of which such individual is accessing or using the Service, as applicable.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8,),
              Text(
                "Collecting and Using Your Personal Data",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8,),
              Text(
                "Types of Data Collected",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8,),
              Text(
                "Personal Data",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8,),
              Text("While using Our Service, We may ask You to provide Us with certain personally identifiable information that can be used to contact or identify You. Personally identifiable information may include, but is not limited to:",),
              SizedBox(height: 8,),
              Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text("Email address"),
                    ],
                  ),
                  SizedBox(height: 8,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text("First name and last name"),
                    ],
                  ),
                  SizedBox(height: 8,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text("Phone number"),
                    ],
                  ),
                  SizedBox(height: 8,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text("Usage Data"),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8,),
              Text(
                "Usage Data",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8,),
              Text("Usage Data is collected automatically when using the Service."),
              SizedBox(height: 8,),
              Text("Usage Data may include information such as Your Device's Internet Protocol address (e.g. IP address), browser type, browser version, the pages of our Service that you visit, the time and date of Your visit, the time spent on those pages, unique device identifiers and other diagnostic data."),
              SizedBox(height: 8,),
              Text("We may also collect information that Your browser sends whenever You visit Our Service or when You access the Service by or through a mobile device."),
              SizedBox(height: 8,),
              Text(
                "Information Collected while Using the Application",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8,),
              Text("While using Our Application, in order to provide features of Our Application, We may collect with Your prior permission:"),
              SizedBox(height: 8,),
              Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text("Information regarding your location"),
                      ),
                    ],
                  ),
                  SizedBox(height: 8,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text("Pictures and other information from your Device's camera and photo library"),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8,),
              Text("We use this information to provide features of Our Service, to improve and customize Our Service. The information may be uploaded to the Company's servers and/or a Service Provider's server or it may be simply stored on Your device."),
              SizedBox(height: 8,),
              Text("You can enable or disable access to this information at any time, through Your Device settings."),
              SizedBox(height: 8,),
              Text(
                "Use of Your Personal Data",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8,),
              Text("The Company may use Personal Data for the following purposes:"),
              SizedBox(height: 8,),
              Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'To provide and maintain our Service, ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text:
                                'including to monitor the usage of our Service.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'To manage Your Account: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text:
                                'to manage Your registration as a user of the Service. The Personal Data You provide can give You access to different functionalities of the Service that are available to You as a registered user.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'For the performance of a contract: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text:
                                'the development, compliance and undertaking of the purchase contract for the products, items or services You have purchased or of any other contract with Us through the Service.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'To contact You: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text:
                                "(To contact You by email, telephone calls, SMS, or other equivalent forms of electronic communication, such as a mobile application's push notifications regarding updates or informative communications related to the functionalities, products or contracted services, including the security updates, when necessary or reasonable for their implementation.",
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'To provide You ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text:
                                'with news, special offers, and general information about other goods, services and events which We offer that are similar to those that you have already purchased or inquired about unless You have opted not to receive such information.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'To manage Your requests: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text:
                                'To attend and manage Your requests to Us.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'For business transfers: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text:
                                'We may use Your information to evaluate or conduct a merger, divestiture, restructuring, reorganization, dissolution, or other sale or transfer of some or all of Our assets, whether as a going concern or as part of bankruptcy, liquidation, or similar proceeding, in which Personal Data held by Us about our Service users is among the assets transferred.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'For other purposes: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text:
                                'We may use Your information for other purposes, such as data analysis, identifying usage trends, determining the effectiveness of our promotional campaigns and to evaluate and improve our Service, products, services, marketing and your experience.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8,),
              Text("We may share Your personal information in the following situations:"),
              SizedBox(height: 8,),
              Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'With Service Providers: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text:
                                'We may share Your personal information with Service Providers to monitor and analyze the use of our Service, to contact You.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'For business transfers: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text:
                                'We may share or transfer Your personal information in connection with, or during negotiations of, any merger, sale of Company assets, financing, or acquisition of all or a portion of Our business to another company.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'With Affiliates: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text:
                                'We may share Your information with Our affiliates, in which case we will require those affiliates to honor this Privacy Policy. Affiliates include Our parent company and any other subsidiaries, joint venture partners or other companies that We control or that are under common control with Us.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'With business partners: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text:
                                "when You share personal information of otherwise interact in the public areas with other users, such information may be viewed by all users and may be publicly distributed outside.",
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'With Your consent: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text:
                                'We may disclose Your personal information for any other purpose with Your consent.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8,),
              Text(
                "Retention of Your Personal Data",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8,),
              Text("The Company will retain Your Personal Data only for as long as is necessary for the purposes set out in this Privacy Policy. We will retain and use Your Personal Data to the extent necessary to comply with our legal obligations (for example, if we are required to retain your data to comply with applicable laws), resolve disputes, and enforce our legal agreements and policies."),
              SizedBox(height: 8,),
              Text("The Company will also retain Usage Data for internal analysis purposes. Usage Data is generally retained for a shorter period of time, except when this data is used to strengthen the security or to improve the functionality of Our Service, or We are legally obligated to retain this data for longer periods."),
              SizedBox(height: 8,),
              Text(
                "Transfer of Your Personal Data",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8,),
              Text("Your information, including Personal Data, is processed at the Company's operating offices and in any other places where the parties involved in the processing are located. It means that this information may be transferred to - and maintained on - computers located outside of Your state, province, country or other governmental jurisdiction where the data protection laws may differ from those from Your durisdiction."),
              SizedBox(height: 8,),
              Text("Your consent to this Privacy Policy followed by Your submission of such information represents Your agreement to that transfer."),
              SizedBox(height: 8,),
              Text("The Company will take all steps reasonably necessary to ensure that Your data is treated securely and in accordance with this Privacy Policy and no transfer of Your Personal Data will take place to an organization or a country unless there are adequate controls in place including the security of Your data and other personal information."),
              SizedBox(height: 8,),
              Text(
                "Delete Your Personal Data",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8,),
              Text("You have the right to delete or request that We assist in deleting the Personal Data that We have collected about You."),
              SizedBox(height: 8,),
              Text("Our Service may give You the ability to delete certain information about You from within the Service."),
              SizedBox(height: 8,),
              Text("You may update, amend, or delete Your information at any time by signing in to Your Account, if you have one, and visiting the account settings section that allows you to manage Your personal information. You may also contact Us to request access to, correct, or delete any personal information that You have provided to Us."),
              SizedBox(height: 8,),
              Text("Please note, however, that We may need to retain certain information when we have a legal obligation or lawful basis to do so."),
              SizedBox(height: 8,),
              Text(
                "Disclosure of Your Personal Data",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8,),
              Text(
                "Business Transactions",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8,),
              Text("If the Company is involved in a merger, acquisition or asset sale, Your Personal Data may be transferred. We will provide notice before Your Personal Data is transferred and becomes subject to a different Privacy Policy."),
              SizedBox(height: 8,),
              Text(
                "Law enforcement",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8,),
              Text("Under certain circumstances, the Company may be required to disclose Your Personal Data if required to do so by law or in response to valid requests by public authorities (e.g. a court or a government agency)."),
              SizedBox(height: 8,),
              Text(
                "Other legal requirements",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8,),
              Text("The Company may disclose Your Personal Data in the good faith belief that such action is necessary to:"),
              SizedBox(height: 8,),
              Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text("Comply with a legal obligation"),
                      ),
                    ],
                  ),
                  SizedBox(height: 8,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text("Protect and defend the rights or property of the Company"),
                      ),
                    ],
                  ),
                  SizedBox(height: 8,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text("Prevent or investigate possible wrongdoing in connection with the Service"),
                      ),
                    ],
                  ),
                  SizedBox(height: 8,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text("Protect the personal safety of Users of the Service or the public"),
                      ),
                    ],
                  ),
                  SizedBox(height: 8,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text("Protect against legal liability"),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8,),
              Text(
                "Security of Your Personal Data",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8,),
              Text("The security of Your Personal Data is important to Us, but remember that no method of transmission over the Internet, or method of electronic storage is 100% secure. While We strive to use commercially reasonable means to protect Your Personal Data, We cannot guarantee its absolute security."),
              SizedBox(height: 8,),
              Text(
                "Children's Privacy",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8,),
              Text("Our Service does not address anyone under the age of 13. We do not knowingly collect personally identifiable information from anyone under the age of 13. If You are a parent or guardian and You are aware that Your child has provided Us with Personal Data, please contact Us. If We become aware that We have collected Personal Data from anyone under the age of 13 without verification of parental consent, We take steps to remove that information from Our servers."),
              SizedBox(height: 8,),
              Text("If We need to rely on consent as a legal basis for processing Your information and Your country requires consent from a parent, We may require Your parent's consent before We collect and use that information."),
              SizedBox(height: 8,),
              Text(
                "Links to Other Websites",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8,),
              Text("Our Service may contain links to other websites that are not operated by Us. If You click on a third party link, You will be directed to that third party's site. We strongly advise You to review the Privacy Policy of every site You visit."),
              SizedBox(height: 8,),
              Text("We have no control over and assume no responsibility for the content, privacy policies or practices of any third party sites or services."),
              SizedBox(height: 8,),
              Text(
                "Changes to this Privacy Policy",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8,),
              Text("We may update Our Privacy Policy from time to time. We will notify You of any changes by posting the new Privacy Policy on this page."),
              SizedBox(height: 8,),
              Text('We will let You know via email and/or a prominent notice on Our Service, prior to the change becoming effective and update the "Last updated" date at the top of this Privacy Policy.'),
              SizedBox(height: 8,),
              Text("You are advised to review this Privacy Policy periodically for any changes. Changes to this Privacy Policy are effective when they are posted on this page."),
          ],
          ),
        ),
      );
    }
  );
}
