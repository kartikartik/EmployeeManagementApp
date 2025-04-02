// lib/employee_bloc.dart
import 'package:employee_management_app/bloc/employee_event.dart';
import 'package:employee_management_app/bloc/employee_state.dart';
import 'package:employee_management_app/model/employee.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

// Define BLoC
class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  final Box<Employee> employees;

  EmployeeBloc(this.employees) : super(EmployeeLoading()) {
    on<LoadEmployee>((event, emit) {
      final tasks = employees.values.toList();
      emit(Employeeloaded(tasks));
    });

    on<AddEmployeeEvent>((event, emit) {
      employees.add(event.employee);
      add(LoadEmployee());
    });

    on<DeleteEmployeeEvent>((event, emit) {
      final index =
          employees.values.toList().indexWhere((e) => e.id == event.id);

      final deletedEmployee = employees.getAt(index);
      employees.deleteAt(index);
      UndoEmployeeState(
        employees.values.toList().cast<Employee>(),
        lastDeletedEmployee: deletedEmployee,
        uID: event.id,
      );
      add(LoadEmployee());
    });

    on<UndoEmployeeState>((event, emit) {
      if (event.lastDeletedEmployee != null && event.uID != null) {
        employees.add(event.lastDeletedEmployee!);
      }

      add(LoadEmployee());
    });

    on<UpdateEmployeeEvent>((event, emit) {
      final index =
          employees.values.toList().indexWhere((e) => e.id == event.id);

      employees.putAt(
          index, event.employee); // Update the employee at the specified index
      add(LoadEmployee());
    });
  }
}
