import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ReturnPage extends StatelessWidget {
  const ReturnPage({super.key});

  // Function to launch email client
  Future<void> _launchEmail(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'Fabio93pinta@gmail.com',
      queryParameters: {
        'subject': 'Return Request - Amo Shopping',
        'body': 'Dear Amo Support Team,\n\nI would like to initiate a return for my order. Please provide further instructions.\n\nOrder Number: \nReason for Return: \n\nThank you,\n[Your Name]'
      },
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        _showSnackBar(context, 'Could not open email client.');
      }
    } catch (e) {
      _showSnackBar(context, 'Error opening email client: $e');
    }
  }

  // Function to launch WhatsApp
  Future<void> _launchWhatsApp(BuildContext context) async {
    final Uri whatsappUri = Uri.parse('https://api.whatsapp.com/send?phone=393492911392&text=Hello%20Amo%20Support%20Team,%20I%20would%20like%20to%20initiate%20a%20return%20for%20my%20order.');

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar(context, 'Could not open WhatsApp.');
      }
    } catch (e) {
      _showSnackBar(context, 'Error opening WhatsApp: $e');
    }
  }

  // Function to show SnackBar
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal[700],
        elevation: 0,
        title: const Text(
          'Amo Return Policy',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal[50]!, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Amo Return Policy',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[900],
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'At Amo, your satisfaction is our priority. Learn about our hassle-free return process below.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Return Policy Section
                _buildSectionTitle('Return Conditions'),
                const SizedBox(height: 12),
                _buildSectionContent(
                  '• Items must be unused, unworn, and in their original packaging.\n'
                  '• Items must include all original tags and labels.\n'
                  '• Returns must be initiated within 30 days of delivery.\n'
                  '• Certain items, such as personalized products or perishable goods, are non-returnable.',
                ),
                const SizedBox(height: 24),

                // How to Return Section
                _buildSectionTitle('How to Return'),
                const SizedBox(height: 12),
                _buildSectionContent(
                  '1. Contact our customer service team at Fabio93pinta@gmail.com'
                  '2. Provide your order number and reason for return.\n'
                  '3. Receive a return authorization and shipping instructions.\n'
                  '4. Pack the item securely and include the return authorization form.\n'
                  '5. Ship the item back to us using the provided shipping label.',
                ),
                const SizedBox(height: 24),

                // Refunds Section
                _buildSectionTitle('Refunds'),
                const SizedBox(height: 12),
                _buildSectionContent(
                  'Once we receive and inspect your return, we will notify you via email about the approval or rejection of your refund. If approved, your refund will be processed within 7-10 business days to the original payment method.',
                ),
                const SizedBox(height: 32),

                // Contact Support Buttons
                Center(
                  child: Column(
                    children: [                 
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _launchWhatsApp(context),
                        icon: const Icon(Icons.message, color: Colors.white),
                        label: const Text('Contact via WhatsApp'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Contact Information
                Center(
                  child: Text(
                    'Email: amocustomerserviceforyou@gmail.com',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method for section titles
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.teal[900],
      ),
    );
  }

  // Helper method for section content
  Widget _buildSectionContent(String content) {
    return Text(
      content,
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey[800],
        height: 1.5,
        letterSpacing: 0.3,
      ),
    );
  }
}