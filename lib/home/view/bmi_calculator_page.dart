import 'package:flutter/material.dart';
import 'package:myapp/home/models/bmi_record.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class BMICalculatorPage extends StatefulWidget {
  const BMICalculatorPage({super.key});

  @override
  BMICalculatorPageState createState() => BMICalculatorPageState();
}

class BMICalculatorPageState extends State<BMICalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();
  List<BMIRecord> _bmiHistory = [];
  bool _isLoading = false;
  Gender _selectedGender = Gender.male;
  double _activityLevel = 1.2; // Sedentary by default

  @override
  void initState() {
    super.initState();
    _loadBMIHistory();
  }

  Future<void> _loadBMIHistory() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? recordsJson = prefs.getString('bmi_records');

      if (recordsJson != null) {
        final List<dynamic> recordsList = jsonDecode(recordsJson);
        setState(() {
          _bmiHistory = recordsList
              .map((json) => BMIRecord.fromMap(json))
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat riwayat BMI: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveBMIHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> recordsList = _bmiHistory
          .map((record) => record.toMap())
          .toList();
      await prefs.setString('bmi_records', jsonEncode(recordsList));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan riwayat BMI: $e')),
        );
      }
    }
  }

  Future<void> _calculateAndSaveBMI() async {
    if (!_formKey.currentState!.validate()) return;

    final weight = double.parse(_weightController.text);
    final height =
        double.parse(_heightController.text) / 100; // Convert to meters
    final age = int.parse(_ageController.text);
    final bmi = weight / (height * height);

    // Calculate ideal weight based on gender using Robinson formula
    final double idealWeight;
    if (_selectedGender == Gender.male) {
      idealWeight = 52 + 1.9 * ((height * 100 - 152.4) / 2.54);
    } else {
      idealWeight = 49 + 1.7 * ((height * 100 - 152.4) / 2.54);
    }

    // Calculate BMR using Mifflin-St Jeor Equation
    final double bmr;
    if (_selectedGender == Gender.male) {
      bmr = (10 * weight) + (6.25 * height * 100) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height * 100) - (5 * age) - 161;
    }

    // Calculate TDEE (Total Daily Energy Expenditure)
    final tdee = bmr * _activityLevel;

    // Calculate body fat percentage using different formulas for men and women
    final double bodyFatPercentage;
    if (_selectedGender == Gender.male) {
      bodyFatPercentage = (1.20 * bmi) + (0.23 * age) - 16.2;
    } else {
      bodyFatPercentage = (1.20 * bmi) + (0.23 * age) - 5.4;
    }

    final record = BMIRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      weight: weight,
      height: height * 100,
      bmi: bmi,
      idealWeight: idealWeight,
      date: DateTime.now(),
      gender: _selectedGender,
      age: age,
      bmr: bmr,
      tdee: tdee,
      bodyFatPercentage: bodyFatPercentage,
    );

    setState(() {
      _bmiHistory.insert(
        0,
        record,
      ); // Add new record at the beginning of the list
    });

    await _saveBMIHistory(); // Save to SharedPreferences

    _weightController.clear();
    _heightController.clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('BMI berhasil dihitung dan disimpan')),
      );
    }
  }

  Future<void> _deleteBMIRecord(String id) async {
    setState(() {
      _bmiHistory.removeWhere((record) => record.id == id);
    });

    await _saveBMIHistory(); // Save changes to SharedPreferences

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Data berhasil dihapus')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kalkulator BMI')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<Gender>(
                            initialValue: _selectedGender,
                            decoration: const InputDecoration(
                              labelText: 'Jenis Kelamin',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: Gender.male,
                                child: Text('Laki-laki'),
                              ),
                              DropdownMenuItem(
                                value: Gender.female,
                                child: Text('Perempuan'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedGender = value!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Usia',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Mohon masukkan usia';
                              }
                              final age = int.tryParse(value);
                              if (age == null || age <= 0 || age > 120) {
                                return 'Mohon masukkan usia yang valid';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Berat Badan (kg)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Mohon masukkan berat badan Anda';
                        }
                        final weight = double.tryParse(value);
                        if (weight == null || weight <= 0) {
                          return 'Mohon masukkan berat badan yang valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Tinggi Badan (cm)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Mohon masukkan tinggi badan Anda';
                        }
                        final height = double.tryParse(value);
                        if (height == null || height <= 0) {
                          return 'Mohon masukkan tinggi badan yang valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<double>(
                      initialValue: _activityLevel,
                      decoration: const InputDecoration(
                        labelText: 'Tingkat Aktivitas',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 1.2,
                          child: Text('Sedentary (Jarang Olahraga)'),
                        ),
                        DropdownMenuItem(
                          value: 1.375,
                          child: Text('Ringan (1-3x seminggu)'),
                        ),
                        DropdownMenuItem(
                          value: 1.55,
                          child: Text('Sedang (3-5x seminggu)'),
                        ),
                        DropdownMenuItem(
                          value: 1.725,
                          child: Text('Aktif (6-7x seminggu)'),
                        ),
                        DropdownMenuItem(
                          value: 1.9,
                          child: Text('Sangat Aktif (Atlet)'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _activityLevel = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _calculateAndSaveBMI,
                      child: const Text('Hitung BMI'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Riwayat BMI',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _bmiHistory.isEmpty
                  ? const Center(child: Text('Belum ada riwayat BMI'))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _bmiHistory.length,
                      itemBuilder: (context, index) {
                        final record = _bmiHistory[index];
                        return Card(
                          child: ListTile(
                            title: Text(
                              'BMI: ${record.bmi.toStringAsFixed(1)} - ${record.getBMICategory()}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      record.gender == Gender.male
                                          ? Icons.male
                                          : Icons.female,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text('${record.age} tahun'),
                                  ],
                                ),
                                Text(
                                  'Berat: ${record.weight.toStringAsFixed(1)} kg (Ideal: ${record.idealWeight.toStringAsFixed(1)} kg)',
                                ),
                                Text(
                                  'Tinggi: ${record.height.toStringAsFixed(1)} cm',
                                ),
                                Text(
                                  'Lemak Tubuh: ${record.bodyFatPercentage.toStringAsFixed(1)}% - ${record.getBodyFatCategory()}',
                                ),
                                Text(
                                  'Kebutuhan Kalori: ${record.getDailyCalorieNeeds()} kkal/hari',
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Rekomendasi:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(record.getHealthRecommendations()),
                                Text('Tanggal: ${_formatDate(record.date)}'),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteBMIRecord(record.id!),
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final List<String> months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }
}
