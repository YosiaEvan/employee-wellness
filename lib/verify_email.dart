import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pinput/pinput.dart';

class VerifyEmail extends StatefulWidget {
  final String email;

  const VerifyEmail({
    super.key,
    required this.email,
  });

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  bool isLoading = false;
  final TextEditingController otpController = TextEditingController();

  Future<void> verify() async {
    setState(() {
      isLoading = true;
    });

    try {
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal terhubung ke server: $e")),
      );
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 60,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.greenAccent),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withValues(alpha: 0.15),
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
        ],
      ),
    );

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

                   Padding(
                     padding: EdgeInsets.symmetric(horizontal: 24),
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
                             )
                           ]
                       ),
                       child: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           const Text(
                             "Masukkan Kode Verifikasi",
                             style: TextStyle(
                               fontSize: 20,
                               fontWeight: FontWeight.w600,
                             ),
                           ),
                           const SizedBox(height: 20),
                           Pinput(
                             controller: otpController,
                             length: 4,
                             defaultPinTheme: defaultPinTheme,
                             focusedPinTheme: defaultPinTheme.copyWith(
                               decoration: defaultPinTheme.decoration!.copyWith(
                                 border: Border.all(color: Colors.green, width: 2),
                                 boxShadow: [
                                   BoxShadow(
                                     color: Colors.blue.withValues(alpha: 0.25),
                                     offset: const Offset(2, 2),
                                     blurRadius: 6,
                                   ),
                                 ],
                               ),
                             ),
                           ),
                           const SizedBox(height: 20),
                           Row(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               Text(
                                 "Belum menerima kode? ",
                                 style: TextStyle(
                                   fontSize: 16,
                                 ),
                               ),
                               Text(
                                 "Kirim ulang",
                                 style: TextStyle(
                                   fontSize: 16,
                                   color: Colors.green,
                                   fontWeight: FontWeight.w500,
                                 ),
                               ),
                             ],
                           ),
                           const SizedBox(height: 24),
                           SizedBox(
                             width: double.infinity,
                             height: 52,
                             child: ElevatedButton(
                               onPressed: isLoading ? null : verify,
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
                                 "Verifikasi Email",
                                 style: TextStyle(
                                   fontSize: 16,
                                   fontWeight: FontWeight.w500,
                                   color: Colors.white,
                                 ),
                               ),
                             ),
                           ),
                         ],
                       ),
                     ),
                   ),
                 ],
               ),
             ),
           ),
         );
        }
      ),
    );
  }
}
