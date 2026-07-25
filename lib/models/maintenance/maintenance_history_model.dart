import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/enum/maintenance_history_status.dart';

class MaintenanceHistory {
  final String id;
  final String maintenanceId;
  final int cycleNumber;
  final String itemId;
  final String itemName;
  final String? partNumber;
  final int intervalDays;
  final String priority;
  final Timestamp? scheduledAt;
  final Timestamp completedAt;
  final MaintenanceHistoryStatus status;
  final int completedQuantity;
  final int cycleInitialQuantity;
  final String userId;
  final String userName;
  final Timestamp? createdAt;

  const MaintenanceHistory({
    required this.id,
    required this.maintenanceId,
    required this.cycleNumber,
    required this.itemId,
    required this.itemName,
    this.partNumber,
    required this.intervalDays,
    required this.priority,
    this.scheduledAt,
    required this.completedAt,
    required this.status,
    required this.completedQuantity,
    required this.cycleInitialQuantity,
    required this.userId,
    required this.userName,
    this.createdAt,
  });

  static MaintenanceHistory fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? options,
  ) {
    final data = doc.data()!;

    return MaintenanceHistory(
      id: doc.id,
      maintenanceId: data['maintenanceId'] ?? '',
      cycleNumber: (data['cycleNumber'] as num?)?.toInt() ?? 1,
      itemId: data['itemId'] ?? '',
      itemName: data['itemName'] ?? '',
      partNumber: data['partNumber'],
      intervalDays: (data['intervalDays'] as num?)?.toInt() ?? 0,
      priority: data['priority'] ?? '',
      scheduledAt: data['scheduledAt'],
      completedAt: data['completedAt'] as Timestamp,
      status: MaintenanceHistoryStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => MaintenanceHistoryStatus.completed,
      ),
      completedQuantity: (data['completedQuantity'] as num?)?.toInt() ?? 0,
      cycleInitialQuantity:
          (data['cycleInitialQuantity'] as num?)?.toInt() ?? 0,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      createdAt: data['createdAt'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'maintenanceId': maintenanceId,
      'cycleNumber': cycleNumber,
      'itemId': itemId,
      'itemName': itemName,
      'partNumber': partNumber,
      'intervalDays': intervalDays,
      'priority': priority,
      'scheduledAt': scheduledAt,
      'completedAt': completedAt,
      'status': status.name,
      'completedQuantity': completedQuantity,
      'cycleInitialQuantity': cycleInitialQuantity,
      'userId': userId,
      'userName': userName,
      'createdAt': createdAt,
    };
  }

  MaintenanceHistory copyWith({
    String? id,
    String? maintenanceId,
    int? cycleNumber,
    String? itemId,
    String? itemName,
    String? partNumber,
    String? priority,
    int? intervalDays,
    Timestamp? scheduledAt,
    Timestamp? completedAt,
    MaintenanceHistoryStatus? status,
    int? completedQuantity,
    int? cycleInitialQuantity,
    String? userId,
    String? userName,
    Timestamp? createdAt,
  }) {
    return MaintenanceHistory(
      id: id ?? this.id,
      maintenanceId: maintenanceId ?? this.maintenanceId,
      cycleNumber: cycleNumber ?? this.cycleNumber,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      partNumber: partNumber ?? this.partNumber,
      intervalDays: intervalDays ?? this.intervalDays,
      priority: priority ?? this.priority,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      completedQuantity: completedQuantity ?? this.completedQuantity,
      cycleInitialQuantity: cycleInitialQuantity ?? this.cycleInitialQuantity,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
