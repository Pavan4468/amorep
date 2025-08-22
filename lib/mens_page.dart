// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class MensPage extends StatefulWidget {
//   const MensPage({super.key});

//   @override
//   MensPageState createState() => MensPageState();
// }

// class MensPageState extends State<MensPage> {
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
//                   product['image'] ?? 'https://via.placeholder.com/300',
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
//                       product['name'] ?? 'Unknown Product',
//                       style: const TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       '€${(product['price'] ?? 0).toStringAsFixed(2)}',
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.teal,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       product['description'] ?? 'No description available',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey[600],
//                         height: 1.4,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Chip(
//                           label: Text(product['category'] ?? 'Unknown'),
//                           backgroundColor: Colors.teal[50],
//                           labelStyle: TextStyle(color: Colors.teal[700]),
//                         ),
//                         Chip(
//                           label: Text('${product['stock'] ?? 0} in stock'),
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
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Men\'s Products'),
//         backgroundColor: Colors.teal,
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('products')
//             .where('category', isEqualTo: 'Men')
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(
//               child: Text(
//                 'Error: ${snapshot.error}',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.red,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             );
//           }
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(
//               child: Text(
//                 'No products available',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.grey[600],
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             );
//           }
//           final products = snapshot.data!.docs;
//           return GridView.builder(
//             padding: const EdgeInsets.all(16),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               crossAxisSpacing: 16,
//               mainAxisSpacing: 16,
//               childAspectRatio: 0.75,
//             ),
//             itemCount: products.length,
//             itemBuilder: (context, index) {
//               final product = products[index].data() as Map<String, dynamic>;
//               return GestureDetector(
//                 onTap: () => _showProductDetails(context, product),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.05),
//                         blurRadius: 8,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(16),
//                         child: Image.network(
//                           product['image'] ?? 'https://via.placeholder.com/300',
//                           height: 180,
//                           width: double.infinity,
//                           fit: BoxFit.cover,
//                           loadingBuilder: (context, child, loadingProgress) {
//                             if (loadingProgress == null) return child;
//                             return Container(
//                               height: 180,
//                               color: Colors.grey[100],
//                               child: const Center(child: CircularProgressIndicator()),
//                             );
//                           },
//                           errorBuilder: (context, error, stackTrace) => Container(
//                             height: 180,
//                             color: Colors.grey[100],
//                             child: const Icon(Icons.error, color: Colors.red),
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(12),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               product['name'] ?? 'Unknown Product',
//                               style: const TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.black87,
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               '€${(product['price'] ?? 0).toStringAsFixed(2)}',
//                               style: const TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.teal,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }