enum Gender { male, female }

class BMIRecord {
  final String? id;
  final double weight;
  final double height;
  final double bmi;
  final double idealWeight;
  final DateTime date;
  final Gender gender;
  final int age;
  final double bmr; // Basal Metabolic Rate
  final double tdee; // Total Daily Energy Expenditure
  final double bodyFatPercentage;

  BMIRecord({
    this.id,
    required this.weight,
    required this.height,
    required this.bmi,
    required this.idealWeight,
    required this.date,
    required this.gender,
    required this.age,
    required this.bmr,
    required this.tdee,
    required this.bodyFatPercentage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'weight': weight,
      'height': height,
      'bmi': bmi,
      'idealWeight': idealWeight,
      'date': date.toIso8601String(),
      'gender': gender.toString(),
      'age': age,
      'bmr': bmr,
      'tdee': tdee,
      'bodyFatPercentage': bodyFatPercentage,
    };
  }

  factory BMIRecord.fromMap(Map<String, dynamic> map) {
    return BMIRecord(
      id: map['id'],
      weight: map['weight'],
      height: map['height'],
      bmi: map['bmi'],
      idealWeight: map['idealWeight'],
      date: DateTime.parse(map['date']),
      gender: map['gender'] == 'Gender.male' ? Gender.male : Gender.female,
      age: map['age'],
      bmr: map['bmr'],
      tdee: map['tdee'],
      bodyFatPercentage: map['bodyFatPercentage'],
    );
  }

  String getBMICategory() {
    // Age-specific BMI categories
    if (age < 18) {
      return _getChildBMICategory();
    } else {
      return _getAdultBMICategory();
    }
  }

  String _getAdultBMICategory() {
    if (bmi < 18.5) {
      return 'Kurus';
    } else if (bmi >= 18.5 && bmi < 25) {
      return 'Normal';
    } else if (bmi >= 25 && bmi < 30) {
      return 'Kelebihan Berat Badan';
    } else {
      return 'Obesitas';
    }
  }

  String _getChildBMICategory() {
    // BMI categories for children and teens are age and gender specific
    // These are approximate values, in a real app you'd want to use CDC or WHO charts
    if (bmi < 5) {
      return 'Sangat Kurus';
    } else if (bmi < 15) {
      return 'Kurus';
    } else if (bmi < 85) {
      return 'Normal';
    } else if (bmi < 95) {
      return 'Kelebihan Berat Badan';
    } else {
      return 'Obesitas';
    }
  }

  String getHealthRecommendations() {
    final recommendations = <String>[];

    // BMI-based recommendations
    if (bmi < 18.5) {
      recommendations.add('• Tingkatkan asupan kalori harian');
      recommendations.add('• Konsumsi makanan bergizi tinggi protein');
      recommendations.add(
        '• Lakukan latihan kekuatan untuk membangun massa otot',
      );
    } else if (bmi >= 25) {
      recommendations.add('• Kurangi asupan kalori harian');
      recommendations.add('• Tingkatkan aktivitas fisik');
      recommendations.add('• Utamakan makanan tinggi serat dan protein');
    }

    // Age-specific recommendations
    if (age < 18) {
      recommendations.add(
        '• Pastikan asupan nutrisi seimbang untuk pertumbuhan',
      );
      recommendations.add(
        '• Lakukan aktivitas fisik minimal 60 menit per hari',
      );
    } else if (age >= 50) {
      recommendations.add(
        '• Jaga kesehatan tulang dengan asupan kalsium cukup',
      );
      recommendations.add(
        '• Lakukan latihan beban ringan untuk menjaga massa otot',
      );
    }

    // Gender-specific recommendations
    if (gender == Gender.female) {
      recommendations.add('• Pastikan asupan zat besi cukup');
      recommendations.add('• Jaga asupan kalsium untuk kesehatan tulang');
    } else {
      recommendations.add('• Perhatikan asupan protein untuk massa otot');
      recommendations.add('• Jaga kesehatan jantung dengan kardio rutin');
    }

    return recommendations.join('\n');
  }

  String getBodyFatCategory() {
    if (gender == Gender.male) {
      if (bodyFatPercentage < 6) return 'Essential Fat';
      if (bodyFatPercentage < 14) return 'Athletes';
      if (bodyFatPercentage < 18) return 'Fitness';
      if (bodyFatPercentage < 25) return 'Normal';
      return 'Obesitas';
    } else {
      if (bodyFatPercentage < 14) return 'Essential Fat';
      if (bodyFatPercentage < 21) return 'Athletes';
      if (bodyFatPercentage < 25) return 'Fitness';
      if (bodyFatPercentage < 32) return 'Normal';
      return 'Obesitas';
    }
  }

  int getDailyCalorieNeeds() {
    return tdee.round();
  }

  BMIRecord copyWith({
    String? id,
    double? weight,
    double? height,
    double? bmi,
    double? idealWeight,
    DateTime? date,
    Gender? gender,
    int? age,
    double? bmr,
    double? tdee,
    double? bodyFatPercentage,
  }) {
    return BMIRecord(
      id: id ?? this.id,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      bmi: bmi ?? this.bmi,
      idealWeight: idealWeight ?? this.idealWeight,
      date: date ?? this.date,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      bmr: bmr ?? this.bmr,
      tdee: tdee ?? this.tdee,
      bodyFatPercentage: bodyFatPercentage ?? this.bodyFatPercentage,
    );
  }
}
