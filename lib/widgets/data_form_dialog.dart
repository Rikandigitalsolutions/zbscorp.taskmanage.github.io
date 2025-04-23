import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DataFormDialog extends StatefulWidget {
  final String title;
  final Map<String, dynamic> initialData;
  final String tableName;
  final List<Map<String, dynamic>> fields;
  final Function() onDataChanged;

  const DataFormDialog({
    super.key,
    required this.title,
    required this.initialData,
    required this.tableName,
    required this.fields,
    required this.onDataChanged,
  });

  @override
  State<DataFormDialog> createState() => _DataFormDialogState();
}

class _DataFormDialogState extends State<DataFormDialog> {
  final formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> controllers = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with initial data
    for (var field in widget.fields) {
      controllers[field['name']] = TextEditingController(
        text: widget.initialData[field['name']]?.toString() ?? '',
      );
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final Map<String, dynamic> data = {};
    for (var field in widget.fields) {
      data[field['name']] = controllers[field['name']]!.text;
    }

    try {
      if (widget.initialData['id'] == null) {
        // Insert new record
        await Supabase.instance.client.from(widget.tableName).insert(data);
      } else {
        // Update existing record
        await Supabase.instance.client
            .from(widget.tableName)
            .update(data)
            .eq('id', widget.initialData['id']);
      }

      if (mounted) {
        widget.onDataChanged(); // Refresh the data
        Navigator.pop(context, true);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.fields.map((field) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: controllers[field['name']],
                  decoration: InputDecoration(
                    labelText: field['label'],
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (field['required'] == true &&
                        (value == null || value.isEmpty)) {
                      return 'This field is required';
                    }
                    return null;
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleSave,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
