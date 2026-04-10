import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../blocs/goal/goal_bloc.dart';
import '../../blocs/goal/goal_event.dart';
import '../../models/goal.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/date_helper.dart';

class CreateGoalScreen extends StatefulWidget {
  const CreateGoalScreen({super.key});

  @override
  State<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends State<CreateGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetAmountController = TextEditingController();
  DateTime _selectedDeadline = DateTime.now().add(const Duration(days: 30));
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  Future<void> _selectDeadline(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.income,
              onPrimary: Colors.white,
              surface: Color(0xFF1A1A1A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDeadline) {
      setState(() {
        _selectedDeadline = picked;
      });
    }
  }

  void _saveGoal() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final goal = Goal(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        targetAmount: double.parse(_targetAmountController.text),
        currentAmount: 0,
        deadline: _selectedDeadline,
        createdAt: DateTime.now(),
      );

      context.read<GoalBloc>().add(CreateGoal(goal));
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Goal created successfully'),
          backgroundColor: Color(0xFF4ADE80),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adaptiveBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.adaptiveBackground(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, size: 24, color: AppColors.adaptiveText(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create New Goal',
          style: TextStyle(
            color: AppColors.adaptiveText(context),
            fontWeight: FontWeight.w700,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  const SizedBox(height: 20),
                  // Visual header with Lottie
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.income.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Lottie.asset(
                        'assets/lotties/Budget Tracker.json',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Large Amount Input
                  _buildAmountInput(),
                  
                  const SizedBox(height: 48),
                  
                  // Goal Name Field
                  Text(
                    'Goal Name',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.adaptiveText(context).withValues(alpha: 0.8),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildGoalNameInput(),
                  
                  const SizedBox(height: 24),
                  
                  // Deadline Selection Card
                  _buildInfoCard(
                    icon: Icons.calendar_today_outlined,
                    label: 'Target Date',
                    value: DateHelper.formatDate(_selectedDeadline),
                    onTap: () => _selectDeadline(context),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
            _buildStickyButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Column(
      children: [
        TextFormField(
          controller: _targetAmountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.center,
          autofocus: true,
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w800,
            color: AppColors.adaptiveText(context),
            letterSpacing: -1,
          ),
          decoration: InputDecoration(
            hintText: '0.00',
            hintStyle: TextStyle(
              color: AppColors.adaptiveSecondaryText(context).withValues(alpha: 0.5),
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SvgPicture.asset(
                'assets/svg/dollar-svgrepo-com.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  AppColors.adaptiveText(context),
                  BlendMode.srcIn,
                ),
              ),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
          validator: Validators.validateAmount,
        ),
        Text(
          'Target Savings Amount',
          style: TextStyle(
            color: AppColors.adaptiveSecondaryText(context),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalNameInput() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        hintText: 'e.g., Summer Vacation, New Car...',
        hintStyle: TextStyle(
          color: AppColors.adaptiveSecondaryText(context).withValues(alpha: 0.5),
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: AppColors.adaptiveFieldBackground(context),
        prefixIcon: Icon(Icons.flag_outlined, color: AppColors.adaptiveSecondaryText(context)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.adaptiveText(context),
            width: 1,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      ),
      validator: Validators.validateGoalName,
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.adaptiveCard(context).withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.adaptiveDivider(context).withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.adaptiveBackground(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: AppColors.adaptiveText(context)),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.adaptiveSecondaryText(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.adaptiveText(context),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: AppColors.adaptiveSecondaryText(context).withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyButton() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        decoration: BoxDecoration(
          color: AppColors.adaptiveBackground(context),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveGoal,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.adaptiveText(context),
              foregroundColor: AppColors.adaptiveBackground(context),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                  )
                : const Text(
                    'Create Savings Goal',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
          ),
        ),
      ),
    );
  }
}
