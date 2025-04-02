
// Define state

import 'package:employee_management_app/model/employee.dart';

abstract class EmployeeState {}

class EmployeeLoading extends EmployeeState {}

class Employeeloaded extends EmployeeState {
  final List<Employee> employees;

  Employeeloaded(this.employees);
}


