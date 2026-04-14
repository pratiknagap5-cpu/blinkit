import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../theme.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final categories = ['All', ...productProvider.products.map((p) => p.category).toSet().toList()];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('All Categories'),
        elevation: 0,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () {
              productProvider.setSelectedCategory(category);
              Provider.of<NavigationProvider>(context, listen: false).setTab(0);
            },
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      _getCategoryIcon(category),
                      size: 40,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  category,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Dairy': return Icons.egg_outlined;
      case 'Fruits': return Icons.apple_outlined;
      case 'Vegetables': return Icons.eco_outlined;
      case 'Grocery': return Icons.shopping_basket_outlined;
      case 'Snacks': return Icons.cookie_outlined;
      case 'Beverages': return Icons.local_drink_outlined;
      default: return Icons.category_outlined;
    }
  }
}
