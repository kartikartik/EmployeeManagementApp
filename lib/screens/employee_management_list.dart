import 'package:employee_management_app/bloc/employee_bloc.dart';
import 'package:employee_management_app/bloc/employee_event.dart';
import 'package:employee_management_app/bloc/employee_state.dart';
import 'package:employee_management_app/model/employee.dart';
import 'package:employee_management_app/screens/employee_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:employee_management_app/utils/helper.dart';

class EmployeeManagementList extends StatelessWidget {
  const EmployeeManagementList({super.key});

  @override
  Widget build(BuildContext context) {
    final employees = Hive.box<Employee>('employees');

    return MaterialApp(
      home: BlocProvider(
        create: (_) => EmployeeBloc(employees)..add(LoadEmployee()),
        child: const EmployeeListScreen(),
      ),
    );
  }
}

class EmployeeListScreen extends StatelessWidget {
  const EmployeeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final employeeManage = BlocProvider.of<EmployeeBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Employee List',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.lightBlue,
      ),
      body: BlocBuilder<EmployeeBloc, EmployeeState>(
        builder: (context, state) {
          if (state is EmployeeLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is Employeeloaded) {
            final tasks = state.employees;
            final Map<String, List<Employee>> groupedEmployees = groupEmployees(
              tasks,
            );

            return groupedEmployees.isNotEmpty
                ? ListView.builder(
                  itemCount: groupedEmployees.keys.length,
                  itemBuilder: (context, index) {
                    final category = groupedEmployees.keys.elementAt(index);
                    final employeesInCategory = groupedEmployees[category]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          height: 40,
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.all(8),
                          color: Colors.grey[200],
                          child: Text(
                            category,
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        showEmpList(context, employeesInCategory, employeeManage)
                      ],
                    );
                  },
                )
                : Center(
                  child: Image.asset(
                    'images/notFound.png',
                    width: 300,
                    height: 300,
                  ),
                );
          }
          return const Center(child: Text('No tasks available.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.white,
        backgroundColor: Colors.lightBlue,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => BlocProvider.value(
                    value: employeeManage,
                    child: EmployeeFormScreen(),
                  ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget showEmpList(BuildContext context,List<Employee> employeesInCategory,EmployeeBloc employeeManage) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: employeesInCategory.length,
      itemBuilder: (context, employeeIndex) {
        final employee = employeesInCategory[employeeIndex];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Column(
            children: [
              Dismissible(
                key: UniqueKey(),
                background: const ColoredBox(
                  color: Colors.red,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                  ),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (DismissDirection direction) {
                  employeeManage.add(DeleteEmployeeEvent(employee.id));
                  //swipe to delete handle
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${employee.name} deleted'),
                      action: SnackBarAction(
                        label: 'UNDO',
                        onPressed: () {
                          employeeManage.add(
                            UndoEmployeeState(
                              employeesInCategory,
                              lastDeletedEmployee: employee,
                              uID: employee.id,
                            ),
                          );
                        },
                      ),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                },
                child: GestureDetector(
                  onTap: () {
                    //edit record handle
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => BlocProvider.value(
                              value: employeeManage,
                              child: EmployeeFormScreen(
                                employee: employee,
                                index: employeeIndex,
                                employeesInCategory: employeesInCategory,
                              ),
                            ),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ListTile(
                        title: Text(
                          employee.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(employee.position),
                            Text(
                              employee.dateOfEnd == "No Date"
                                  ? 'From ${employee.dateOfJoining}'
                                  : '${employee.dateOfJoining} - ${employee.dateOfEnd}',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
