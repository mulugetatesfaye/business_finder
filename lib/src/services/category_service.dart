import 'package:business_finder/src/models/category_model.dart';
import 'package:flutter/material.dart';

class CategoryService {
  static final List<CategoryModel> categories = [
    CategoryModel(
        name: 'Restaurants', icon: Icons.restaurant, color: Colors.black54),
    CategoryModel(name: 'Real Estate', icon: Icons.home, color: Colors.black54),
    CategoryModel(
        name: 'Supermarkets', icon: Icons.store, color: Colors.black54),
    CategoryModel(
        name: 'Car dealers', icon: Icons.car_rental, color: Colors.black54),
    CategoryModel(name: 'Mansions', icon: Icons.house, color: Colors.black54),
    CategoryModel(name: 'Park', icon: Icons.park, color: Colors.black54),
  ];
}
