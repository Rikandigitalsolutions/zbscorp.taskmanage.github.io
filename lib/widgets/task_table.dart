import 'package:flutter/material.dart';
import '../models/task.dart';
import 'task_form.dart';

class TaskTable extends StatefulWidget {
  final List<Task> tasks;
  final Function(Task) onTaskUpdated;

  const TaskTable({
    super.key,
    required this.tasks,
    required this.onTaskUpdated,
  });

  @override
  State<TaskTable> createState() => _TaskTableState();
}

class _TaskTableState extends State<TaskTable> {
  List<Task> _filteredTasks = [];
  String? _sortColumn;
  bool _sortAscending = true;
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _filteredTasks = List.from(widget.tasks);
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TaskTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tasks != oldWidget.tasks) {
      _filteredTasks = List.from(widget.tasks);
      _sortTasks();
    }
  }

  void _sort(String columnName) {
    setState(() {
      if (_sortColumn == columnName) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = columnName;
        _sortAscending = true;
      }
      _sortTasks();
    });
  }

  void _sortTasks() {
    if (_sortColumn == null) return;

    _filteredTasks.sort((a, b) {
      int result;
      switch (_sortColumn) {
        case 'Job ID':
          result = (a.id ?? 0).compareTo(b.id ?? 0);
          break;
        case 'Entry-Date':
          result = a.entryDate.compareTo(b.entryDate);
          break;
        case 'DueDate':
          result = a.dueDate.compareTo(b.dueDate);
          break;
        case 'Nature of Work':
          result = a.natureOfWork.compareTo(b.natureOfWork);
          break;
        case 'Work-Category':
          result = a.workCategory.compareTo(b.workCategory);
          break;
        case 'ClientName':
          result = a.clientName.compareTo(b.clientName);
          break;
        case 'Priority':
          result = a.priority.compareTo(b.priority);
          break;
        case 'AssignedTo':
          result = a.assignedTo.compareTo(b.assignedTo);
          break;
        case 'Days Remaining':
          result = a.daysRemaining.compareTo(b.daysRemaining);
          break;
        case 'Amount':
          result = a.amount.compareTo(b.amount);
          break;
        case 'Turnover':
          result = (a.displayTurnover ?? '').compareTo(b.displayTurnover ?? '');
          break;
        case 'BilledFromFirm':
          result = (a.billedFromFirm ?? '').compareTo(b.billedFromFirm ?? '');
          break;
        case 'TaskStatus':
          result = a.taskStatus.compareTo(b.taskStatus);
          break;
        case 'ReviewStatus':
          result = a.displayReviewStatus.compareTo(b.displayReviewStatus);
          break;
        case 'BillStatus':
          result = a.displayBillStatus.compareTo(b.displayBillStatus);
          break;
        case 'PaymentReceiptStatus':
          result = (a.paymentReceiptStatus ?? '')
              .compareTo(b.paymentReceiptStatus ?? '');
          break;
        case 'Outstanding':
          result = a.daysPass.compareTo(b.daysPass);
          break;
        default:
          result = 0;
      }
      return _sortAscending ? result : -result;
    });
  }

  void _applyFilter(String filter) {
    setState(() {
      if (filter.isEmpty) {
        _filteredTasks = List.from(widget.tasks);
      } else {
        _filteredTasks = widget.tasks.where((task) {
          return task.natureOfWork
                  .toLowerCase()
                  .contains(filter.toLowerCase()) ||
              task.workCategory.toLowerCase().contains(filter.toLowerCase()) ||
              task.clientName.toLowerCase().contains(filter.toLowerCase()) ||
              task.priority.toLowerCase().contains(filter.toLowerCase()) ||
              task.assignedTo.toLowerCase().contains(filter.toLowerCase()) ||
              task.taskStatus.toLowerCase().contains(filter.toLowerCase()) ||
              (task.turnover
                      ?.toString()
                      .toLowerCase()
                      .contains(filter.toLowerCase()) ??
                  false) ||
              (task.billedFromFirm
                      ?.toLowerCase()
                      .contains(filter.toLowerCase()) ??
                  false) ||
              (task.billStatus
                      ?.toLowerCase()
                      .contains(filter.toLowerCase()) ??
                  false) ||
              (task.reviewStatus
                      ?.toLowerCase()
                      .contains(filter.toLowerCase()) ??
                  false) ||
              (task.paymentReceiptStatus
                      ?.toLowerCase()
                      .contains(filter.toLowerCase()) ??
                  false);
        }).toList();
      }
      _sortTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Search',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: _applyFilter,
          ),
        ),
        Expanded(
          child: Scrollbar(
            controller: _verticalScrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _verticalScrollController,
              child: Scrollbar(
                controller: _horizontalScrollController,
                thumbVisibility: true,
                scrollbarOrientation: ScrollbarOrientation.bottom,
                child: SingleChildScrollView(
                  controller: _horizontalScrollController,
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: MediaQuery.of(context).size.width,
                      ),
                      child: DataTable(
                        showCheckboxColumn: false,
                        sortColumnIndex: _getSortColumnIndex(),
                        sortAscending: _sortAscending,
                        horizontalMargin: 8,
                        columnSpacing: 8,
                        dataRowMinHeight: 40,
                        headingRowHeight: 40,
                        headingRowColor: WidgetStateProperty.all(
                          Theme.of(context).colorScheme.primaryContainer,
                        ),
                        columns: [
                          _buildDataColumn('Job ID', width: 40),
                          _buildDataColumn('Entry-Date', width: 80),
                          _buildDataColumn('DueDate', width: 80),
                          _buildDataColumn('Nature of Work', width: 100),
                          _buildDataColumn('Work-Category', width: 100),
                          _buildDataColumn('ClientName', width: 120),
                          _buildDataColumn('Priority', width: 80),
                          _buildDataColumn('AssignedTo', width: 120),
                          _buildDataColumn('Days Remaining', width: 50),
                          _buildDataColumn('Amount', width: 60),
                          _buildDataColumn('TaskStatus', width: 80),
                          _buildDataColumn('Turnover', width: 80),
                          _buildDataColumn('BilledFirm', width: 80),
                          _buildDataColumn('ReviewStatus', width: 100),
                          _buildDataColumn('BillStatus', width: 50),
                          _buildDataColumn('PaymentStatus', width: 50)
                        ],
                        rows: _filteredTasks.asMap().entries.map((entry) {
                          final index = entry.key;
                          final task = entry.value;
                          return DataRow(
                            color: WidgetStateProperty.all(
                              index.isEven
                                  ? Theme.of(context).colorScheme.surface
                                  : Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                            ),
                            onSelectChanged: (_) => _editTask(task),
                            cells: [
                              DataCell(Text(task.id.toString())),
                              DataCell(Text(_formatDate(task.entryDate))),
                              DataCell(Text(_formatDate(task.dueDate))),
                              DataCell(Text(task.natureOfWork)),
                              DataCell(Text(task.workCategory)),
                              DataCell(Text(task.clientName)),
                              DataCell(Text(task.priority)),
                              DataCell(Text(task.assignedTo)),
                              DataCell(Text(task.daysRemaining.toString())),
                              DataCell(Text(task.amount.toStringAsFixed(2))),
                              DataCell(Text(task.taskStatus)),
                              DataCell(Text(
                                  task.turnover?.toStringAsFixed(2) ?? '')),
                              DataCell(Text(task.billedFromFirm ?? '')),
                              DataCell(Text(task.reviewStatus ?? '')),
                              DataCell(Text(task.billStatus ?? '')),
                              DataCell(Text(task.paymentReceiptStatus ?? ''))
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  DataColumn _buildDataColumn(String label, {double? width}) {
    return DataColumn(
      label: SizedBox(
        width: width,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            overflow: TextOverflow.visible,
          ),
        ),
      ),
      onSort: (columnIndex, ascending) {
        _sort(label);
      },
    );
  }

  int? _getSortColumnIndex() {
    if (_sortColumn == null) return null;
    final columns = [
      'Job ID',
      'Entry-Date',
      'DueDate',
      'Nature of Work',
      'Work-Category',
      'ClientName',
      'Priority',
      'AssignedTo',
      'Days Remaining',
      'Amount',
      'Turnover',
      'BilledFromFirm',
      'TaskStatus',
      'ReviewStatus',
      'BillStatus',
      'PaymentReceiptStatus',
      'Outstanding',
    ];
    return columns.indexOf(_sortColumn!);
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _editTask(Task task) {
    showDialog(
      context: context,
      builder: (context) => TaskForm(
        onTaskAdded: (updatedTask) {
          widget.onTaskUpdated(updatedTask);
          Navigator.of(context).pop();
        },
        task: task,
      ),
    );
  }
}
