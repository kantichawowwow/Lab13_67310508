enum TransactionType { income, expense }

class MyTransaction {
  final int? id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;

  MyTransaction({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
  });

  // แปลงจาก Object เป็น Map เพื่อบันทึกลง SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id, // ใส่ id เฉพาะเมื่อมีค่า เพื่อไม่ให้ UPDATE ผิดพลาด
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type.name, // เก็บเป็น string ('income' หรือ 'expense')
    };
  }

  // แปลงจาก Map ที่อ่านได้จาก SQLite กลับเป็น Object
  factory MyTransaction.fromMap(Map<String, dynamic> map) {
    return MyTransaction(
      id: map['id'] as int,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      type: TransactionType.values.byName(map['type'] as String),
    );
  }
}