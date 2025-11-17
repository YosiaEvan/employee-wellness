import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'dart:convert';
import 'dart:io';
import '../services/profile_health_service.dart';
import '../services/auth_storage.dart';
import '../main.dart';

class HealthProfile extends StatefulWidget {
  const HealthProfile({super.key});

  @override
  State<HealthProfile> createState() => _HealthProfileState();
}

class _HealthProfileState extends State<HealthProfile> {
  bool isLoading = false;
  bool isLoadingData = true; // Loading state for fetching data

  // Photo
  File? _imageFile;
  String? _photoBase64;
  final ImagePicker _picker = ImagePicker();

  // Form Controllers
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? selectedOption = "L";
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _targetWeightController = TextEditingController();
  final TextEditingController _targetCalorieController = TextEditingController();
  String? selectedDietType;
  String? selectedActivityLevel;

  // Alergi, Kondisi Medis, Obat
  final TextEditingController _allergyController = TextEditingController();
  final TextEditingController _medicalConditionController = TextEditingController();
  final TextEditingController _drugController = TextEditingController();
  final List<String> _allergyList = [];
  final List<String> _medicalConditionList = [];
  final List<String> _drugList = [];

  // Kontak Darurat
  final TextEditingController _emergencyNameController = TextEditingController();
  final TextEditingController _emergencyPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    setState(() {
      isLoadingData = true;
    });

    print("📥 Loading existing health profile...");

    // Check if user has valid token/credentials
    final hasCredentials = await _checkCredentials();
    if (!hasCredentials) {
      print("❌ No credentials found - redirecting to login");
      setState(() {
        isLoadingData = false;
      });

      if (mounted) {
        _showSnackBar("Sesi Anda telah berakhir. Silakan login kembali.", Colors.red);

        // Redirect to login after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const MyApp()),
              (route) => false,
            );
          }
        });
      }
      return;
    }

    final result = await ProfileHealthService.getProfile();

    setState(() {
      isLoadingData = false;
    });

    // Check if needs login (401 or no credentials)
    if (result["needsLogin"] == true) {
      print("❌ Unauthorized - redirecting to login");

      if (mounted) {
        _showSnackBar("Sesi Anda telah berakhir. Silakan login kembali.", Colors.red);

        // Redirect to login
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const MyApp()),
              (route) => false,
            );
          }
        });
      }
      return;
    }

    if (result["success"] && result["data"] != null) {
      final data = result["data"];

      print("✅ Profile data loaded successfully!");
      print("Data: ${data['nama_lengkap']}, ${data['email']}");

      // Populate form fields with existing data
      setState(() {
        _namaController.text = data['nama_lengkap'] ?? '';
        _emailController.text = data['email'] ?? '';
        selectedOption = data['jenis_kelamin'] ?? 'L';

        // Load existing photo if available
        if (data['foto'] != null && data['foto'].toString().isNotEmpty) {
          print("📷 Existing photo found in profile");
          print("📷 Photo length: ${data['foto'].toString().length}");
          _photoBase64 = data['foto'];
        }

        // Format date from yyyy-MM-dd to dd/MM/yyyy for display
        if (data['tanggal_lahir'] != null) {
          try {
            final date = DateTime.parse(data['tanggal_lahir']);
            _dateController.text = DateFormat('dd/MM/yyyy').format(date);
          } catch (e) {
            _dateController.text = data['tanggal_lahir'];
          }
        }

        _heightController.text = data['tinggi_badan']?.toString() ?? '';
        _weightController.text = data['berat_badan']?.toString() ?? '';
        _targetWeightController.text = data['target_berat']?.toString() ?? '';
        _targetCalorieController.text = data['target_kalori']?.toString() ?? '';

        selectedDietType = data['tipe_diet'];
        selectedActivityLevel = data['level_aktivitas'];

        // Populate lists
        if (data['alergi'] != null && data['alergi'] is List) {
          _allergyList.clear();
          _allergyList.addAll(List<String>.from(data['alergi']));
        }

        if (data['kondisi_medis'] != null && data['kondisi_medis'] is List) {
          _medicalConditionList.clear();
          _medicalConditionList.addAll(List<String>.from(data['kondisi_medis']));
        }

        if (data['obat_dikonsumsi'] != null && data['obat_dikonsumsi'] is List) {
          _drugList.clear();
          _drugList.addAll(List<String>.from(data['obat_dikonsumsi']));
        }

        _emergencyNameController.text = data['nama_kontak_darurat'] ?? '';
        _emergencyPhoneController.text = data['nomor_kontak_darurat'] ?? '';
      });

      _showSnackBar("Data profil berhasil dimuat", const Color(0xFF00C368));
    } else {
      print("ℹ️ No existing profile found or failed to load");
      // No existing profile - this is fine for new users
    }
  }

  Future<bool> _checkCredentials() async {
    try {
      final token = await AuthStorage.getToken();
      final credentials = await AuthStorage.getCredentials();

      // Check if token exists
      if (token == null) {
        print("⚠️ No token found");
        return false;
      }

      // Check if credentials exist and have email/password
      if (credentials == null ||
          (credentials['email'] == null && credentials['password'] == null)) {
        print("⚠️ No valid credentials found");
        return false;
      }

      return true;
    } catch (e) {
      print("❌ Error checking credentials: $e");
      return false;
    }
  }

  /// Compress and encode image to base64
  Future<String> _compressAndEncode(List<int> bytes) async {
    try {
      print("🗜️ Starting image compression...");
      print("📦 Original size: ${bytes.length} bytes");

      // Convert to Uint8List if needed
      final uint8bytes = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);

      // Decode image
      final image = img.decodeImage(uint8bytes);

      if (image == null) {
        print("❌ Failed to decode image");
        throw Exception("Failed to decode image");
      }

      print("📏 Original dimensions: ${image.width}x${image.height}");

      // Resize (max 512px for profile photo)
      final resized = img.copyResize(image, width: 512);
      print("📏 Resized dimensions: ${resized.width}x${resized.height}");

      // Compress to JPEG quality 85
      final compressed = img.encodeJpg(resized, quality: 85);
      print("📦 Compressed size: ${compressed.length} bytes");
      print("📊 Compression ratio: ${((1 - compressed.length / bytes.length) * 100).toStringAsFixed(1)}% reduction");

      // Convert to base64
      final base64String = base64Encode(compressed);
      print("🔐 Base64 length: ${base64String.length} chars");

      return base64String;
    } catch (e) {
      print("❌ Compression error: $e");
      // Fallback: return original base64 if compression fails
      return base64Encode(bytes);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      print("📸 Starting image picker...");
      print("Source: ${source == ImageSource.camera ? 'Camera' : 'Gallery'}");
      print("Platform: ${kIsWeb ? 'Web' : 'Mobile'}");

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      print("📋 PickedFile result: ${pickedFile != null ? 'NOT NULL' : 'NULL'}");

      if (pickedFile != null) {
        print("✅ Image picked: ${pickedFile.path}");
        print("📁 File name: ${pickedFile.name}");
        print("📏 File path length: ${pickedFile.path.length}");

        // Use XFile.readAsBytes() which works on both web and mobile
        final bytes = await pickedFile.readAsBytes();
        print("📦 Bytes read: ${bytes.length} bytes");

        // Compress and encode image
        final base64String = await _compressAndEncode(bytes);

        setState(() {
          // For mobile only, store File object for preview
          if (!kIsWeb) {
            _imageFile = File(pickedFile.path);
            print("📱 Mobile: _imageFile set");
          } else {
            print("🌐 Web: _imageFile NOT set (as expected)");
          }
          _photoBase64 = base64String;
          print("✅ _photoBase64 SET in state");
        });

        print("📊 Current state:");
        print("   - _photoBase64: ${_photoBase64 != null ? 'NOT NULL (${_photoBase64!.length} chars)' : 'NULL'}");
        print("   - _imageFile: ${_imageFile != null ? 'NOT NULL' : 'NULL'}");

        _showSnackBar("Foto berhasil dipilih dan dikompres!", const Color(0xFF00C368));
      } else {
        print("ℹ️ Image selection cancelled by user");
      }
    } catch (e, stackTrace) {
      print("❌ Error picking image: $e");
      print("Stack trace: $stackTrace");
      _showSnackBar("Gagal memilih foto.", Colors.red);
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Pilih Sumber Foto"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text("Kamera"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: const Text("Galeri"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1945),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  void _addAllergy() {
    final text = _allergyController.text.trim();
    if (text.isNotEmpty && !_allergyList.contains(text)) {
      setState(() {
        _allergyList.add(text);
        _allergyController.clear();
      });
    }
  }

  void _removeAllergy(String item) {
    setState(() {
      _allergyList.remove(item);
    });
  }

  void _addMedicalCondition() {
    final text = _medicalConditionController.text.trim();
    if (text.isNotEmpty && !_medicalConditionList.contains(text)) {
      setState(() {
        _medicalConditionList.add(text);
        _medicalConditionController.clear();
      });
    }
  }

  void _removeMedicalCondition(String item) {
    setState(() {
      _medicalConditionList.remove(item);
    });
  }

  void _addDrug() {
    final text = _drugController.text.trim();
    if (text.isNotEmpty && !_drugList.contains(text)) {
      setState(() {
        _drugList.add(text);
        _drugController.clear();
      });
    }
  }

  void _removeDrug(String item) {
    setState(() {
      _drugList.remove(item);
    });
  }

  Future<void> _saveProfile() async {
    // Validation
    if (_namaController.text.trim().isEmpty) {
      _showSnackBar("Nama lengkap harus diisi", Colors.red);
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      _showSnackBar("Email harus diisi", Colors.red);
      return;
    }

    if (_dateController.text.trim().isEmpty) {
      _showSnackBar("Tanggal lahir harus diisi", Colors.red);
      return;
    }

    if (_heightController.text.trim().isEmpty || _weightController.text.trim().isEmpty) {
      _showSnackBar("Tinggi dan berat badan harus diisi", Colors.red);
      return;
    }

    if (_targetWeightController.text.trim().isEmpty || _targetCalorieController.text.trim().isEmpty) {
      _showSnackBar("Target berat dan kalori harus diisi", Colors.red);
      return;
    }

    if (selectedDietType == null || (selectedDietType?.isEmpty ?? true)) {
      _showSnackBar("Tipe diet harus dipilih", Colors.red);
      return;
    }

    if (selectedActivityLevel == null || (selectedActivityLevel?.isEmpty ?? true)) {
      _showSnackBar("Level aktivitas harus dipilih", Colors.red);
      return;
    }

    if (_emergencyNameController.text.trim().isEmpty || _emergencyPhoneController.text.trim().isEmpty) {
      _showSnackBar("Kontak darurat harus diisi", Colors.red);
      return;
    }

    setState(() {
      isLoading = true;
    });

    print("💾 Preparing to save profile...");
    print("📸 Photo state before save:");
    print("   - _photoBase64: ${_photoBase64 != null ? 'NOT NULL (${_photoBase64!.length} chars)' : 'NULL'}");
    print("   - Will send photo: ${_photoBase64 != null ? 'YES' : 'NO'}");

    // Convert date format from dd/MM/yyyy to yyyy-MM-dd
    String tanggalLahir = _dateController.text;
    try {
      final date = DateFormat('dd/MM/yyyy').parse(_dateController.text);
      tanggalLahir = DateFormat('yyyy-MM-dd').format(date);
    } catch (e) {
      print("Date parse error: $e");
    }

    final result = await ProfileHealthService.saveProfile(
      namaLengkap: _namaController.text.trim(),
      email: _emailController.text.trim(),
      jenisKelamin: selectedOption ?? "L",
      tanggalLahir: tanggalLahir,
      tinggiBadan: double.parse(_heightController.text.trim()),
      beratBadan: double.parse(_weightController.text.trim()),
      targetBerat: double.parse(_targetWeightController.text.trim()),
      targetKalori: int.parse(_targetCalorieController.text.trim()),
      tipeDiet: selectedDietType ?? '',
      levelAktivitas: selectedActivityLevel ?? '',
      alergi: _allergyList,
      kondisiMedis: _medicalConditionList,
      obatDikonsumsi: _drugList,
      namaKontakDarurat: _emergencyNameController.text.trim(),
      nomorKontakDarurat: _emergencyPhoneController.text.trim(),
      fotoBase64: _photoBase64, // Send photo if available
    );

    setState(() {
      isLoading = false;
    });

    if (result["success"]) {
      _showSnackBar("Profil kesehatan berhasil disimpan!", const Color(0xFF00C368));

      // Navigate back after 1 second
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    } else {
      _showSnackBar(result["message"] ?? "Gagal menyimpan profil", Colors.red);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _dateController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    _targetCalorieController.dispose();
    _allergyController.dispose();
    _medicalConditionController.dispose();
    _drugController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withValues(alpha: 0.98),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      FontAwesomeIcons.arrowLeft,
                      size: 20,
                    )
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Profil Kesehatan",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "Biodata Lengkap"
                      )
                    ],
                  )
                ],
              ),
            ),

            // Loading Indicator
            if (isLoadingData)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(
                        color: Color(0xFF00C368),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Memuat data profil...",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Main Content
            if (!isLoadingData)
              Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Alert
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color(0xfffff8ed),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 4),
                              child: Icon(
                                FontAwesomeIcons.circleInfo,
                                size: 16,
                              ),
                            ),
                            SizedBox(width: 16,),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Lengkapi Profil Kesehatan",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    "Data ini akan membantu personalisasi program wellness Anda",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              )
                            )
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20,),

                    // Informasi Pribadi
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SizedBox.square(
                                  dimension: 40,
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      FontAwesomeIcons.person,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Text(
                                  "Informasi Pribadi",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Nama Lengkap",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                TextField(
                                  controller: _namaController,
                                  decoration: InputDecoration(
                                    hintText: "Masukan nama lengkap",
                                    isDense: true,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 20),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Email",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                TextField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    hintText: "email@example.com",
                                    isDense: true,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 20),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Foto Profil",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: _showImageSourceDialog,
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.grey.shade50,
                                    ),
                                    child: _photoBase64 == null && _imageFile == null
                                        ? Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.cloud_upload_outlined,
                                                size: 48,
                                                color: Colors.grey.shade400,
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                "Klik untuk upload foto",
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                "JPG, PNG (Max 1MB)",
                                                style: TextStyle(
                                                  color: Colors.grey.shade500,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          )
                                        : Stack(
                                            children: [
                                              Center(
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(10),
                                                  child: _photoBase64 != null
                                                      ? (kIsWeb
                                                          ? Image.memory(
                                                              base64Decode(_photoBase64!),
                                                              height: 200,
                                                              fit: BoxFit.cover,
                                                            )
                                                          : Image.memory(
                                                              base64Decode(_photoBase64!),
                                                              height: 200,
                                                              fit: BoxFit.cover,
                                                            ))
                                                      : (_imageFile != null
                                                          ? Image.file(
                                                              _imageFile!,
                                                              height: 200,
                                                              fit: BoxFit.cover,
                                                            )
                                                          : Container(
                                                              height: 200,
                                                              color: Colors.grey.shade200,
                                                              child: Icon(
                                                                Icons.person,
                                                                size: 80,
                                                                color: Colors.grey.shade400,
                                                              ),
                                                            )),
                                                ),
                                              ),
                                              Positioned(
                                                top: 8,
                                                right: 8,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _imageFile = null;
                                                      _photoBase64 = null;
                                                    });
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      Icons.close,
                                                      color: Colors.white,
                                                      size: 20,
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
                            const SizedBox(height: 20),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Jenis Kelamin",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),

                                Row(
                                  children: [
                                    Row(
                                      children: [
                                        Radio<String>(
                                          value: "L",
                                          groupValue: selectedOption,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedOption = value;
                                            });
                                          },
                                        ),
                                        const Text("Laki-Laki")
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Radio<String>(
                                          value: "P",
                                          groupValue: selectedOption,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedOption = value;
                                            });
                                          },
                                        ),
                                        const Text("Perempuan")
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Taggal Lahir",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                TextField(
                                  controller: _dateController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    hintText: "hh/bb/tttt",
                                    isDense: true,
                                    suffixIcon: const Icon(FontAwesomeIcons.calendar),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                  ),
                                  onTap: () => _selectDate(context),
                                )
                              ],
                            ),
                          ],
                        ),
                      )
                    ),

                    const SizedBox(height: 20),

                    // Informasi Fisik
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SizedBox.square(
                                  dimension: 40,
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Color(0xff9810fa),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      FontAwesomeIcons.ruler,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Text(
                                  "Informasi Fisik",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Tinggi Badan (cm)",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      TextField(
                                        controller: _heightController,
                                        decoration: InputDecoration(
                                            hintText: "170",
                                            isDense: true,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            )
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Berat Badan (kg)",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      TextField(
                                        controller: _weightController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                            hintText: "65",
                                            isDense: true,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            )
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Target Kesehatan
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SizedBox.square(
                                  dimension: 40,
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      FontAwesomeIcons.bullseye,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Text(
                                  "Target Kesehatan",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Target Berat (kg)",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      TextField(
                                        controller: _targetWeightController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                            hintText: "60",
                                            isDense: true,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            )
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Target Kalori/Hari",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      TextField(
                                        controller: _targetCalorieController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                            hintText: "2000",
                                            isDense: true,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            )
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Tipe Diet",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      DropdownButtonFormField<String>(
                                        value: selectedDietType,
                                        hint: const Text("Pilih"),
                                        isExpanded: true,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.all(10),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: const BorderSide(color: Colors.grey),
                                          ),
                                        ),
                                        items: const [
                                          DropdownMenuItem(
                                            value: "",
                                            child: Text("Pilih"),
                                          ),
                                          DropdownMenuItem(
                                            value: "Regular",
                                            child: Text("Regular"),
                                          ),
                                          DropdownMenuItem(
                                            value: "Vegetarian",
                                            child: Text("Vegetarian"),
                                          ),
                                          DropdownMenuItem(
                                            value: "Vegan",
                                            child: Text("Vegan"),
                                          ),
                                          DropdownMenuItem(
                                            value: "Pescatarian",
                                            child: Text("Pescatarian"),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            selectedDietType = value;
                                          });
                                        },
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Level Aktivitas",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      DropdownButtonFormField<String>(
                                        value: selectedActivityLevel,
                                        hint: const Text("Pilih"),
                                        isExpanded: true,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.all(10),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: const BorderSide(color: Colors.grey),
                                          ),
                                        ),
                                        items: const [
                                          DropdownMenuItem(
                                            value: "",
                                            child: Text("Pilih"),
                                          ),
                                          DropdownMenuItem(
                                            value: "Sedentary",
                                            child: Text("Sedentary (Jarang)"),
                                          ),
                                          DropdownMenuItem(
                                            value: "Light",
                                            child: Text("Light (1-3x/minggu)"),
                                          ),
                                          DropdownMenuItem(
                                            value: "Moderate",
                                            child: Text("Moderate (3-5x/minggu)"),
                                          ),
                                          DropdownMenuItem(
                                            value: "Active",
                                            child: Text("Active (6-7x/minggu)"),
                                          ),
                                          DropdownMenuItem(
                                            value: "Very Active",
                                            child: Text("Very Active (2x/hari)"),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            selectedActivityLevel = value;
                                          });
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Informasi Pekerjaan
                    // Container(
                    //   width: double.infinity,
                    //   decoration: BoxDecoration(
                    //     color: Colors.white,
                    //     borderRadius: BorderRadius.circular(20),
                    //   ),
                    //   child: Container(
                    //     padding: EdgeInsets.all(20),
                    //     child: Column(
                    //       mainAxisSize: MainAxisSize.min,
                    //       mainAxisAlignment: MainAxisAlignment.start,
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         Row(
                    //           children: [
                    //             SizedBox.square(
                    //               dimension: 40,
                    //               child: Container(
                    //                 padding: EdgeInsets.all(8),
                    //                 decoration: BoxDecoration(
                    //                   color: Colors.blue,
                    //                   borderRadius: BorderRadius.circular(12),
                    //                 ),
                    //                 child: Icon(
                    //                   FontAwesomeIcons.building,
                    //                   size: 20,
                    //                   color: Colors.white,
                    //                 ),
                    //               ),
                    //             ),
                    //             const SizedBox(width: 20),
                    //             Text(
                    //               "Informasi Pekerjaan",
                    //               style: TextStyle(
                    //                 fontSize: 16,
                    //                 fontWeight: FontWeight.w500,
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //         const SizedBox(height: 20),
                    //         Column(
                    //           mainAxisAlignment: MainAxisAlignment.start,
                    //           crossAxisAlignment: CrossAxisAlignment.start,
                    //           children: [
                    //             Text(
                    //               "Divisi",
                    //               style: TextStyle(
                    //                 fontSize: 14,
                    //                 fontWeight: FontWeight.w500,
                    //               ),
                    //             ),
                    //             const SizedBox(height: 4),
                    //             TextField(
                    //               decoration: InputDecoration(
                    //                 hintText: "Masukan divisi",
                    //                 isDense: true,
                    //                 border: OutlineInputBorder(
                    //                     borderRadius: BorderRadius.circular(10)
                    //                 ),
                    //               ),
                    //             )
                    //           ],
                    //         ),
                    //         const SizedBox(height: 20),
                    //         Column(
                    //           mainAxisAlignment: MainAxisAlignment.start,
                    //           crossAxisAlignment: CrossAxisAlignment.start,
                    //           children: [
                    //             Text(
                    //               "Jabatan",
                    //               style: TextStyle(
                    //                 fontSize: 14,
                    //                 fontWeight: FontWeight.w500,
                    //               ),
                    //             ),
                    //             const SizedBox(height: 4),
                    //             TextField(
                    //               decoration: InputDecoration(
                    //                 hintText: "Masukan jabatan",
                    //                 isDense: true,
                    //                 border: OutlineInputBorder(
                    //                     borderRadius: BorderRadius.circular(10)
                    //                 ),
                    //               ),
                    //             )
                    //           ],
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),

                    const SizedBox(height: 20),

                    // Kondisi Kesehatan Dasar
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SizedBox.square(
                                  dimension: 40,
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFFb749f6),
                                          Color(0xFFec3ca9),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      FontAwesomeIcons.heart,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Text(
                                  "Kondisi Kesehatan Dasar",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 20),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Alergi",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _allergyController,
                                        onSubmitted: (_) => _addAllergy(),
                                        decoration: InputDecoration(
                                          hintText: "Tambah alergi (tekan Enter)",
                                          filled: true,
                                          fillColor: Colors.grey.shade200,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10,),
                                    SizedBox(
                                      height: 48,
                                      width: 48,
                                      child: ElevatedButton(
                                        onPressed: _addAllergy,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          padding: EdgeInsets.zero,
                                        ),
                                        child: const Icon(Icons.add, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12,),
                                if (_allergyList.isEmpty)
                                  Text(
                                    "Tidak ada alergi yang tercatat",
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                  )
                                else
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _allergyList.map((item) {
                                      return Chip(
                                        label: Text(item),
                                        deleteIcon: const Icon(Icons.close, size: 18),
                                        onDeleted: () => _removeAllergy(item),
                                        backgroundColor: Colors.blue.shade50,
                                      );
                                    }).toList(),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Kondisi Medis",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _medicalConditionController,
                                        onSubmitted: (_) => _addMedicalCondition(),
                                        decoration: InputDecoration(
                                          hintText: "Tambah kondisi medis (tekan Enter)",
                                          filled: true,
                                          fillColor: Colors.grey.shade200,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10,),
                                    SizedBox(
                                      height: 48,
                                      width: 48,
                                      child: ElevatedButton(
                                        onPressed: _addMedicalCondition,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          padding: EdgeInsets.zero,
                                        ),
                                        child: const Icon(Icons.add, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12,),
                                if (_medicalConditionList.isEmpty)
                                  Text(
                                    "Tidak ada kondisi medis yang tercatat",
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                  )
                                else
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _medicalConditionList.map((item) {
                                      return Chip(
                                        label: Text(item),
                                        deleteIcon: const Icon(Icons.close, size: 18),
                                        onDeleted: () => _removeMedicalCondition(item),
                                        backgroundColor: Colors.blue.shade50,
                                      );
                                    }).toList(),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Obat yang Dikonsumsi",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _drugController,
                                        onSubmitted: (_) => _addDrug(),
                                        decoration: InputDecoration(
                                          hintText: "Tambah obat (tekan Enter)",
                                          filled: true,
                                          fillColor: Colors.grey.shade200,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10,),
                                    SizedBox(
                                      height: 48,
                                      width: 48,
                                      child: ElevatedButton(
                                        onPressed: _addDrug,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          padding: EdgeInsets.zero,
                                        ),
                                        child: const Icon(Icons.add, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12,),
                                if (_drugList.isEmpty)
                                  Text(
                                    "Tidak ada obat yang tercatat",
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                  )
                                else
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _drugList.map((item) {
                                      return Chip(
                                        label: Text(item),
                                        deleteIcon: const Icon(Icons.close, size: 18),
                                        onDeleted: () => _removeDrug(item),
                                        backgroundColor: Colors.blue.shade50,
                                      );
                                    }).toList(),
                                  ),
                              ],
                            ),
                            // Column(
                            //   children: options.map((item) {
                            //     return CheckboxListTile(
                            //       title: Text(item["label"]),
                            //       value: item["checked"],
                            //       onChanged: (value) {
                            //         setState(() {
                            //           item["checked"] = value ?? false;
                            //         });
                            //       },
                            //     );
                            //   }).toList(),
                            // ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20,),

                    // Kontak Darurat
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SizedBox.square(
                                  dimension: 40,
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      FontAwesomeIcons.phone,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Text(
                                  "Kontak Darurat",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Nama Kontak Darurat",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                TextField(
                                  controller: _emergencyNameController,
                                  decoration: InputDecoration(
                                    hintText: "Nama keluarga/teman",
                                    isDense: true,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 20),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Nomor Telepon",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                TextField(
                                  controller: _emergencyPhoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    hintText: "+62 812 3456 7890",
                                    isDense: true,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      )
                    ),

                    const SizedBox(height: 20),

                    // Note
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color(0xffecfafe),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 4),
                              child: Icon(
                                FontAwesomeIcons.circleInfo,
                                size: 16,
                              ),
                            ),
                            SizedBox(width: 16,),
                            Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Privasi Anda Terjamin",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      "Semua data kesehatan disimpan secara lokal di perangkat Anda dan tidak dikirim ke server manapun.",
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                )
                            )
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          backgroundColor: Colors.blue,
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                          "Simpan Profil Kesehatan",
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
    );
  }
}
