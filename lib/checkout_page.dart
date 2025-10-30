import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'order_model.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double total;

  const CheckoutPage({super.key, required this.cartItems, required this.total});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController();
  String _paymentMethod = 'Cash on Delivery';

  Future<void> _placeOrder() async {
    if (_formKey.currentState!.validate()) {
      final order = OrderModel(
        userName: _nameController.text,
        phoneNumber: _phoneController.text,
        email: _emailController.text,
        addressLine1: _addressLine1Controller.text,
        addressLine2: _addressLine2Controller.text,
        city: _cityController.text,
        state: _stateController.text,
        postalCode: _postalCodeController.text,
        country: _countryController.text,
        items: widget.cartItems,
        total: widget.total,
        paymentMethod: _paymentMethod,
        orderDate: DateTime.now(),
      );

      try {
        // Store order in Firestore
        await FirebaseFirestore.instance.collection('orders').add(order.toMap());

        // Prepare WhatsApp message
        String itemsList = widget.cartItems
            .map((item) => "${item['name']} (Qty: ${item['quantity']}, Price: €${item['price']})")
            .join('\n');
        String message = '''
New Order Received!
Name: ${_nameController.text}
Phone: ${_phoneController.text}
Email: ${_emailController.text}
Address: ${_addressLine1Controller.text}, ${_addressLine2Controller.text}, ${_cityController.text}, ${_stateController.text}, ${_postalCodeController.text}, ${_countryController.text}
Items:
$itemsList
Total: €${widget.total.toStringAsFixed(2)}
Payment Method: $_paymentMethod
Order Date: ${DateTime.now().toString()}
''';

        // Encode message for WhatsApp URL
        String encodedMessage = Uri.encodeComponent(message);
        String whatsappUrl = 'https://wa.me/393492911392?text=$encodedMessage';

        // Launch WhatsApp
        if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
          await launchUrl(Uri.parse(whatsappUrl));
        } else {
          throw 'Could not launch WhatsApp';
        }

        // Clear cart
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('cart', []);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Order placed successfully! WhatsApp message sent.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );

        // Navigate back
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _openStripePayment() async {
    const url = 'https://buy.stripe.com/14AfZh75b9PO2qTcylcQU10';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not open payment link'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isOptional = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.teal),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.teal, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
        prefixIcon: Icon(
          label.contains('Name')
              ? Icons.person
              : label.contains('Phone')
                  ? Icons.phone
                  : label.contains('Email')
                      ? Icons.email
                      : Icons.location_on,
          color: Colors.teal,
        ),
      ),
      keyboardType: keyboardType,
      validator: isOptional ? null : validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.teal,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'User Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your name' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your phone number' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty) return 'Please enter your email';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Shipping Address',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _addressLine1Controller,
                    label: 'Address Line 1',
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your address' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _addressLine2Controller,
                    label: 'Address Line 2 (Optional)',
                    isOptional: true,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _cityController,
                    label: 'City',
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your city' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _stateController,
                    label: 'State/Province',
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your state/province' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _postalCodeController,
                    label: 'Postal Code',
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your postal code' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _countryController,
                    label: 'Country',
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your country' : null,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Payment Method',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _openStripePayment,
                    icon: const Icon(Icons.payment),
                    label: const Text('Pay with Stripe'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.teal, width: 1),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text('Cash on Delivery'),
                          leading: Radio<String>(
                            value: 'Cash on Delivery',
                            groupValue: _paymentMethod,
                            onChanged: (value) {
                              setState(() {
                                _paymentMethod = value!;
                              });
                            },
                            activeColor: Colors.teal,
                          ),
                        ),
                        ListTile(
                          title: const Text('Online Payment'),
                          leading: Radio<String>(
                            value: 'Online Payment',
                            groupValue: _paymentMethod,
                            onChanged: (value) {
                              setState(() {
                                _paymentMethod = value!;
                              });
                            },
                            activeColor: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Order Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.teal[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        Text(
                          '€${widget.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _placeOrder,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Place Order'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}