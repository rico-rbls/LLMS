/// lib/providers/attendance_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AttendanceRecord {
  final DateTime date;
  final DateTime timeIn;
  final DateTime? timeOut;

  AttendanceRecord({required this.date, required this.timeIn, this.timeOut});
  
  int get durationMinutes => timeOut?.difference(timeIn).inMinutes ?? 0;
}

class AttendanceNotifier extends Notifier<List<AttendanceRecord>> {
  @override
  List<AttendanceRecord> build() {
    final now = DateTime.now();
    return [
      AttendanceRecord(date: now, timeIn: now.subtract(const Duration(hours: 2)), timeOut: now),
      AttendanceRecord(date: now.subtract(const Duration(days: 1)), timeIn: now.subtract(const Duration(days: 1, hours: 4)), timeOut: now.subtract(const Duration(days: 1, hours: 1))),
    ];
  }

  void logAttendance() {
    state = [...state, AttendanceRecord(date: DateTime.now(), timeIn: DateTime.now())];
  }
}

final attendanceProvider = NotifierProvider<AttendanceNotifier, List<AttendanceRecord>>(AttendanceNotifier.new);
