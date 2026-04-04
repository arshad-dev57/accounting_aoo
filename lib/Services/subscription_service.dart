  import 'dart:convert';
  import 'package:http/http.dart' as http;
  import 'package:shared_preferences/shared_preferences.dart';
  import '../../../config/apiconfig.dart';

  class SubscriptionService {
    final String baseUrl = Apiconfig().baseUrl;

    Future<String?> _getToken() async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    }

    Future<Map<String, String>> _getHeaders() async {
      final token = await _getToken();
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    }

    // Get subscription plans
    Future<Map<String, dynamic>> getPlans() async {
      try {
        final headers = await _getHeaders();
        final response = await http.get(
          Uri.parse('$baseUrl/api/subscription/plans'),
          headers: headers,
        );

        final data = json.decode(response.body);
        return data;
      } catch (e) {
        return {'success': false, 'message': e.toString()};
      }
    }

    // Check current subscription status
    Future<Map<String, dynamic>> checkSubscription() async {
      try {
        final headers = await _getHeaders();
        final response = await http.get(
          Uri.parse('$baseUrl/api/subscription/status'),
          headers: headers,
        );

        final data = json.decode(response.body);
        return data;
      } catch (e) {
        return {'success': false, 'message': e.toString()};
      }
    }

    // Create subscription (after payment)
    Future<Map<String, dynamic>> createSubscription({
      required String plan,
      required double amount,
      String? paymentMethod,
      String? transactionId,
    }) async {
      try {
        final headers = await _getHeaders();
        final response = await http.post(
          Uri.parse('$baseUrl/api/subscription/create'),
          headers: headers,
          body: json.encode({
            'plan': plan,
            'amount': amount,
            'paymentMethod': paymentMethod ?? 'in_app_purchase',
            'transactionId': transactionId ?? 'TXN-${DateTime.now().millisecondsSinceEpoch}',
          }),
        );

        final data = json.decode(response.body);
        return data;
      } catch (e) {
        return {'success': false, 'message': e.toString()};
      }
    }

    // Cancel subscription
    Future<Map<String, dynamic>> cancelSubscription() async {
      try {
        final headers = await _getHeaders();
        final response = await http.post(
          Uri.parse('$baseUrl/api/subscription/cancel'),
          headers: headers,
        );

        final data = json.decode(response.body);
        return data;
      } catch (e) {
        return {'success': false, 'message': e.toString()};
      }
    }

    // Get subscription history
    Future<Map<String, dynamic>> getSubscriptionHistory() async {
      try {
        final headers = await _getHeaders();
        final response = await http.get(
          Uri.parse('$baseUrl/api/subscription/history'),
          headers: headers,
        );

        final data = json.decode(response.body);
        return data;
      } catch (e) {
        return {'success': false, 'message': e.toString()};
      }
    }
  }