import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:employee_management_app/bloc/employee_bloc.dart';
import 'package:employee_management_app/bloc/employee_event.dart';
import 'package:employee_management_app/model/employee.dart';
import 'package:employee_management_app/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

class EmployeeFormScreen extends StatefulWidget {
  final Employee? employee;
  final int? index;
  final List<Employee>? employeesInCategory;

  EmployeeFormScreen({this.employee, this.index, this.employeesInCategory});

  @override
  _EmployeeFormScreenState createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String? _position;
  String uID = '';
  DateTime todayDate = DateTime.now();
  DateTime fromDate = DateTime.now();
  bool btnTodaySelected = true;
  bool btnNextMonSelected = false;
  bool btnNextTueSelected = false;
  bool btnWeekSelected = false;
  bool endDtFlag = false;
  final _selectedJoiningDate = BehaviorSubject<String>();
  final _selectedEndDate = BehaviorSubject<String>();

  List<String> empRole = [
    'Product Manager',
    'Flutter Designer',
    'QA Tester',
    'Product Owner',
  ];
  @override
  void initState() {
    super.initState();

    handleData();
  }

  handleData() {
    _selectedEndDate.value = "No Date";

    uID = const Uuid().v4();
    if (widget.employee != null) {
      _name = widget.employee?.name ?? "";
      _position = widget.employee?.position ?? "";
      _selectedJoiningDate.value = widget.employee?.dateOfJoining ?? "";
      _selectedEndDate.value = widget.employee?.dateOfEnd ?? "";
      uID = widget.employee?.id ?? "";
      fromDate = convertStringToDate(widget.employee?.dateOfJoining ?? "");
    }
  }

  void updateData(String newData) {
    _selectedJoiningDate.add(newData);
  }

  void updateToData(String newData) {
    _selectedEndDate.add(newData);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeManage = BlocProvider.of<EmployeeBloc>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        automaticallyImplyLeading: false,
        title: Text(
          widget.employee == null
              ? 'Add Employee Details'
              : 'Edit Employee Details',
          style: const TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          widget.employee != null
              ? IconButton(
                icon: const Icon(Icons.delete, color: Colors.white),
                onPressed: () {
                  employeeManage.add(
                    DeleteEmployeeEvent(widget.employee?.id ?? ""),
                  );

                  // Show Snackbar for undo
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${widget.employee?.name} deleted'),
                      action: SnackBarAction(
                        label: 'UNDO',
                        onPressed: () {
                          employeeManage.add(
                            UndoEmployeeState(
                              widget.employeesInCategory,
                              lastDeletedEmployee: widget.employee,
                              uID: widget.employee?.id ?? "",
                            ),
                          );
                        },
                      ),
                      duration: const Duration(seconds: 3),
                    ),
                  );

                  Navigator.of(context, rootNavigator: true).pop();
                },
              )
              : const SizedBox(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Employee name',
                  prefixIcon: Icon(Icons.person, color: Colors.lightBlue),
                  border: OutlineInputBorder(borderSide: BorderSide(width: 1)),
                ),
                initialValue: _name,
                onChanged: (value) {
                  _name = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter Employee name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _position,
                hint: const Text('Select role'),
                iconEnabledColor: Colors.lightBlue,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(
                    Icons.work_outline_outlined,
                    color: Colors.lightBlue,
                  ),
                ),
                items:
                    empRole.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _position = newValue.toString();
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a role';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 40.0,
                    width: MediaQuery.of(context).size.width / 2.6,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7.0),
                      border: Border.all(color: Colors.blueGrey),
                    ),
                    child: TextButton.icon(
                      onPressed: () async {
                        setState(() {
                          endDtFlag = false;
                        });
                        showDialog(
                          context: context,
                          builder:
                              (ctxt) =>
                                  AlertDialog(title: handleCalendar(ctxt)),
                        );
                      },
                      style: TextButton.styleFrom(
                        textStyle: const TextStyle(color: Colors.blue),
                        // backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                      ),
                      icon: const Icon(
                        Icons.calendar_month,
                        color: Colors.blue,
                      ),
                      label: StreamBuilder<String>(
                        stream: _selectedJoiningDate,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              '${snapshot.data}',
                              style: const TextStyle(fontSize: 14),
                            );
                          } else {
                            return const Text('Today');
                          }
                        },
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_forward, color: Colors.blue),
                  Container(
                    height: 40.0,
                    width: MediaQuery.of(context).size.width / 2.6,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7.0),
                      border: Border.all(color: Colors.blueGrey),
                    ),
                    child: TextButton.icon(
                      onPressed: () async {
                        if (_selectedJoiningDate.hasValue) {
                          setState(() {
                            endDtFlag = true;
                            // updateToData("");
                          });

                          showDialog(
                            context: context,
                            builder:
                                (ctxt) =>
                                    AlertDialog(title: handleCalendar(ctxt)),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('First Select from date'),
                            ),
                          );
                        }
                      },
                      style: TextButton.styleFrom(
                        textStyle: const TextStyle(color: Colors.blue),
                        // backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                      ),
                      icon: const Icon(
                        Icons.calendar_month,
                        color: Colors.blue,
                      ),
                      label: StreamBuilder<String>(
                        stream: _selectedEndDate,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              '${snapshot.data}',
                              style: const TextStyle(fontSize: 14),
                            );
                          } else {
                            return const Text('No Date');
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 1,
                color: Colors.grey,
              ),
              const SizedBox(height: 6),
              Row(
                spacing: 4,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MaterialButton(
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      width: 73,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                      child: const Center(
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  MaterialButton(
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      width: 73,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                      child: const Center(
                        child: Text(
                          "Save",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (_selectedJoiningDate.hasValue) {
                          final employee = Employee(
                            id: uID,
                            name: _name,
                            position: _position.toString(),
                            dateOfJoining: _selectedJoiningDate.value,
                            dateOfEnd:
                                _selectedEndDate.hasValue
                                    ? _selectedEndDate.value
                                    : "No Date",
                            empStatus:
                                _selectedEndDate.hasValue &&
                                        _selectedEndDate.value == "No Date"
                                    ? "Current Employees"
                                    : "Previous Employees",
                          );
                          if (widget.index != null) {
                            // Update existing employee
                            employeeManage.add(
                              UpdateEmployeeEvent(uID, employee),
                            );
                          }
                          employeeManage.add(AddEmployeeEvent(employee));
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter joining date'),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget handleCalendar(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MaterialButton(
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    width: 80,
                    // height: 50.0,
                    decoration: BoxDecoration(
                      color: btnTodaySelected ? Colors.blue : Colors.blue[50],
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    // color: Colors.blue,
                    child: Center(
                      child: Text(
                        endDtFlag ? "No Date" : "Today",
                        style: TextStyle(
                          color: btnTodaySelected ? Colors.white : Colors.blue,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      btnTodaySelected = true;
                      btnNextMonSelected = false;
                      btnNextTueSelected = false;
                      btnWeekSelected = false;

                      DateTime todayDate = DateTime.now();
                      final date = DateFormat('dd MMM, yyyy');
                      fromDate = todayDate;
                      endDtFlag
                          ? updateToData("No Date")
                          : updateData(
                            date.format(
                              DateTime.fromMillisecondsSinceEpoch(
                                todayDate.millisecondsSinceEpoch,
                              ),
                            ),
                          );
                    });
                  },
                ),
                MaterialButton(
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    //    width: MediaQuery.of(context).size.width/3.6,
                    // height: 50.0,
                    decoration: BoxDecoration(
                      color: btnNextMonSelected ? Colors.blue : Colors.blue[50],
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    // color: Colors.blue,
                    child: Center(
                      child: Text(
                        endDtFlag ? "Today" : "Next Monday",
                        style: TextStyle(
                          color:
                              btnNextMonSelected ? Colors.white : Colors.blue,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      btnTodaySelected = false;
                      btnNextMonSelected = true;
                      btnNextTueSelected = false;
                      btnWeekSelected = false;

                      DateTime todayDate = DateTime.now();
                      DateTime nextMon = todayDate.next(DateTime.monday);
                      fromDate = nextMon;
                      final date = DateFormat('dd MMM, yyyy');
                      endDtFlag
                          ? updateToData(
                            date.format(
                              DateTime.fromMillisecondsSinceEpoch(
                                todayDate.millisecondsSinceEpoch,
                              ),
                            ),
                          )
                          : updateData(
                            date.format(
                              DateTime.fromMillisecondsSinceEpoch(
                                nextMon.millisecondsSinceEpoch,
                              ),
                            ),
                          );
                    });
                  },
                ),
              ],
            ),
            endDtFlag
                ? const SizedBox()
                : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MaterialButton(
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        // width: MediaQuery.of(context).size.width/3.6,
                        // height: 50.0,
                        decoration: BoxDecoration(
                          color:
                              btnNextTueSelected
                                  ? Colors.blue
                                  : Colors.blue[50],
                          borderRadius: BorderRadius.circular(7.0),
                        ),
                        // color: Colors.blue,
                        child: Center(
                          child: Text(
                            "Next Tuesday",
                            style: TextStyle(
                              color:
                                  btnNextTueSelected
                                      ? Colors.white
                                      : Colors.blue,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          btnTodaySelected = false;
                          btnNextMonSelected = false;
                          btnNextTueSelected = true;
                          btnWeekSelected = false;

                          DateTime todayDate = DateTime.now();
                          DateTime nextTue = todayDate.next(DateTime.tuesday);
                          fromDate = nextTue;
                          final date = DateFormat('dd MMM, yyyy');
                          updateData(
                            date.format(
                              DateTime.fromMillisecondsSinceEpoch(
                                nextTue.millisecondsSinceEpoch,
                              ),
                            ),
                          );
                        });
                      },
                    ),
                    MaterialButton(
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        // height: 50.0,
                        //  width: MediaQuery.of(context).size.width/3.6,
                        decoration: BoxDecoration(
                          color:
                              btnWeekSelected ? Colors.blue : Colors.blue[50],
                          borderRadius: BorderRadius.circular(7.0),
                        ),
                        // color: Colors.blue,
                        child: Center(
                          child: Text(
                            "After 1 Week",
                            style: TextStyle(
                              color:
                                  btnWeekSelected ? Colors.white : Colors.blue,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          btnTodaySelected = false;
                          btnNextMonSelected = false;
                          btnNextTueSelected = false;
                          btnWeekSelected = true;

                          DateTime todayDate = DateTime.now();
                          final date = DateFormat('dd MMM, yyyy');

                          DateTime nextWeek = todayDate.add(Duration(days: 7));
                          fromDate = nextWeek;
                          updateData(
                            date.format(
                              DateTime.fromMillisecondsSinceEpoch(
                                nextWeek.millisecondsSinceEpoch,
                              ),
                            ),
                          );
                        });
                      },
                    ),
                  ],
                ),
            SizedBox(
              width: MediaQuery.of(context).size.width * .8,
              height: 400,
              child: DatePicker(
                highlightColor: Colors.blue,
                slidersColor: Colors.blue,
                splashColor: Colors.blue,
                selectedDate: fromDate,
                currentDate: fromDate,
                initialDate: fromDate,
                minDate: DateTime(
                  todayDate.year - 10,
                  todayDate.month,
                  todayDate.day,
                ),
                maxDate: DateTime(
                  todayDate.year + 10,
                  todayDate.month,
                  todayDate.day,
                ),
                onDateSelected: (value) {
                  fromDate = value;
                  final date = DateFormat('dd MMM, yyyy');
                  var dt = date.format(
                    DateTime.fromMillisecondsSinceEpoch(
                      value.millisecondsSinceEpoch,
                    ),
                  );
                  endDtFlag ? updateToData(dt) : updateData(dt);
                },
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 1,
              padding: const EdgeInsets.all(4),
              color: Colors.grey,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width:100,
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month, color: Colors.blue),
                      const SizedBox(width: 4),
                      StreamBuilder<String>(
                        stream:
                            endDtFlag ? _selectedEndDate : _selectedJoiningDate,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              '${snapshot.data}',
                              style: const TextStyle(fontSize: 12),
                            );
                          } else {
                            return const Text('-');
                          }
                        },
                      ),
                    ],
                  ),
                ),
                 const Spacer(),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    
                    MaterialButton(
                      minWidth: MediaQuery.of(context).size.width * 0.14,
                      padding: EdgeInsets.zero,
                      
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(7.0),
                        ),
                        child: const Center(child: Text("Cancel")),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    MaterialButton(
                       padding: EdgeInsets.zero,
                       minWidth: MediaQuery.of(context).size.width * 0.18,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(7.0),
                        ),
                        child: const Center(
                          child: Text(
                            "Save",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
