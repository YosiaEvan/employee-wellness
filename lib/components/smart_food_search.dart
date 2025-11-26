import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/food_manage_service.dart';
import '../services/tracking_kalori_service.dart';

/// Widget untuk search makanan dengan preview
class SmartFoodSearch extends StatefulWidget {
  final Function(Map<String, dynamic>) onFoodSelected;

  const SmartFoodSearch({
    super.key,
    required this.onFoodSelected,
  });

  @override
  State<SmartFoodSearch> createState() => _SmartFoodSearchState();
}

class _SmartFoodSearchState extends State<SmartFoodSearch> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  Map<String, dynamic>? _foodData;
  String? _sumber;

  Future<void> _showAddFoodDialog(Map<String, dynamic> foodData) async {
    String jenisMakan = 'sarapan';
    double porsi = 1.0;

    await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Tambah Makanan'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    foodData['nama_makanan'] ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Jenis Makan Dropdown
                  const Text('Jenis Makan:', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: jenisMakan,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'sarapan', child: Text('Sarapan')),
                      DropdownMenuItem(value: 'makan_siang', child: Text('Makan Siang')),
                      DropdownMenuItem(value: 'makan_malam', child: Text('Makan Malam')),
                      DropdownMenuItem(value: 'snack', child: Text('Snack')),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        jenisMakan = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // Porsi Input
                  const Text('Porsi:', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          if (porsi > 0.5) {
                            setDialogState(() {
                              porsi -= 0.5;
                            });
                          }
                        },
                      ),
                      Expanded(
                        child: Text(
                          '$porsi porsi',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          setDialogState(() {
                            porsi += 0.5;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Save context reference before any async operations
                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);

                    // Close dialog first
                    navigator.pop();

                    // Show loading snackbar
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Menambahkan makanan...'),
                          ],
                        ),
                        backgroundColor: Colors.blue,
                        duration: Duration(seconds: 2),
                      ),
                    );

                    // POST to API
                    final result = await TrackingKaloriService.tambahMakanan(
                      idFoodNutrition: foodData['id'] ?? 0,
                      jenisMakan: jenisMakan,
                      porsi: porsi,
                    );

                    // IMPORTANT: Wait for database to commit transaction
                    await Future.delayed(const Duration(milliseconds: 500));

                    // Hide loading snackbar
                    messenger.hideCurrentSnackBar();

                    // Pass result to parent - ALWAYS call this
                    widget.onFoodSelected(result);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C368),
                  ),
                  child: const Text('Tambahkan', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _foodData = null;
        _sumber = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _foodData = null;
    });

    // Search via API
    final result = await FoodManageService.searchFood(query.trim());

    setState(() {
      _isSearching = false;

      if (result["success"]) {
        _foodData = result["data"];
        _sumber = result["sumber"];
      } else {
        _foodData = null;
        _sumber = null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result["message"] ?? "Makanan tidak ditemukan"),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Cari makanan... (contoh: Nasi Putih)',
            prefixIcon: const Icon(FontAwesomeIcons.magnifyingGlass),
            suffixIcon: _isSearching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _foodData = null;
                            _sumber = null;
                          });
                        },
                      )
                    : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00C368)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00C368), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          onSubmitted: _performSearch,
        ),

        const SizedBox(height: 16),

        // Preview Data
        if (_foodData != null) ...[
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _sumber == 'gemini' ? const Color(0xFFE3F2FD) : const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _sumber == 'gemini' ? const Color(0xFF2196F3) : const Color(0xFF4CAF50),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _sumber == 'gemini' ? FontAwesomeIcons.brain : FontAwesomeIcons.database,
                          size: 12,
                          color: _sumber == 'gemini' ? const Color(0xFF2196F3) : const Color(0xFF4CAF50),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _sumber == 'gemini' ? 'Dari Gemini AI' : 'Dari Database',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _sumber == 'gemini' ? const Color(0xFF2196F3) : const Color(0xFF4CAF50),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Food Name
                  Text(
                    _foodData!['nama_makanan'] ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Porsi Standard
                  if (_foodData!['porsi_standard'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(FontAwesomeIcons.weightScale, size: 12, color: Color(0xFFFF9800)),
                          const SizedBox(width: 6),
                          Text(
                            'Porsi: ${_foodData!['porsi_standard']}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFFFF9800),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Nutrition Table
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Color(0xFF00C368),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(FontAwesomeIcons.chartPie, size: 16, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Informasi Nutrisi',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Protein
                        _buildNutritionRow(
                          'Protein',
                          '${_foodData!['protein_gram'] ?? 0}g',
                          Colors.red.shade50,
                          Colors.red,
                        ),
                        const Divider(height: 1),

                        // Karbohidrat
                        _buildNutritionRow(
                          'Karbohidrat',
                          '${_foodData!['karbohidrat_gram'] ?? 0}g',
                          Colors.blue.shade50,
                          Colors.blue,
                        ),
                        const Divider(height: 1),

                        // Serat
                        _buildNutritionRow(
                          'Serat',
                          '${_foodData!['serat_gram'] ?? 0}g',
                          Colors.green.shade50,
                          Colors.green,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Warning Badges
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (_foodData!['mengandung_minyak'] == true)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFFF9800)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(FontAwesomeIcons.oilCan, size: 12, color: Color(0xFFFF9800)),
                              SizedBox(width: 6),
                              Text(
                                'Mengandung Minyak',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF9800),
                                ),
                              ),
                            ],
                          ),
                        ),

                      if (_foodData!['mengandung_gula'] == true)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE91E63)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(FontAwesomeIcons.cubesStacked, size: 12, color: Color(0xFFE91E63)),
                              SizedBox(width: 6),
                              Text(
                                'Mengandung Gula',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE91E63),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Select Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _showAddFoodDialog(_foodData!);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C368),
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(FontAwesomeIcons.check, size: 18, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Pilih Makanan Ini',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
        ] else if (!_isSearching && _searchController.text.isEmpty) ...[
          // Empty State
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FontAwesomeIcons.magnifyingGlass,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Cari makanan untuk melihat nutrisinya',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Contoh: Nasi Putih, Ayam Goreng, dll',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNutritionRow(String label, String value, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: bgColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: textColor.withValues(alpha: 0.9),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

