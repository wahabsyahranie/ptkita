// lib/models/maintenance_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kita/models/inventory/item_model.dart';

class Maintenance {
  final String id;
  final String itemId;
  final String itemName;
  final String? typeUnit;
  final Timestamp? nextMaintenanceAt;
  final Timestamp? lastMaintenanceAt;
  final int intervalDays;
  final String priority;
  final List<MaintenanceTask> tasks;
  final int cycleInitialQuantity;
  final int remainingQuantity;

  Maintenance({
    required this.id,
    required this.itemId,
    required this.itemName,
    this.typeUnit,
    this.nextMaintenanceAt,
    this.lastMaintenanceAt,
    required this.intervalDays,
    required this.priority,
    required this.tasks,
    this.cycleInitialQuantity = 0,
    this.remainingQuantity = 0,
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
      typeUnit: data['typeUnit'],
      nextMaintenanceAt: data['nextMaintenanceAt'],
      lastMaintenanceAt: data['lastMaintenanceAt'],
      intervalDays: (data['intervalDays'] as num?)?.toInt() ?? 0,
      priority: data['priority'] ?? 'rendah',
      tasks: tasks,
      cycleInitialQuantity:
          (data['cycleInitialQuantity'] as num?)?.toInt() ?? 0,
      remainingQuantity: (data['remainingQuantity'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'itemId': itemId,
    'itemName': itemName,
    'typeUnit': typeUnit,
    'nextMaintenanceAt': nextMaintenanceAt,
    'lastMaintenanceAt': lastMaintenanceAt,
    'intervalDays': intervalDays,
    'priority': priority,
    'tasks': tasks.map((e) => e.toMap()).toList(),
    'cycleInitialQuantity': cycleInitialQuantity,
    'remainingQuantity': remainingQuantity,
  };

  Maintenance copyWith({
    String? id,
    String? itemId,
    String? itemName,
    String? typeUnit,
    int? intervalDays,
    String? priority,
    Timestamp? lastMaintenanceAt,
    Timestamp? nextMaintenanceAt,
    List<MaintenanceTask>? tasks,
    int? cycleInitialQuantity,
    int? remainingQuantity,
  }) {
    return Maintenance(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      typeUnit: typeUnit ?? this.typeUnit,
      intervalDays: intervalDays ?? this.intervalDays,
      priority: priority ?? this.priority,
      lastMaintenanceAt: lastMaintenanceAt ?? this.lastMaintenanceAt,
      nextMaintenanceAt: nextMaintenanceAt ?? this.nextMaintenanceAt,
      tasks: tasks ?? this.tasks,
      cycleInitialQuantity: cycleInitialQuantity ?? this.cycleInitialQuantity,
      remainingQuantity: remainingQuantity ?? this.remainingQuantity,
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
  final Item? item;

  MaintenanceDetail({required this.maintenance, required this.item});
}

class MaintenanceDetailView {
  final Maintenance maintenance;
  final ImageProvider imageProvider;

  final int initialQuantity;
  final int remainingQuantity;
  final int completedQuantity;
  final double progress;

  MaintenanceDetailView({
    required this.maintenance,
    required this.imageProvider,
    required this.initialQuantity,
    required this.remainingQuantity,
    required this.completedQuantity,
    required this.progress,
  });
}
