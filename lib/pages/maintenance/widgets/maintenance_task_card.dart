import 'package:flutter/material.dart';
import 'package:flutter_kita/models/maintenance/maintenance_model.dart';
import 'package:flutter_kita/styles/colors.dart';

class MaintenanceTaskCard extends StatelessWidget {
  final MaintenanceTask task;
  final bool checked;
  final int index;
  final VoidCallback onTap;

  const MaintenanceTaskCard({
    super.key,
    required this.task,
    required this.checked,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: checked ? _completeCard() : _pendingCard(),
    );
  }

  Widget _completeCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: MyColors.success, width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _checkIcon(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _titleRow(task.title, 'Selesai', MyColors.success),
                const SizedBox(height: 8),
                Text(
                  task.description,
                  style: const TextStyle(color: MyColors.success),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pendingCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: MyColors.secondary, width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _circleIndex(index + 1, MyColors.secondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _titleRow(task.title, 'Tandai', MyColors.secondary),
                const SizedBox(height: 8),
                Text(task.description),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: MyColors.success,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check, color: MyColors.white),
    );
  }

  Widget _circleIndex(int index, Color color) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Text(
        '$index',
        style: TextStyle(fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _titleRow(String title, String status, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          status,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
