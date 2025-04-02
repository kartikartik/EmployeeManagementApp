import 'package:employee_management_app/model/employee.dart';
import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  DateTime next(int day) {
    return add(
      Duration(
        days: (day - weekday) % DateTime.daysPerWeek,
      ),
    );
  }
}

DateTime convertStringToDate(String dateString) {
  // Define the date format
  DateFormat format = DateFormat('dd MMM, yyyy');

  // Parse the string to DateTime
  DateTime dateTime = format.parse(dateString);

  return dateTime;
}

//group by current emp & previous emp
Map<String, List<Employee>> groupEmployees(List<Employee> employees) {
  Map<String, List<Employee>> groupedEmployees = {};

  for (var employee in employees) {
    if (groupedEmployees.containsKey(employee.empStatus)) {
      groupedEmployees[employee.empStatus]?.add(employee);
    } else {
      groupedEmployees[employee.empStatus] = [employee];
    }
  }

  return groupedEmployees;
}
