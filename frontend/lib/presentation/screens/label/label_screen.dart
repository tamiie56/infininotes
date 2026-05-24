import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/label_provider.dart';

class LabelScreen extends StatefulWidget {
  const LabelScreen({super.key});

  @override
  State<LabelScreen> createState() => _LabelScreenState();
}

class _LabelScreenState extends State<LabelScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LabelProvider>().fetchLabels();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showAddLabel() {
    _controller.clear();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Create label'),
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(hintText: 'Label name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (_controller.text.trim().isNotEmpty) {
                await context.read<LabelProvider>().createLabel(_controller.text.trim());
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditLabel(String id, String currentName) {
    _controller.text = currentName;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit label'),
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(hintText: 'Label name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (_controller.text.trim().isNotEmpty) {
                await context.read<LabelProvider>().updateLabel(id, _controller.text.trim());
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final labelProvider = context.watch<LabelProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Edit labels')),
      body: labelProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : labelProvider.labels.isEmpty
              ? const Center(child: Text('No labels yet', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  itemCount: labelProvider.labels.length,
                  itemBuilder: (_, i) {
                    final label = labelProvider.labels[i];
                    return ListTile(
                      leading: const Icon(Icons.label_outlined),
                      title: Text(label.name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _showEditLabel(label.id, label.name),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outlined),
                            onPressed: () async {
                              await context.read<LabelProvider>().deleteLabel(label.id);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLabel,
        child: const Icon(Icons.add),
      ),
    );
  }
}