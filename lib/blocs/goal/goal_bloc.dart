import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/database_service.dart';
import 'goal_event.dart';
import 'goal_state.dart';

class GoalBloc extends Bloc<GoalEvent, GoalState> {
  final DatabaseService _databaseService;

  GoalBloc({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService.instance,
        super(const GoalInitial()) {
    on<LoadGoals>(_onLoadGoals);
    on<CreateGoal>(_onCreateGoal);
    on<UpdateGoal>(_onUpdateGoal);
    on<UpdateGoalProgress>(_onUpdateGoalProgress);
    on<DeleteGoal>(_onDeleteGoal);
  }

  Future<void> _onLoadGoals(
    LoadGoals event,
    Emitter<GoalState> emit,
  ) async {
    emit(const GoalLoading());
    try {
      final goals = await _databaseService.getGoals();
      final activeGoal = await _databaseService.getActiveGoal();
      emit(GoalLoaded(goals: goals, activeGoal: activeGoal));
    } catch (e) {
      emit(GoalError(e.toString()));
    }
  }

  Future<void> _onCreateGoal(
    CreateGoal event,
    Emitter<GoalState> emit,
  ) async {
    try {
      await _databaseService.insertGoal(event.goal);
      add(const LoadGoals());
    } catch (e) {
      emit(GoalError(e.toString()));
    }
  }

  Future<void> _onUpdateGoal(
    UpdateGoal event,
    Emitter<GoalState> emit,
  ) async {
    try {
      await _databaseService.updateGoal(event.goal);
      add(const LoadGoals());
    } catch (e) {
      emit(GoalError(e.toString()));
    }
  }

  Future<void> _onUpdateGoalProgress(
    UpdateGoalProgress event,
    Emitter<GoalState> emit,
  ) async {
    try {
      final activeGoal = await _databaseService.getActiveGoal();
      if (activeGoal != null) {
        final updatedGoal = activeGoal.copyWith(
          currentAmount: activeGoal.currentAmount + event.amount,
        );
        await _databaseService.updateGoal(updatedGoal);
        add(const LoadGoals());
      }
    } catch (e) {
      emit(GoalError(e.toString()));
    }
  }

  Future<void> _onDeleteGoal(
    DeleteGoal event,
    Emitter<GoalState> emit,
  ) async {
    try {
      await _databaseService.deleteGoal(event.id);
      add(const LoadGoals());
    } catch (e) {
      emit(GoalError(e.toString()));
    }
  }
}
