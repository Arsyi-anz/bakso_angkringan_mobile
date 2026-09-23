import 'customer_model.dart';

class AuthResponseModel {
  final CustomerModel customer;
  final String token;

  AuthResponseModel({
    required this.customer,
    required this.token,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      customer: CustomerModel.fromJson(
        json['data'] as Map<String, dynamic>,
      ),
      token: json['token'] ?? '',
    );
  }
}