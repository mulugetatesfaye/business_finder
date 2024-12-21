import 'package:flutter/material.dart';

class CategoryModel {
  final IconData icon;
  final String name;
  final Color? color;

  CategoryModel({required this.icon, required this.name, this.color});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      icon: json['icon'] as IconData,
      name: json['name'] as String,
      color: json['color'] as Color,
    );
  }

  Map<String, dynamic> toJson() => {
        'icon': icon,
        'name': name,
        'color': color,
      };
}
