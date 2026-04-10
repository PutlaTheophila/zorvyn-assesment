import 'package:equatable/equatable.dart';
import '../../models/goal.dart';

abstract class GoalState extends Equatable {
  const GoalState();

  @override
  List<Object?> get props => [];
}

class GoalInitial extends GoalState {
  const GoalInitial();
}

class GoalLoading extends GoalState {
  const GoalLoading();
}

class GoalLoaded extends GoalState {
  final List<Goal> goals;
  final Goal? activeGoal;

  const GoalLoaded({
    required this.goals,
    this.activeGoal,
  });

  @override
  List<Object?> get props => [goals, activeGoal];

  GoalLoaded copyWith({
    List<Goal>? goals,
    Goal? activeGoal,
  }) {
    return GoalLoaded(
      goals: goals ?? this.goals,
      activeGoal: activeGoal ?? this.activeGoal,
    );
  }
}

class GoalError extends GoalState {
  final String message;

  const GoalError(this.message);

  @override
  List<Object?> get props => [message];
}
