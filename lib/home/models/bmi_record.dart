class BMIRecord {
  final String? id;  // Changed to String for Appwrite document ID
  final double weight;
  final double height;
  final double bmi;
  final double idealWeight;
  final DateTime date;

  BMIRecord({
    this.id,
    required this.weight,
    required this.height,
    required this.bmi,
    required this.idealWeight,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'weight': weight,
      'height': height,
      'bmi': bmi,
      'idealWeight': idealWeight,
      'date': date.toIso8601String(),
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
    );
  }

  String getBMICategory() {
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

  BMIRecord copyWith({
    String? id,
    double? weight,
    double? height,
    double? bmi,
    double? idealWeight,
    DateTime? date,
  }) {
    return BMIRecord(
      id: id ?? this.id,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      bmi: bmi ?? this.bmi,
      idealWeight: idealWeight ?? this.idealWeight,
      date: date ?? this.date,
    );
  }
}
