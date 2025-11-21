import 'package:flutter/material.dart';
import '../../../models/category_model.dart';

class CategoryChips extends StatefulWidget {
  final List<CategoryModel> categories;
  final Function(String) onCategorySelected;

  const CategoryChips({
    super.key,
    required this.categories,
    required this.onCategorySelected,
  });

  @override
  State<CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  String _selectedValue = 'general';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.categories.length,
        itemBuilder: (context, index) {
          final category = widget.categories[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ChoiceChip(
              label: Text(category.name),
              selected: _selectedValue == category.value,
              onSelected: (selected) {
                setState(() {
                  _selectedValue = category.value;
                });
                widget.onCategorySelected(category.value);
              },
            ),
          );
        },
      ),
    );
  }
}