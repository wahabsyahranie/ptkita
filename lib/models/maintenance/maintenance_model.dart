// lib/models/maintenance_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Maintenance {
  final String id;
  final String itemId;
  final String itemName;
  final String? sku;
  final Timestamp? nextMaintenanceAt;
  final Timestamp? lastMaintenanceAt;
  final int intervalDays;
  final String priority;
  final List<MaintenanceTask> tasks;

  Maintenance({
    required this.id,
    required this.itemId,
    required this.itemName,
    this.sku,
    this.nextMaintenanceAt,
    this.lastMaintenanceAt,
    required this.intervalDays,
    required this.priority,
    required this.tasks,
  });

  factory Maintenance.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? opts,
  ) {
    final data = doc.data() ?? {};

    final rawItemId = data['itemId'];
    final itemIdStr = rawItemId is DocumentReference
        ? rawItemId.id
        : rawItemId?.toString() ?? '';

    final tasks = (data['tasks'] as List<dynamic>? ?? [])
        .map((e) => MaintenanceTask.fromMap(e as Map<String, dynamic>))
        .toList();

    return Maintenance(
      id: doc.id,
      itemId: itemIdStr,
      itemName: data['itemName'] ?? '',
      sku: data['sku'],
      nextMaintenanceAt: data['nextMaintenanceAt'],
      lastMaintenanceAt: data['lastMaintenanceAt'],
      intervalDays: (data['intervalDays'] as num?)?.toInt() ?? 0,
      priority: data['priority'] ?? 'rendah',
      tasks: tasks,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'itemId': itemId,
    'itemName': itemName,
    'sku': sku,
    'nextMaintenanceAt': nextMaintenanceAt,
    'lastMaintenanceAt': lastMaintenanceAt,
    'intervalDays': intervalDays,
    'priority': priority,
    'tasks': tasks.map((e) => e.toMap()).toList(),
  };

  Maintenance copyWith({
    String? id,
    String? itemId,
    String? itemName,
    String? sku,
    int? intervalDays,
    String? priority,
    Timestamp? lastMaintenanceAt,
    Timestamp? nextMaintenanceAt,
    List<MaintenanceTask>? tasks,
  }) {
    return Maintenance(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      sku: sku ?? this.sku,
      intervalDays: intervalDays ?? this.intervalDays,
      priority: priority ?? this.priority,
      lastMaintenanceAt: lastMaintenanceAt ?? this.lastMaintenanceAt,
      nextMaintenanceAt: nextMaintenanceAt ?? this.nextMaintenanceAt,
      tasks: tasks ?? this.tasks,
    );
  }
}

class MaintenanceTask {
  final String id;
  final String title;
  final String description;
  final bool completed;

  MaintenanceTask({
    required this.id,
    required this.title,
    required this.description,
    required this.completed,
  });

  factory MaintenanceTask.fromMap(Map<String, dynamic> map) {
    return MaintenanceTask(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      completed: map['completed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'completed': completed,
  };

  /// 🔑 INI YANG KAMU PAKAI DI PAGE
  MaintenanceTask copyWith({
    String? id,
    String? title,
    String? description,
    bool? completed,
  }) {
    return MaintenanceTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
    );
  }
}

class MaintenanceDetail {
  final Maintenance maintenance;
  final String? imageUrl;

  MaintenanceDetail({required this.maintenance, required this.imageUrl});
}
