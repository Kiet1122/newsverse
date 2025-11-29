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
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.categories.length,
        itemBuilder: (context, index) {
          final category = widget.categories[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(
                category.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _selectedValue == category.value 
                      ? Colors.white 
                      : Colors.grey[700],
                ),
              ),
              selected: _selectedValue == category.value,
              onSelected: (selected) {
                setState(() {
                  _selectedValue = category.value;
                });
                widget.onCategorySelected(category.value);
              },
              selectedColor: Colors.blue[600],
              backgroundColor: Colors.grey[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: _selectedValue == category.value 
                      ? Colors.blue[600]! 
                      : Colors.grey[300]!,
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          );
        },
      ),
    );
  }
}