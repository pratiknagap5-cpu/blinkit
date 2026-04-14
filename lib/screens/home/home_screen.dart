import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/address_provider.dart';
import '../../models/product_model.dart';
import '../../theme.dart';
import '../product/product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<AddressProvider>(context, listen: false).fetchCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final addressProvider = Provider.of<AddressProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);

    // Group products by category
    final productsToDisplay = productProvider.filteredProducts;
    Map<String, List<ProductModel>> categorizedProducts = {};
    for (var p in productsToDisplay) {
      if (!categorizedProducts.containsKey(p.category)) {
        categorizedProducts[p.category] = [];
      }
      categorizedProducts[p.category]!.add(p);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 120,
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Blinkit',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '10 MINS',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => Navigator.pushNamed(context, '/checkout'),
              child: Row(
                children: [
                  const Icon(Icons.location_on, size: 18, color: Colors.black),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Delivery to',
                          style: TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          addressProvider.currentAddress,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.black),
                ],
              ),
            ),
          ],
        ),
      ),
      body: productProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Search Bar Sticker
                  Container(
                    color: AppTheme.primaryColor,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        onChanged: (value) => productProvider.setSearchQuery(value),
                        decoration: const InputDecoration(
                          icon: Icon(Icons.search_rounded, color: AppTheme.textDark),
                          hintText: 'Search "milk", "bread"',
                          hintStyle: TextStyle(color: AppTheme.textLight, fontSize: 14),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  // Banners dummy
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(20),
                        image: const DecorationImage(
                          image: NetworkImage('https://images.unsplash.com/photo-1542831371-29b0f74f9713?q=80&w=1000&auto=format&fit=crop'),
                          fit: BoxFit.cover,
                          opacity: 0.6,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Fresh\nVegetables',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24, height: 1.1),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'UP TO 50% OFF',
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Categories Slider
                  _buildCategorySelector(productProvider),
                  const SizedBox(height: 10),
                  // Products
                  productsToDisplay.isEmpty
                      ? _buildNoResults()
                      : Column(
                          children: categorizedProducts.entries.map((entry) {
                            return _buildCategorySection(entry.key, entry.value);
                          }).toList(),
                        ),
                  const SizedBox(height: 120), // padding for bottom cart bar
                ],
              ),
            ),
      bottomSheet: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.cartItems.isEmpty) return const SizedBox.shrink();
          return Container(
            color: Colors.transparent,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, '/cart'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.successColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.successColor.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${cart.cartItems.length} ITEMS',
                              style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w900, fontSize: 10),
                            ),
                            Text(
                              '₹${cart.totalAmount.toStringAsFixed(0)}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Row(
                      children: [
                        Text('View Cart', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_right_alt, color: Colors.white, size: 24),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategorySection(String category, List<ProductModel> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1F1F1F)),
              ),
              const Text(
                'See all',
                style: TextStyle(color: AppTheme.successColor, fontWeight: FontWeight.w900, fontSize: 13),
              ),
            ],
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.60,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            return _buildProductCard(products[index]);
          },
        ),
      ],
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section with fixed 150px height
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: SizedBox(
                height: 150,
                width: double.infinity,
                child: _buildProductImage(product.image),
              ),
            ),
            // Content Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const Spacer(), // Pushes price and button to bottom
                    Text(
                      '₹${product.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // ADD Button / Qty Selector
                    Consumer<CartProvider>(
                      builder: (context, cart, child) {
                        int qty = cart.getQuantity(product.id!);
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: qty == 0
                              ? SizedBox(
                                  key: const ValueKey('add'),
                                  width: double.infinity,
                                  height: 36,
                                  child: OutlinedButton(
                                    onPressed: () => cart.addToCart(product),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppTheme.successColor,
                                      side: const BorderSide(
                                          color: AppTheme.successColor, width: 1.5),
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10)),
                                    ),
                                    child: const Text('ADD',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w900, fontSize: 13)),
                                  ),
                                )
                              : Container(
                                  key: const ValueKey('qty'),
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppTheme.successColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove,
                                            color: Colors.white, size: 18),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () =>
                                            cart.updateQuantity(product.id!, qty - 1),
                                      ),
                                      Text(
                                        '$qty',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 14,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add,
                                            color: Colors.white, size: 18),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () =>
                                            cart.updateQuantity(product.id!, qty + 1),
                                      ),
                                    ],
                                  ),
                                ),
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const String _placeholder = 'https://via.placeholder.com/150';

  Widget _buildCategorySelector(ProductProvider provider) {
    final categories = ['All', ...provider.products.map((p) => p.category).toSet().toList()];
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = provider.selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => provider.setSelectedCategory(category),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryColor : Colors.grey[100],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black12 : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      _getCategoryIcon(category),
                      color: isSelected ? Colors.black : Colors.black54,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                      color: isSelected ? Colors.black : AppTheme.textLight,
                    ),
                  ),
                ],
              ),
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

  Widget _buildNoResults() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'No products found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textLight),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try searching for something else',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(String rawUrl) {
    // Valid URL: must be http(s), from a known image CDN (not google gstatic), not base64
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
      height: 150,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          height: 150,
          color: const Color(0xFFF5F5F5),
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppTheme.primaryColor,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        // On network error, fall back to the placeholder image
        return Image.network(
          _placeholder,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 150,
          errorBuilder: (_, __, ___) => Container(
            height: 150,
            color: const Color(0xFFF5F5F5),
            child: const Center(
              child: Icon(Icons.image_not_supported_outlined,
                  color: Color(0xFFCCCCCC), size: 40),
            ),
          ),
        );
      },
    );
  }
}
