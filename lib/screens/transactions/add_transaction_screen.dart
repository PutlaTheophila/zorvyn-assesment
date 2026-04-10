import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../blocs/transaction/transaction_event.dart';
import '../../models/transaction.dart' as model;
import '../../models/category.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/date_helper.dart';
import '../../services/database_service.dart';

class AddTransactionScreen extends StatefulWidget {
  final model.Transaction? transaction;

  const AddTransactionScreen({
    super.key,
    this.transaction,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  model.TransactionType _type = model.TransactionType.expense;
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  List<Category> _categories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();

    if (widget.transaction != null) {
      _amountController.text = widget.transaction!.amount.toString();
      _descriptionController.text = widget.transaction!.description ?? '';
      _type = widget.transaction!.type;
      _selectedCategory = widget.transaction!.category;
      _selectedDate = widget.transaction!.date;
    }
  }

  Future<void> _loadCategories() async {
    final categories = await DatabaseService.instance.getCategories(type: _type);
    setState(() {
      _categories = categories;
      if (_selectedCategory == null && categories.isNotEmpty) {
        _selectedCategory = categories.first.name;
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.darkText,
              onPrimary: Colors.white,
              onSurface: AppColors.darkText,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final transaction = model.Transaction(
        id: widget.transaction?.id ?? const Uuid().v4(),
        amount: double.parse(_amountController.text),
        type: _type,
        category: _selectedCategory!,
        date: _selectedDate,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        createdAt: widget.transaction?.createdAt ?? DateTime.now(),
      );

      if (widget.transaction == null) {
        context.read<TransactionBloc>().add(AddTransaction(transaction));
      } else {
        context.read<TransactionBloc>().add(UpdateTransaction(transaction));
      }

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.transaction == null
                ? 'Transaction added successfully'
                : 'Transaction updated successfully',
          ),
          backgroundColor: AppColors.income,
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
          widget.transaction == null ? 'Add Transaction' : 'Edit Transaction',
          style: TextStyle(
            color: AppColors.adaptiveText(context),
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  const SizedBox(height: 12),
                  _buildTypeToggle(),
                  const SizedBox(height: 40),
                  _buildAmountInput(),
                  const SizedBox(height: 48),
                  Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.adaptiveText(context).withValues(alpha: 0.8),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryGrid(),
                  const SizedBox(height: 32),
                  _buildInfoCard(
                    icon: Icons.calendar_today_outlined,
                    label: 'Date',
                    value: DateHelper.formatDate(_selectedDate),
                    onTap: () => _selectDate(context),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.notes_rounded,
                    label: 'Description',
                    value: _descriptionController.text.isEmpty
                        ? 'Add a note...'
                        : _descriptionController.text,
                    onTap: () => _showDescriptionDialog(),
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

  Widget _buildTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.adaptiveFieldBackground(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _toggleItem('Expense', model.TransactionType.expense),
          _toggleItem('Income', model.TransactionType.income),
        ],
      ),
    );
  }

  Widget _toggleItem(String label, model.TransactionType type) {
    final isSelected = _type == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _type = type;
            _selectedCategory = null;
            _loadCategories();
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.adaptiveCard(context) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.adaptiveText(context) : AppColors.adaptiveSecondaryText(context),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Column(
      children: [
        TextFormField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.center,
          autofocus: true,
          style: TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.w800,
            color: AppColors.adaptiveText(context),
            letterSpacing: -1,
          ),
          decoration: InputDecoration(
            hintText: '0.00',
            hintStyle: TextStyle(
              color: AppColors.adaptiveSecondaryText(context).withValues(alpha: 0.5),
              fontSize: 40,
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
        if (_amountController.text.isEmpty)
          const Text(
            'Enter amount',
            style: TextStyle(
              color: AppColors.greyText,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  String _getCategoryLottie(String category) {
    category = category.toLowerCase();
    if (category.contains('food') || category.contains('dining')) {
      return 'assets/lotties/Food Carousel.json';
    } else if (category.contains('shopping')) {
      return 'assets/lotties/shopping cart.json';
    } else if (category.contains('transport') || category.contains('car')) {
      return 'assets/lotties/Red Car Drive.json';
    } else if (category.contains('entertainment') || category.contains('movie')) {
      return 'assets/lotties/Watch a movie with popcorn.json';
    } else if (category.contains('grocery')) {
      return 'assets/lotties/Grocery Lottie JSON animation.json';
    }
    return '';
  }

  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        final isSelected = _selectedCategory == category.name;
        final lottiePath = _getCategoryLottie(category.name);

        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = category.name),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isSelected ? category.color : AppColors.adaptiveFieldBackground(context),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: category.color.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [],
                ),
                child: lottiePath.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Lottie.asset(lottiePath, fit: BoxFit.contain, animate: isSelected),
                      )
                    : Icon(
                        category.icon,
                        color: isSelected ? AppColors.adaptiveBackground(context) : AppColors.adaptiveSecondaryText(context),
                        size: 24,
                      ),
              ),
              const SizedBox(height: 8),
              Text(
                category.name,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.adaptiveText(context) : AppColors.adaptiveSecondaryText(context),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
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
          color: AppColors.adaptiveBackground(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.adaptiveDivider(context)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.adaptiveCard(context),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                  )
                ],
              ),
              child: Icon(icon, size: 20, color: AppColors.adaptiveText(context)),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.greyText,
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
            const Icon(Icons.chevron_right, color: Color(0xFFD1D5DB)),
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
            onPressed: _isLoading ? null : _saveTransaction,
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
                : Text(
                    widget.transaction == null ? 'Complete Transaction' : 'Update Transaction',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
          ),
        ),
      ),
    );
  }

  void _showDescriptionDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: AppColors.adaptiveBackground(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Description',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.adaptiveText(context)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'What was this for?',
                  hintStyle: TextStyle(color: AppColors.adaptiveSecondaryText(context).withValues(alpha: 0.5)),
                  filled: true,
                  fillColor: AppColors.adaptiveFieldBackground(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {});
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.adaptiveText(context),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('Save Note', style: TextStyle(color: AppColors.adaptiveBackground(context), fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
