import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/task.dart';
import 'widgets/task_table.dart';
import 'widgets/task_form.dart';
import 'widgets/app_bar.dart';
import 'pages/dashboard_page.dart';
import 'pages/signin_page.dart';
import 'pages/manage_data_page.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://wlxygkqjfhldkgoxpudb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndseHlna3FqZmhsZGtnb3hwdWRiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI3MDI4NTMsImV4cCI6MjA1ODI3ODg1M30.nfMDv7Qkjg0ULVaRzOmO_jFeSbLS6tGCRRfZqif3tcY',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/signin',
      redirect: (context, state) {
        final session = Supabase.instance.client.auth.currentSession;
        final isSignIn = state.matchedLocation == '/signin';

        if (session == null) {
          // Store the intended location in the URL when redirecting to signin
          return isSignIn ? null : '/signin?redirect=${state.matchedLocation}';
        }

        // If coming from signin with a redirect, go to that location
        if (isSignIn) {
          final redirect = state.uri.queryParameters['redirect'];
          return redirect ?? '/dashboard';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/signin',
          builder: (context, state) => const SignInPage(),
        ),
        ShellRoute(
          builder: (context, state, child) => Scaffold(body: child),
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardPage(),
            ),
            GoRoute(
              path: '/tasks',
              builder: (context, state) {
                final team = state.uri.queryParameters['team'];
                final status = state.uri.queryParameters['status'];
                final month = state.uri.queryParameters['month'];
                final billStatus = state.uri.queryParameters['billStatus'];
                return TaskManagementPage(
                  filterByTeam: team,
                  filterByStatus: status,
                  filterByMonth: month,
                  filterByBillStatus: billStatus,
                );
              },
            ),
            GoRoute(
              path: '/manage-data',
              builder: (context, state) => const ManageDataPage(),
            ),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Task Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}

class TaskManagementPage extends StatefulWidget {
  final String? filterByTeam;
  final String? filterByStatus;
  final String? filterByMonth;
  final String? filterByBillStatus;

  const TaskManagementPage({
    super.key,
    this.filterByTeam,
    this.filterByStatus,
    this.filterByMonth,
    this.filterByBillStatus,
  });

  @override
  State<TaskManagementPage> createState() => _TaskManagementPageState();
}

class _TaskManagementPageState extends State<TaskManagementPage> {
  List<Task> _tasks = [];
  String _currentFilter = '';
  String? _statusFilter;
  String? _monthFilter;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      var query =
          Supabase.instance.client.from('jobtasks').select().eq('Active', true);

      // Apply filters from URL parameters
      if (widget.filterByTeam != null) {
        query = query.eq('AssignedTo', widget.filterByTeam!);
      }
      if (widget.filterByStatus != null) {
        if (widget.filterByStatus == 'Overdue') {
          query = query
              .lt('DueDate', DateTime.now().toIso8601String())
              .neq('TaskStatus', 'Completed');
        } else {
          query = query.eq('TaskStatus', widget.filterByStatus!);
        }
      }
      if (widget.filterByMonth != null) {
        final [year, month] = widget.filterByMonth!.split('-');
        final startDate = DateTime(int.parse(year), int.parse(month), 1);
        final endDate = DateTime(int.parse(year), int.parse(month) + 1, 0);
        query = query
            .gte('DueDate', startDate.toIso8601String())
            .lte('DueDate', endDate.toIso8601String());
      }
      if (widget.filterByBillStatus != null) {
        query = query
            .not('BillStatus', 'is', null)
            .not('BillStatus', 'eq', '')
            .or('PaymentReceiptStatus.is.null');
      }

      final response = await query;

      setState(() {
        _tasks = response.map<Task>((json) => Task.fromJson(json)).toList();
        _currentFilter = widget.filterByTeam ?? '';
        _statusFilter = widget.filterByStatus;
        _monthFilter = widget.filterByMonth;
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

  Future<void> _addTask(Task task) async {
    try {
      if (task.id == null) {
        // Insert new task
        final response = await Supabase.instance.client
            .from('jobtasks')
            .insert(task.toJsonForInsert())
            .select()
            .single();

        final newTask = Task.fromJson(response);
        setState(() {
          _tasks.add(newTask);
        });
      } else {
        // Update existing task
        await Supabase.instance.client
            .from('jobtasks')
            .update(task.toJson())
            .eq('id', task.id!);

        setState(() {
          final index = _tasks.indexWhere((t) => t.id == task.id);
          if (index != -1) {
            _tasks[index] = task;
          }
        });
      }

      // Refresh tasks list
      await _loadTasks();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(task.id == null
                ? 'Task added successfully'
                : 'Task updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Error ${task.id == null ? 'adding' : 'updating'} task: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateTask(Task task) async {
    try {
      if (task.id == null) return;

      final taskData = task.toJson();
      taskData.remove('id');

      await Supabase.instance.client
          .from('jobtasks')
          .update(taskData)
          .eq('id', task.id!);

      await _loadTasks();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating task: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = 'Task Management';
    if (_currentFilter.isNotEmpty) {
      title = 'Tasks - $_currentFilter';
    } else if (_statusFilter != null) {
      title = 'Tasks - $_statusFilter';
    } else if (_monthFilter != null) {
      title = 'Tasks - $_monthFilter';
    } else if (widget.filterByBillStatus != null) {
      title = 'Tasks - Pending Bills';
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: title,
        showBackButton: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TaskTable(
              tasks: _tasks,
              onTaskUpdated: _updateTask,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => TaskForm(
              onTaskAdded: (task) async {
                await _addTask(task);
                if (mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
