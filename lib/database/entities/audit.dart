import 'dart:convert';

class Audit {
  final int date;
  final String table;
  final String action;
  final String? oldData;
  final String? newData;
  final int userId;
  final String userData;

  Audit({
    required this.date,
    required this.table,
    required this.action,
    required this.oldData,
    required this.newData,
    required this.userId,
    required this.userData,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'table': table,
      'action': action,
      'old_data': oldData,
      'new_data': newData,
      'user_id': userId,
      'user_data': userData,
    };
  }

  Map<String, dynamic> getNewDataMap() {
    if (newData == null) return {};
    return json.decode(newData!);
  }

  Map<String, dynamic> getOldDataMap() {
    if (oldData == null) return {};
    return json.decode(oldData!);
  }

  Map<String, dynamic> getUserDataMap() {
    return json.decode(userData);
  }

  static String mapToString(Map map) {
    return json.encode(map);
  }

  // get class object from map
  static Audit fromMap(Map<String, dynamic> map) {
    return Audit(
      date: map['date'] as int,
      table: map['table'] as String,
      action: map['action'] as String,
      oldData: map['old_data'] as String?,
      newData: map['new_data'] as String?,
      userId: map['user_id'] as int,
      userData: map['user_data'] as String,
    );
  }
}
