import 'package:equatable/equatable.dart';
import '../../models/goal.dart';

abstract class GoalEvent extends Equatable {
  const GoalEvent();

  @override
  List<Object?> get props => [];
}

class LoadGoals extends GoalEvent {
  const LoadGoals();
}

class CreateGoal extends GoalEvent {
  final Goal goal;

  const CreateGoal(this.goal);

  @override
  List<Object?> get props => [goal];
}

class UpdateGoal extends GoalEvent {
  final Goal goal;

  const UpdateGoal(this.goal);

  @override
  List<Object?> get props => [goal];
}

class UpdateGoalProgress extends GoalEvent {
  final double amount;

  const UpdateGoalProgress(this.amount);

  @override
  List<Object?> get props => [amount];
}

class DeleteGoal extends GoalEvent {
  final String id;

  const DeleteGoal(this.id);

  @override
  List<Object?> get props => [id];
}
