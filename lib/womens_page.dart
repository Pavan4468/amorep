// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class WomensPage extends StatefulWidget {
//   const WomensPage({super.key});

//   @override
//   WomensPageState createState() => WomensPageState();
// }

// class WomensPageState extends State<WomensPage> {
//   Future<void> _addToCart(Map<String, dynamic> product) async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> cart = prefs.getStringList('cart') ?? [];
//     cart.add(
//         '${product['name']}|${product['price']}|${product['image']}|${product['description']}|${product['category']}|${product['stock']}');
//     await prefs.setStringList('cart', cart);
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('${product['name']} added to cart'),
//         backgroundColor: Colors.green,
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(16),
//       ),
//     );
//   }

//   void _showProductDetails(BuildContext context, Map<String, dynamic> product) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => DraggableScrollableSheet(
//         initialChildSize: 0.9,
//         minChildSize: 0.5,
//         maxChildSize: 0.95,
//         builder: (_, controller) => Container(
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//           ),
//           child: ListView(
//             controller: controller,
//             children: [
//               ClipRRect(
//                 borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
//                 child: Image.network(
//                   product['image'],
//                   height: 300,
//                   width: double.infinity,
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) => Container(
//                     height: 300,
//                     color: Colors.grey[200],
//                     child: const Icon(Icons.error, color: Colors.red),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       product['name'],
//                       style: const TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       '€${product['price'].toStringAsFixed(2)}',
//                       style: const TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.teal,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       product['description'],
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.grey[600],
//                         height: 1.4,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Chip(
//                           label: Text(product['category']),
//                           backgroundColor: Colors.teal[50],
//                           labelStyle: TextStyle(color: Colors.teal[700]),
//                         ),
//                         Chip(
//                           label: Text('${product['stock']} in stock'),
//                           backgroundColor: Colors.teal[50],
//                           labelStyle: TextStyle(color: Colors.teal[700]),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 24),
//                     ElevatedButton(
//                       onPressed: () => _addToCart(product),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.teal,
//                         foregroundColor: Colors.white,
//                         minimumSize: const Size(double.infinity, 50),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       child: const Text(
//                         'Add to Cart',
//                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('products')
//           .where('category', isEqualTo: 'Women')
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return Center(
//             child: Text(
//               'No products available',
//               style: TextStyle(
//                 fontSize: 18,
//                 color: Colors.grey[600],
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           );
//         }
//         final products = snapshot.data!.docs;
//         return GridView.builder(
//           padding: const EdgeInsets.all(16),
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2,
//             crossAxisSpacing: 16,
//             mainAxisSpacing: 16,
//             childAspectRatio: 0.75,
//           ),
//           itemCount: products.length,
//           itemBuilder: (context, index) {
//             final product = products[index].data() as Map<String, dynamic>;
//             return GestureDetector(
//               onTap: () => _showProductDetails(context, product),
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       blurRadius: 8,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Expanded(
//                       child: ClipRRect(
//                         borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//                         child: Image.network(
//                           product['image'],
//                           width: double.infinity,
//                           fit: BoxFit.cover,
//                           loadingBuilder: (context, child, loadingProgress) {
//                             if (loadingProgress == null) return child;
//                             return Container(
//                               color: Colors.grey[100],
//                               child: const Center(child: CircularProgressIndicator()),
//                             );
//                           },
//                           errorBuilder: (context, error, stackTrace) => Container(
//                             color: Colors.grey[100],
//                             child: const Icon(Icons.error, color: Colors.red),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(12),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             product['name'],
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.black87,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             '€${product['price'].toStringAsFixed(2)}',
//                             style: const TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.teal,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }