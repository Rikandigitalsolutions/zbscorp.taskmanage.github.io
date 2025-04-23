import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task.dart';
import '../widgets/app_bar.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Task> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final response = await Supabase.instance.client
          .from('jobtasks')
          .select()
          .eq('Active', true);

      setState(() {
        _tasks = response.map<Task>((json) => Task.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading tasks: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Map<String, int> _getTasksByMonth() {
    final Map<String, int> tasksByMonth = {};
    for (var task in _tasks) {
      final month =
          '${task.dueDate.year}-${task.dueDate.month.toString().padLeft(2, '0')}';
      tasksByMonth[month] = (tasksByMonth[month] ?? 0) + 1;
    }
    return tasksByMonth;
  }

  int _getPendingTasksCount() {
    return _tasks.where((task) => task.taskStatus != 'Completed').length;
  }

  Map<String, int> _getPendingTasksByAllotment() {
    final Map<String, int> pendingByAllotment = {};
    for (var task in _tasks.where((task) => task.taskStatus != 'Completed')) {
      pendingByAllotment[task.assignedTo] =
          (pendingByAllotment[task.assignedTo] ?? 0) + 1;
    }
    return pendingByAllotment;
  }

  int _getPendingBillsCount() {
    return _tasks
        .where((task) =>
            task.billStatus != null &&
            task.billStatus!.isNotEmpty &&
            task.billStatus != 'Received' &&
            (task.paymentReceiptStatus == null ||
                task.paymentReceiptStatus!.isEmpty))
        .length;
  }

  int _getCompletedTasksCount() {
    return _tasks.where((task) => task.taskStatus == 'Completed').length;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final tasksByMonth = _getTasksByMonth();
    final pendingTasksCount = _getPendingTasksCount();
    final pendingByAllotment = _getPendingTasksByAllotment();
    final pendingBillsCount = _getPendingBillsCount();
    final completedTasksCount = _getCompletedTasksCount();

    // Calculate grid count based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount;
    if (screenWidth < 600) {
      // Mobile
      crossAxisCount = 1;
    } else if (screenWidth < 900) {
      // Tablet
      crossAxisCount = 2;
    } else if (screenWidth < 1200) {
      // Medium screens
      crossAxisCount = 3;
    } else {
      // Desktop
      crossAxisCount = 4;
    }

    return Scaffold(
      appBar: const CustomAppBar(title: 'Dashboard'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Task Overview',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio:
                    1.5, // Adjust aspect ratio for better mobile display
                children: [
                  _buildTaskCountTile(context),
                  _buildCompletedTasksTile(context, completedTasksCount),
                  _buildPendingTasksTile(context, pendingTasksCount),
                  _buildTasksByMonthTile(context, tasksByMonth),
                  _buildPendingByAllotmentTile(context, pendingByAllotment),
                  _buildPendingBillsTile(context, pendingBillsCount),
                  _buildManageDataTile(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCountTile(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          context.go('/tasks');
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.task_alt, size: 48, color: Colors.blue),
                    const SizedBox(height: 8),
                    Text(
                      '${_tasks.length}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Total Tasks',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPendingTasksTile(BuildContext context, int pendingCount) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          context.go('/tasks?status=Not Started');
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.pending_actions,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 8),
                    Text(
                      '$pendingCount',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pending Tasks',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTasksByMonthTile(
    BuildContext context,
    Map<String, int> tasksByMonth,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_today, size: 48, color: Colors.orange),
              const SizedBox(height: 8),
              const Text(
                'Tasks Due in Month',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: tasksByMonth.length,
                  itemBuilder: (context, index) {
                    final month = tasksByMonth.keys.elementAt(index);
                    final count = tasksByMonth[month]!;
                    return InkWell(
                      onTap: () {
                        context.go('/tasks?month=$month');
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(month, style: const TextStyle(fontSize: 14)),
                            Text(
                              '$count tasks',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPendingByAllotmentTile(
    BuildContext context,
    Map<String, int> pendingByAllotment,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.group_work, size: 48, color: Colors.purple),
              const SizedBox(height: 8),
              const Text(
                'Pending by Team',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: pendingByAllotment.length,
                  itemBuilder: (context, index) {
                    final allotment = pendingByAllotment.keys.elementAt(index);
                    final count = pendingByAllotment[allotment]!;
                    return InkWell(
                      onTap: () {
                        context.go('/tasks?team=$allotment');
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              allotment,
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              '$count tasks',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPendingBillsTile(BuildContext context, int pendingBillsCount) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          context.go('/tasks?billStatus=pending');
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.payment, size: 48, color: Colors.orange),
                    const SizedBox(height: 8),
                    Text(
                      '$pendingBillsCount',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pending Bills',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedTasksTile(BuildContext context, int completedCount) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          context.go('/tasks?status=Completed');
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle,
                        size: 48, color: Colors.green),
                    const SizedBox(height: 8),
                    Text(
                      '$completedCount',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Completed Tasks',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManageDataTile(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          context.go('/manage-data');
        },
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.settings, size: 48, color: Colors.blue),
                    SizedBox(height: 8),
                    Text(
                      'Manage Data',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Manage work categories and other data',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
