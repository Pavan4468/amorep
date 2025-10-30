import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:badges/badges.dart' as badges;
import 'CartPage.dart';
import 'CheapProductsPage.dart';
import 'CategoriesPage.dart';
import 'KidsProductsPage.dart';

import 'ReturnPage.dart';
 // Placeholder provided below

class EShoppingHomePage extends StatefulWidget {
  const EShoppingHomePage({super.key});

  @override
  EShoppingHomePageState createState() => EShoppingHomePageState();
}

class EShoppingHomePageState extends State<EShoppingHomePage> {
  final List<String> bannerImages = [
    'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=600&auto=format&fit=crop&q=60',
    'https://plus.unsplash.com/premium_photo-1700824490393-c9355c267144?w=600&auto=format&fit=crop&q=60',
    'https://plus.unsplash.com/premium_photo-1683121271931-669e09a55414?w=600&auto=format&fit=crop&q=60',
    'https://plus.unsplash.com/premium_photo-1683121350513-6fbc3f1ce91a?w=600&auto=format&fit=crop&q=60',
  ];

  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Men\'s Fashion',
      'image': 'https://plus.unsplash.com/premium_photo-1661326297568-65045688d10a?w=600&auto=format&fit=crop&q=60',
      'page': const CategoriesPage(),
    },
    {
      'name': 'Women\'s Fashion',
      'image': 'https://images.unsplash.com/photo-1651489337165-f0f62bc3fc9e?w=600&auto=format&fit=crop&q=60',
      'page': const WomenProductsPage(),
    },
    {
      'name': 'Kids\' Fashion',
      'image': 'https://plus.unsplash.com/premium_photo-1661274061055-6f6d0f110ba6?w=600&auto=format&fit=crop&q=60',
      'page': const KidsProductsPage(),
    },
    
  ];

  int cartItemCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCartCount();
  }

  Future<void> _loadCartCount() async {
    final prefs = await SharedPreferences.getInstance();
    final cart = prefs.getStringList('cart') ?? [];
    setState(() {
      cartItemCount = cart.length;
    });
  }

  Future<void> _addToCart(Map<String, dynamic> product, String selectedSize) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cart = prefs.getStringList('cart') ?? [];
    cart.add(
        '${product['name']}|${product['price']}|${product['image']}|${product['description']}|${product['category']}|${product['stock']}|$selectedSize');
    await prefs.setStringList('cart', cart);
    setState(() {
      cartItemCount = cart.length;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product['name']} (Size: $selectedSize) added to cart'),
        //backgroundColor: Colors.teal,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showProductDetails(BuildContext context, Map<String, dynamic> product) {
    String selectedSize = 'M'; // Default size
    List<String> availableSizes = ['S', 'M', 'L', 'XL'];
    List<String> productImages = [
      product['image1'] as String? ?? product['image'] as String? ?? 'https://via.placeholder.com/300',
      product['image2'] as String? ?? 'https://via.placeholder.com/300',
      product['image3'] as String? ?? 'https://via.placeholder.com/300',
      product['image4'] as String? ?? 'https://via.placeholder.com/300',
    ].where((image) => image.isNotEmpty).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: controller,
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  height: 300,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  viewportFraction: 0.85,
                ),
                items: productImages.map((url) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 300,
                        color: Colors.grey[200],
                        child: const Icon(Icons.error, color: Colors.red),
                      ),
                    ),
                  );
                }).toList(),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'] ?? 'Unknown Product',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '€${(product['price'] as num? ?? 0).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      product['description'] ?? 'No description available',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Chip(
                          label: Text(product['category'] ?? 'Unknown'),
                          backgroundColor: Colors.teal[50],
                          labelStyle: TextStyle(color: Colors.teal[700]),
                        ),
                        Chip(
                          label: Text('${product['stock'] ?? 0} in stock'),
                          backgroundColor: Colors.teal[50],
                          labelStyle: TextStyle(color: Colors.teal[700]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Select Size',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    StatefulBuilder(
                      builder: (context, setState) => Wrap(
                        spacing: 8,
                        children: availableSizes.map((size) {
                          return ChoiceChip(
                            label: Text(size),
                            selected: selectedSize == size,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  selectedSize = size;
                                });
                              }
                            },
                            selectedColor: Colors.teal,
                            labelStyle: TextStyle(
                              color: selectedSize == size ? Colors.white : Colors.black87,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => _addToCart(product, selectedSize),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Add to Cart',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
       title: const Text('Shopping'),
        //backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: badges.Badge(
              badgeContent: Text(
                cartItemCount.toString(),
                style: const TextStyle(color: Colors.white),
              ),
              child: const Icon(Icons.shopping_cart),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartPage()),
              ).then((_) => _loadCartCount());
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal, Colors.teal.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'AMO fashion',
                    style: TextStyle(
                      fontSize: 14,
                     // fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.teal),
              title: const Text(
                'Home',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.category, color: Colors.teal),
              title: const Text(
                'Men\'s Fashion',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CategoriesPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.female, color: Colors.teal),
              title: const Text(
                'Women\'s Fashion',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WomenProductsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.child_care, color: Colors.teal),
              title: const Text(
                'Kids\' Fashion',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const KidsProductsPage()),
                );
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.policy, color: Colors.teal),
              title: const Text(
                'Return Product',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReturnPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart, color: Colors.teal),
              title: const Text(
                'Cart',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              trailing: badges.Badge(
                badgeContent: Text(
                  cartItemCount.toString(),
                  style: const TextStyle(color: Colors.white),
                ),
                child: const SizedBox(),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartPage()),
                ).then((_) => _loadCartCount());
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  height: 200,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  viewportFraction: 0.85,
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                ),
                items: bannerImages.map((url) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        url,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.error, color: Colors.red),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Shop by Category',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: List.generate(
                        (categories.length / 2).ceil(),
                        (index) {
                          final firstIndex = index * 2;
                          final secondIndex = firstIndex + 1;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (firstIndex < categories.length)
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => categories[firstIndex]['page']),
                                        );
                                      },
                                      child: Column(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: Image.network(
                                              categories[firstIndex]['image'],
                                              width: 150,
                                              height: 150,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (context, child, loadingProgress) {
                                                if (loadingProgress == null) return child;
                                                return Container(
                                                  width: 150,
                                                  height: 150,
                                                  color: Colors.grey[300],
                                                  child: const Center(child: CircularProgressIndicator()),
                                                );
                                              },
                                              errorBuilder: (context, error, stackTrace) => Container(
                                                width: 150,
                                                height: 150,
                                                color: Colors.grey[300],
                                                child: const Icon(Icons.error, color: Colors.red),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            categories[firstIndex]['name'],
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black87,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 16),
                                if (secondIndex < categories.length)
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => categories[secondIndex]['page']),
                                        );
                                      },
                                      child: Column(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: Image.network(
                                              categories[secondIndex]['image'],
                                              width: 150,
                                              height: 150,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (context, child, loadingProgress) {
                                                if (loadingProgress == null) return child;
                                                return Container(
                                                  width: 150,
                                                  height: 150,
                                                  color: Colors.grey[300],
                                                  child: const Center(child: CircularProgressIndicator()),
                                                );
                                              },
                                              errorBuilder: (context, error, stackTrace) => Container(
                                                width: 150,
                                                height: 150,
                                                color: Colors.grey[300],
                                                child: const Icon(Icons.error, color: Colors.red),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            categories[secondIndex]['name'],
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black87,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  const Expanded(child: SizedBox()),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('products').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        '',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }
                  final products = snapshot.data!.docs;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index].data() as Map<String, dynamic>;
                      return GestureDetector(
                        onTap: () => _showProductDetails(context, product),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                  child: Image.network(
                                    product['image'] ?? 'https://via.placeholder.com/300',
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: Colors.grey[100],
                                        child: const Center(child: CircularProgressIndicator()),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: Colors.grey[100],
                                      child: const Icon(Icons.error, color: Colors.red),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['name'] ?? 'Unknown Product',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '€${(product['price'] as num? ?? 0).toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}