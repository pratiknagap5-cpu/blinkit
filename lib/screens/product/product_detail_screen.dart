import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../theme.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  static const String _placeholder = 'https://via.placeholder.com/150';

  Widget _buildDetailImage(String rawUrl) {
    final bool isValid = rawUrl.isNotEmpty &&
        rawUrl.startsWith('http') &&
        !rawUrl.startsWith('data:') &&
        !rawUrl.contains('gstatic.com') &&
        !rawUrl.contains('encrypted-tbn');
    final String url = isValid ? rawUrl : _placeholder;

    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: 350,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: const Color(0xFFF5F5F5),
          child: const Center(child: CircularProgressIndicator()),
        );
      },
      errorBuilder: (context, error, stackTrace) => Image.network(
        _placeholder,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 350,
        errorBuilder: (_, __, ___) => Container(
          color: const Color(0xFFF5F5F5),
          child: const Center(
            child: Icon(Icons.image_not_supported_outlined,
                color: Color(0xFFCCCCCC), size: 60),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Custom body to allow image to go under status bar
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 350,
                  width: double.infinity,
                  child: _buildDetailImage(product.image),
                ),
                Positioned(
                  top: 40,
                  left: 20,
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.3),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '₹${product.price}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 5),
                  Text('Category: ${product.category}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 20),
                  const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(
                    product.description,
                    style: const TextStyle(fontSize: 16, color: AppTheme.textLight, height: 1.5),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: Consumer<CartProvider>(
          builder: (context, cart, child) {
            int qty = cart.getQuantity(product.id!);
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: qty == 0
                  ? SizedBox(
                      key: const ValueKey('add'),
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => cart.addToCart(product),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('ADD TO CART', style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w900)),
                      ),
                    )
                  : Container(
                      key: const ValueKey('qty'),
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppTheme.successColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, color: Colors.white, size: 24),
                            onPressed: () => cart.updateQuantity(product.id!, qty - 1),
                          ),
                          Text(
                            '$qty',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.white, size: 24),
                            onPressed: () => cart.updateQuantity(product.id!, qty + 1),
                          ),
                        ],
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }
}
