import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';

class TaskForm {
  final String id;
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();

  TaskForm(this.id);
}

class MaintenanceTaskFormSection extends StatelessWidget {
  final List<TaskForm> tasks;
  final VoidCallback onAddTask;
  final void Function(TaskForm task) onDeleteTask;

  const MaintenanceTaskFormSection({
    super.key,
    required this.tasks,
    required this.onAddTask,
    required this.onDeleteTask,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: MyColors.background),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ...tasks.map(_buildTaskItem),
          TextButton.icon(
            onPressed: onAddTask,
            icon: const Icon(Icons.add, color: MyColors.secondary),
            label: const Text(
              "Tambah Jenis Perawatan Lain",
              style: TextStyle(color: MyColors.secondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(TaskForm task) {
    final isOnlyOne = tasks.length == 1;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Jenis Perawatan",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              if (!isOnlyOne)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => onDeleteTask(task),
                ),
            ],
          ),

          const SizedBox(height: 8),
          TextFormField(
            controller: task.titleCtrl,
            decoration: const InputDecoration(
              hintText: 'Judul',
              border: OutlineInputBorder(),
            ),
            validator: (v) =>
                v == null || v.isEmpty ? 'Judul wajib diisi' : null,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: task.descCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Deskripsi',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
