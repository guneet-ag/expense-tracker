import 'package:flutter/material.dart';
import '../utils/categories.dart';
import '../utils/format.dart';

class CategorySummary extends StatelessWidget {
  final Map<String, double> totals; // category name -> amount
  final double monthTotal;
  const CategorySummary({super.key, required this.totals, required this.monthTotal});

  @override
  Widget build(BuildContext context) {
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Column(
      children: entries.map((e) {
        final cat = categoryByName(e.key);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(cat.icon, color: cat.color, size: 20),
              const SizedBox(width: 8),
              SizedBox(width: 100, child: Text(cat.name)),
              Expanded(
                child: LinearProgressIndicator(
                  value: monthTotal == 0 ? 0 : e.value / monthTotal,
                  color: cat.color,
                  backgroundColor: cat.color.withValues(alpha: 0.15),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Text(formatMoney(e.value), style: const TextStyle(fontSize: 12)),
            ],
          ),
        );
      }).toList(),
    );
  }
}