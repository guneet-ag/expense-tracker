import 'package:flutter/material.dart';

class Category {
  final String name;
  final IconData icon;
  final Color color;
  const Category(this.name, this.icon, this.color);
}

const categories = [
  Category('Food', Icons.restaurant, Colors.orange),
  Category('Travel', Icons.directions_bus, Colors.blue),
  Category('Shopping', Icons.shopping_bag, Colors.pink),
  Category('Bills', Icons.receipt_long, Colors.red),
  Category('Entertainment', Icons.movie, Colors.purple),
  Category('Health', Icons.favorite, Colors.green),
  Category('Other', Icons.category, Colors.grey),
];

Category categoryByName(String name) =>
    categories.firstWhere((c) => c.name == name, orElse: () => categories.last);