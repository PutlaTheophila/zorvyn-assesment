import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/goal/goal_bloc.dart';
import '../../blocs/goal/goal_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import 'widgets/goal_card.dart';
import 'create_goal_screen.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adaptiveBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.adaptiveBackground(context),
        elevation: 0,
        title: Text(
          'Goals',
          style: TextStyle(
            color: AppColors.adaptiveText(context),
            fontWeight: FontWeight.w700,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateGoalScreen(),
                ),
              );
            },
            icon: Icon(Icons.add_rounded, color: AppColors.adaptiveText(context)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<GoalBloc, GoalState>(
        builder: (context, state) {
          if (state is GoalLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is GoalError) {
            return Center(
              child: Text('Error: ${state.message}'),
            );
          }

          if (state is GoalLoaded) {
            if (state.goals.isEmpty) {
              return EmptyState(
                icon: Icons.flag,
                title: 'No goals set',
                description:
                    'Set your first savings goal to start your financial journey',
                lottiePath: 'assets/lotties/Budget Tracker.json',
                svgPath: 'assets/svg/target-marketing-goal-svgrepo-com.svg',
                actionText: 'Create Goal',
                onActionPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateGoalScreen(),
                    ),
                  );
                },
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: state.goals.length,
              itemBuilder: (context, index) {
                final goal = state.goals[index];
                return GoalCard(
                  goal: goal,
                  onTap: () {
                    // TODO: Navigate to goal details
                  },
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
