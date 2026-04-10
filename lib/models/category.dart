import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../models/transaction.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final TransactionType type;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon_code': icon.codePoint,
      'color_code': color.toARGB32(),
      'type': type == TransactionType.income ? 'income' : 'expense',
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      name: map['name'] as String,
      icon: IconData(map['icon_code'] as int, fontFamily: 'MaterialIcons'),
      color: Color(map['color_code'] as int),
      type: map['type'] == 'income' ? TransactionType.income : TransactionType.expense,
    );
  }

  @override
  List<Object?> get props => [id, name, icon, color, type];
}
