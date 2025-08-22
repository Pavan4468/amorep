class OrderModel {
  final String userName;
  final String phoneNumber;
  final String email;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final List<Map<String, dynamic>> items;
  final double total;
  final String paymentMethod;
  final DateTime orderDate;

  OrderModel({
    required this.userName,
    required this.phoneNumber,
    required this.email,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.items,
    required this.total,
    required this.paymentMethod,
    required this.orderDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'phoneNumber': phoneNumber,
      'email': email,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'items': items,
      'total': total,
      'paymentMethod': paymentMethod,
      'orderDate': orderDate.toIso8601String(),
    };
  }
}