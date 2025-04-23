import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../models/task.dart';

class TaskForm extends StatefulWidget {
  final Function(Task) onTaskAdded;
  final Task? task;

  const TaskForm({
    super.key,
    required this.onTaskAdded,
    this.task,
  });

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  final _jobIdController = TextEditingController();
  final _natureOfWorkController = TextEditingController();
  final _workCategoryController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _priorityController = TextEditingController();
  final _assignedToController = TextEditingController();
  final _amountController = TextEditingController();
  final _turnoverController = TextEditingController();
  final _billedFromFirmController = TextEditingController();
  final _billStatusController = TextEditingController();
  final _reviewStatusController = TextEditingController();
  final _paymentReceiptStatusController = TextEditingController();
  final _billInvoiceController = TextEditingController();

  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  DateTime? _paymentReceivedDate;
  String _taskStatus = 'Not Started';
  List<String> _clients = [];
  List<String> _workCategories = [];
  List<String> _employees = [];
  List<String> _billingFirms = [];

  final List<String> _taskStatusOptions = [
    'Not Started',
    'In Progress',
    'Completed'
  ];
  final List<String> _reviewStatusOptions = ['In Progress', 'Completed'];
  final List<String> _priorityOptions = ['High', 'Medium', 'Low'];

  @override
  void initState() {
    super.initState();
    _loadClients();
    _loadWorkCategories();
    _loadEmployees();
    _loadBillingFirms();
    if (widget.task != null) {
      _jobIdController.text = widget.task!.id.toString();
      _natureOfWorkController.text = widget.task!.natureOfWork;
      _workCategoryController.text = widget.task!.workCategory;
      _clientNameController.text = widget.task!.clientName;
      _priorityController.text = widget.task!.priority;
      _assignedToController.text = widget.task!.assignedTo;
      _amountController.text = widget.task!.amount.toString();
      _turnoverController.text = widget.task!.turnover?.toString() ?? '';
      _billedFromFirmController.text = widget.task!.billedFromFirm ?? '';
      _billStatusController.text = widget.task!.billStatus ?? '';
      _reviewStatusController.text = widget.task!.reviewStatus ?? '';
      _paymentReceiptStatusController.text =
          widget.task!.paymentReceiptStatus ?? '';
      _billInvoiceController.text = widget.task!.billInvoice ?? '';
      _paymentReceivedDate = widget.task!.paymentReceivedDate;
      _dueDate = widget.task!.dueDate;
      _taskStatus = widget.task!.taskStatus;
    }
  }

  Future<void> _loadClients() async {
    try {
      final response =
          await Supabase.instance.client.from('clients').select('client_name');

      if (mounted) {
        setState(() {
          _clients = response
              .map<String>((client) => client['client_name'] as String)
              .toList();
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading clients: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadWorkCategories() async {
    try {
      final response = await Supabase.instance.client
          .from('work_category')
          .select('category');

      if (mounted) {
        setState(() {
          _workCategories = response
              .map<String>((category) => category['category'] as String)
              .toList();
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading work categories: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadEmployees() async {
    try {
      final response = await Supabase.instance.client
          .from('employees')
          .select('employee_name');

      if (mounted) {
        setState(() {
          _employees = response
              .map<String>((employee) => employee['employee_name'] as String)
              .toList();
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading employees: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadBillingFirms() async {
    try {
      final response = await Supabase.instance.client
          .from('billing_firm')
          .select('billingfirm');

      if (mounted) {
        setState(() {
          _billingFirms = response
              .map<String>((firm) => firm['billingfirm'] as String)
              .toList();
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading billing firms: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _jobIdController.dispose();
    _natureOfWorkController.dispose();
    _workCategoryController.dispose();
    _clientNameController.dispose();
    _priorityController.dispose();
    _assignedToController.dispose();
    _amountController.dispose();
    _turnoverController.dispose();
    _billedFromFirmController.dispose();
    _billStatusController.dispose();
    _reviewStatusController.dispose();
    _paymentReceiptStatusController.dispose();
    _billInvoiceController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final task = Task(
        id: widget.task?.id,
        entryDate: widget.task?.entryDate ?? DateTime.now(),
        dueDate: _dueDate,
        natureOfWork: _natureOfWorkController.text,
        workCategory: _workCategoryController.text,
        priority: _priorityController.text,
        clientName: _clientNameController.text,
        assignedTo: _assignedToController.text,
        amount: double.parse(_amountController.text),
        turnover: _reviewStatusController.text == 'Completed'
            ? double.parse(_amountController.text)
            : (_turnoverController.text.isEmpty
                ? null
                : double.parse(_turnoverController.text)),
        billedFromFirm: _billedFromFirmController.text.isEmpty
            ? null
            : _billedFromFirmController.text,
        billStatus: _billInvoiceController.text.isNotEmpty
            ? 'Billed'
            : (_billStatusController.text.isEmpty
                ? 'Not Billed'
                : _billStatusController.text),
        billInvoice: _billInvoiceController.text.isEmpty
            ? null
            : _billInvoiceController.text,
        paymentReceivedDate: _paymentReceivedDate,
        taskStatus: _taskStatus,
        reviewStatus:
            _taskStatus == 'Completed' && _reviewStatusController.text.isEmpty
                ? 'In Progress'
                : (_reviewStatusController.text.isEmpty
                    ? null
                    : _reviewStatusController.text),
        paymentReceiptStatus: _paymentReceivedDate != null
            ? 'Received'
            : (_paymentReceiptStatusController.text.isEmpty
                ? 'Not Received'
                : _paymentReceiptStatusController.text),
        active: true,
      );

      widget.onTaskAdded(task);
      context.pop();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _selectPaymentReceivedDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _paymentReceivedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _paymentReceivedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;
    return Scaffold(
      appBar: AppBar(
        title:
            Text(isEditing ? 'Edit Task #${widget.task!.id}' : 'Add New Task'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column
                  Expanded(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _jobIdController,
                          enabled: false,
                          decoration: const InputDecoration(
                            labelText: 'Job ID',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () => _selectDate(context),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Due Date',
                              border: OutlineInputBorder(),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_formatDate(_dueDate)),
                                const Icon(Icons.calendar_today),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _natureOfWorkController,
                          decoration: const InputDecoration(
                            labelText: 'Nature of Work',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter nature of work';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Autocomplete<String>(
                          initialValue: TextEditingValue(
                              text: _workCategoryController.text),
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            return _workCategories.where((category) => category
                                .toLowerCase()
                                .contains(textEditingValue.text.toLowerCase()));
                          },
                          onSelected: (String selection) {
                            _workCategoryController.text = selection;
                          },
                          optionsViewBuilder: (context, onSelected, options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4.0,
                                child: Container(
                                  constraints:
                                      const BoxConstraints(maxHeight: 200),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    itemBuilder: (context, index) {
                                      final option = options.elementAt(index);
                                      return ListTile(
                                        title: Text(option),
                                        onTap: () => onSelected(option),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                          fieldViewBuilder: (BuildContext context,
                              TextEditingController textEditingController,
                              FocusNode focusNode,
                              VoidCallback onFieldSubmitted) {
                            return TextFormField(
                              controller: textEditingController,
                              focusNode: focusNode,
                              decoration: const InputDecoration(
                                labelText: 'Work Category',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a work category';
                                }
                                return null;
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Autocomplete<String>(
                          initialValue: TextEditingValue(
                              text: _clientNameController.text),
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            return _clients.where((client) => client
                                .toLowerCase()
                                .contains(textEditingValue.text.toLowerCase()));
                          },
                          onSelected: (String selection) {
                            _clientNameController.text = selection;
                          },
                          optionsViewBuilder: (context, onSelected, options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4.0,
                                child: Container(
                                  constraints:
                                      const BoxConstraints(maxHeight: 200),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    itemBuilder: (context, index) {
                                      final option = options.elementAt(index);
                                      return ListTile(
                                        title: Text(option),
                                        onTap: () => onSelected(option),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                          fieldViewBuilder: (BuildContext context,
                              TextEditingController textEditingController,
                              FocusNode focusNode,
                              VoidCallback onFieldSubmitted) {
                            return TextFormField(
                              controller: textEditingController,
                              focusNode: focusNode,
                              decoration: const InputDecoration(
                                labelText: 'Client Name',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a client';
                                }
                                return null;
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _priorityController.text.isEmpty
                              ? null
                              : _priorityController.text,
                          decoration: const InputDecoration(
                            labelText: 'Priority',
                            border: OutlineInputBorder(),
                          ),
                          items: _priorityOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              _priorityController.text = value ?? '';
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select priority';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Right Column
                  Expanded(
                    child: Column(
                      children: [
                        Autocomplete<String>(
                          initialValue: TextEditingValue(
                              text: _assignedToController.text),
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            return _employees.where((employee) => employee
                                .toLowerCase()
                                .contains(textEditingValue.text.toLowerCase()));
                          },
                          onSelected: (String selection) {
                            _assignedToController.text = selection;
                          },
                          optionsViewBuilder: (context, onSelected, options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4.0,
                                child: Container(
                                  constraints:
                                      const BoxConstraints(maxHeight: 200),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    itemBuilder: (context, index) {
                                      final option = options.elementAt(index);
                                      return ListTile(
                                        title: Text(option),
                                        onTap: () => onSelected(option),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                          fieldViewBuilder: (BuildContext context,
                              TextEditingController textEditingController,
                              FocusNode focusNode,
                              VoidCallback onFieldSubmitted) {
                            return TextFormField(
                              controller: textEditingController,
                              focusNode: focusNode,
                              decoration: const InputDecoration(
                                labelText: 'Assigned To',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select an employee';
                                }
                                return null;
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _amountController,
                          decoration: const InputDecoration(
                            labelText: 'Amount',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter amount';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        if (isEditing) ...[
                          DropdownButtonFormField<String>(
                            value: _taskStatus,
                            decoration: const InputDecoration(
                              labelText: 'Task Status',
                              border: OutlineInputBorder(),
                            ),
                            items: _taskStatusOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                _taskStatus = value ?? 'Not Started';
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _reviewStatusController.text.isEmpty
                                ? null
                                : _reviewStatusController.text,
                            decoration: const InputDecoration(
                              labelText: 'Review Status',
                              border: OutlineInputBorder(),
                            ),
                            items: _reviewStatusOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                _reviewStatusController.text = value ?? '';
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _turnoverController,
                            decoration: const InputDecoration(
                              labelText: 'Turnover (Optional)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _billedFromFirmController.text.isEmpty
                              ? null
                              : _billedFromFirmController.text,
                          decoration: const InputDecoration(
                            labelText: 'Billed From Firm',
                            border: OutlineInputBorder(),
                          ),
                          items: _billingFirms.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              _billedFromFirmController.text = value ?? '';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (isEditing)
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _billStatusController,
                        decoration: const InputDecoration(
                          labelText: 'Bill Status (Optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _paymentReceiptStatusController,
                        decoration: const InputDecoration(
                          labelText: 'Payment Receipt Status (Optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              if (isEditing)
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _billInvoiceController,
                        decoration: const InputDecoration(
                          labelText: 'Bill Invoice (Optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectPaymentReceivedDate(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Payment Received Date (Optional)',
                            border: OutlineInputBorder(),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_paymentReceivedDate != null
                                  ? _formatDate(_paymentReceivedDate!)
                                  : 'Select Date'),
                              const Icon(Icons.calendar_today),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: Text(isEditing ? 'Update Task' : 'Add Task'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
