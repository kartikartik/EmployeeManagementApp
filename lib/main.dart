import 'package:employee_management_app/model/employee.dart';
import 'package:employee_management_app/screens/employee_management_list.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(EmployeeAdapter());
  await Hive.openBox<Employee>('employees');

  runApp(const EmployeeManagementList());
}
