import 'package:equatable/equatable.dart';

class Goal extends Equatable {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadline;
  final DateTime createdAt;
  final bool isCompleted;

  const Goal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    required this.createdAt,
    this.isCompleted = false,
  });

  double get progress {
    if (targetAmount == 0) return 0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  double get progressPercentage => progress * 100;

  int get daysRemaining {
    final now = DateTime.now();
    return deadline.difference(now).inDays;
  }

  bool get isOverdue => daysRemaining < 0 && !isCompleted;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'deadline': deadline.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'is_completed': isCompleted ? 1 : 0,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'] as String,
      name: map['name'] as String,
      targetAmount: map['target_amount'] as double,
      currentAmount: map['current_amount'] as double,
      deadline: DateTime.parse(map['deadline'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      isCompleted: map['is_completed'] == 1,
    );
  }

  Goal copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadline,
    DateTime? createdAt,
    bool? isCompleted,
  }) {
    return Goal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        targetAmount,
        currentAmount,
        deadline,
        createdAt,
        isCompleted,
      ];
}
