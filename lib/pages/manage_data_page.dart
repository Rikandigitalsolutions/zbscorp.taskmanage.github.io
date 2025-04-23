import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/app_bar.dart';
import '../widgets/data_form_dialog.dart';
import '../models/work_category.dart';
import '../models/employee.dart';
import '../models/client.dart';
import '../models/billing_firm.dart';

class ManageDataPage extends StatefulWidget {
  const ManageDataPage({super.key});

  @override
  State<ManageDataPage> createState() => _ManageDataPageState();
}

class _ManageDataPageState extends State<ManageDataPage> {
  List<WorkCategory> _workCategories = [];
  List<Employee> _employees = [];
  List<Client> _clients = [];
  List<BillingFirm> _billingFirms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final categories =
          await Supabase.instance.client.from('work_category').select();

      final billingFirms =
          await Supabase.instance.client.from('billing_firm').select();
      print(billingFirms);

      final employees =
          await Supabase.instance.client.from('employees').select();

      final clients = await Supabase.instance.client.from('clients').select();

      final jobtask = await Supabase.instance.client.from('jobtasks').select();

      setState(() {
        _workCategories = categories
            .map<WorkCategory>((json) => WorkCategory.fromJson(json))
            .toList();
        print(_workCategories);
        _billingFirms = billingFirms
            .map<BillingFirm>((json) => BillingFirm.fromJson(json))
            .toList();
        print(_billingFirms);
        _employees =
            employees.map<Employee>((json) => Employee.fromJson(json)).toList();
        print(_employees);
        _clients =
            clients.map<Client>((json) => Client.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showFormDialog({
    required String title,
    required Map<String, dynamic> initialData,
    required String tableName,
    required List<Map<String, dynamic>> fields,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => DataFormDialog(
        title: title,
        initialData: initialData,
        tableName: tableName,
        fields: fields,
        onDataChanged: _loadData,
      ),
    );

    if (result == true) {
      await _loadData();
    }
  }

  Future<void> _deleteItem(String tableName, int id) async {
    try {
      await Supabase.instance.client.from(tableName).delete().eq('id', id);
      await _loadData();
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
      appBar: const CustomAppBar(
        title: 'Manage Data',
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.8, // Decreased from 1.5 to make tiles taller
          children: [
            _buildWorkCategoryTile(),
            _buildEmployeesTile(),
            _buildClientsTile(),
            _buildBillingFirmsTile(),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkCategoryTile() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Work Categories',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _workCategories.length,
                      itemBuilder: (context, index) {
                        final category = _workCategories[index];
                        return ListTile(
                          title: Text(category.category),
                          subtitle: Text(
                            'Created: ${category.createdAt.toString().split(' ')[0]}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _showFormDialog(
                                    title: 'Edit Work Category',
                                    initialData: {
                                      'id': category.id,
                                      'category': category.category,
                                    },
                                    tableName: 'work_category',
                                    fields: [
                                      {
                                        'name': 'category',
                                        'label': 'Category Name',
                                        'required': true,
                                      },
                                    ],
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  _deleteItem('work_category', category.id);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                _showFormDialog(
                  title: 'Add Work Category',
                  initialData: {},
                  tableName: 'work_category',
                  fields: [
                    {
                      'name': 'category',
                      'label': 'Category Name',
                      'required': true,
                    },
                  ],
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Category'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeesTile() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Employees',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _employees.length,
                      itemBuilder: (context, index) {
                        final employee = _employees[index];
                        return ListTile(
                          title: Text(employee.employeeName),
                          subtitle: Text(
                            'Status: ${employee.active ? 'Active' : 'Inactive'}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _showFormDialog(
                                    title: 'Edit Employee',
                                    initialData: {
                                      'id': employee.id,
                                      'employee_name': employee.employeeName,
                                      'active': employee.active,
                                    },
                                    tableName: 'employees',
                                    fields: [
                                      {
                                        'name': 'employee_name',
                                        'label': 'Employee Name',
                                        'required': true,
                                      },
                                      {
                                        'name': 'active',
                                        'label': 'Active',
                                        'required': true,
                                      },
                                    ],
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  _deleteItem('employees', employee.id);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                _showFormDialog(
                  title: 'Add Employee',
                  initialData: {'active': true},
                  tableName: 'employees',
                  fields: [
                    {
                      'name': 'employee_name',
                      'label': 'Employee Name',
                      'required': true,
                    },
                    {
                      'name': 'active',
                      'label': 'Active',
                      'required': true,
                    },
                  ],
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Employee'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientsTile() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Clients',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _clients.length,
                      itemBuilder: (context, index) {
                        final client = _clients[index];
                        return ListTile(
                          title: Text(client.clientName),
                          subtitle: Text(
                            'Created: ${client.createdAt.toString().split(' ')[0]}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _showFormDialog(
                                    title: 'Edit Client',
                                    initialData: {
                                      'id': client.id,
                                      'client_name': client.clientName,
                                    },
                                    tableName: 'clients',
                                    fields: [
                                      {
                                        'name': 'client_name',
                                        'label': 'Client Name',
                                        'required': true,
                                      },
                                    ],
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  _deleteItem('clients', client.id);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                _showFormDialog(
                  title: 'Add Client',
                  initialData: {},
                  tableName: 'clients',
                  fields: [
                    {
                      'name': 'client_name',
                      'label': 'Client Name',
                      'required': true,
                    },
                  ],
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Client'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingFirmsTile() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Billing Firms',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _billingFirms.length,
                      itemBuilder: (context, index) {
                        final firm = _billingFirms[index];
                        return ListTile(
                          title: Text(firm.billingFirm),
                          subtitle: Text(
                            'Created: ${firm.createdAt.toString().split(' ')[0]}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _showFormDialog(
                                    title: 'Edit Billing Firm',
                                    initialData: {
                                      'id': firm.id,
                                      'billing_firm': firm.billingFirm,
                                    },
                                    tableName: 'billing_firms',
                                    fields: [
                                      {
                                        'name': 'billing_firm',
                                        'label': 'Billing Firm Name',
                                        'required': true,
                                      },
                                    ],
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  _deleteItem('billing_firms', firm.id);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                _showFormDialog(
                  title: 'Add Billing Firm',
                  initialData: {},
                  tableName: 'billing_firms',
                  fields: [
                    {
                      'name': 'billing_firm',
                      'label': 'Billing Firm Name',
                      'required': true,
                    },
                  ],
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Firm'),
            ),
          ],
        ),
      ),
    );
  }
}
