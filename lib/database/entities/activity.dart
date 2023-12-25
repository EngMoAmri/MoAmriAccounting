class Activity {
  final int date;
  final String action;
  final String tableName;

  Activity({
    required this.date,
    required this.action,
    required this.tableName,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'action': action,
      'table_name': tableName,
    };
  }

  // get class object from map
  static Activity fromMap(Map<String, dynamic> map) {
    return Activity(
      date: map['date'] as int,
      action: map['action'] as String,
      tableName: map['table_name'] as String,
    );
  }
}
