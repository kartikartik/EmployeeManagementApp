// Define events
import 'package:employee_management_app/model/employee.dart';

abstract class EmployeeEvent {}

class AddEmployeeEvent extends EmployeeEvent {
  final Employee employee;

  AddEmployeeEvent(this.employee);
}

class DeleteEmployeeEvent extends EmployeeEvent {
  final String id;

  DeleteEmployeeEvent(this.id);
}

class UndoEmployeeState extends EmployeeEvent{
  final List<Employee>? employees;
  final Employee? lastDeletedEmployee;
  final String? uID;

  UndoEmployeeState(this.employees, {this.lastDeletedEmployee, this.uID});
}

class UpdateEmployeeEvent extends EmployeeEvent {
  final String id;
  final Employee employee;

  UpdateEmployeeEvent(this.id, this.employee);
}

class LoadEmployee extends EmployeeEvent {}
