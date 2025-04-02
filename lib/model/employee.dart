import 'package:hive/hive.dart';

part 'employee.g.dart';

@HiveType(typeId: 0)
class Employee extends HiveObject {
  @HiveField(0)
  final String id; // Unique identifier

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String position;

  @HiveField(3)
  final String dateOfJoining;

  @HiveField(4)
  final String dateOfEnd;

  @HiveField(5)
  final String empStatus;

  Employee(
      {required this.id,
      required this.name,
      required this.position,
      required this.dateOfJoining,
      required this.dateOfEnd,
      required this.empStatus});
}
