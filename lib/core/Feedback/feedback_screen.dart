import 'package:LedgerPro_app/Utils/colors.dart';
import 'package:LedgerPro_app/Utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _suggestionController = TextEditingController();
  
  int _rating = 0;
  bool _isSubmitting = false;
  bool _anonymous = false;

  Future<void> _submitFeedback() async {
    if (_feedbackController.text.trim().isEmpty && _suggestionController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please provide some feedback',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    
    if (_rating == 0) {
      Get.snackbar('Error', 'Please rate your experience',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      final response = await http.post(
        Uri.parse('https://your-api.com/api/feedback/submit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'rating': _rating,
          'feedback': _feedbackController.text.trim(),
          'suggestion': _suggestionController.text.trim(),
          'anonymous': _anonymous,
        }),
      );

      if (response.statusCode == 200) {
        Get.snackbar('Thank You!', 'Your feedback has been submitted',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
        
        _feedbackController.clear();
        _suggestionController.clear();
        setState(() => _rating = 0);
        
        Future.delayed(const Duration(seconds: 2), () => Get.back());
      } else {
        throw Exception('Failed to submit');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit feedback. Please try again.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    final isMobile = ResponsiveUtils.isMobile(context);
    
    return Container(
      color: const Color(0xFFF5F8FC),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isWeb ? 24 : 16),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildRatingCard(),
            const SizedBox(height: 20),
            _buildFeedbackForm(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isWeb = ResponsiveUtils.isWeb(Get.context!);
    final isMobile = ResponsiveUtils.isMobile(Get.context!);
    
    return Container(
      padding: EdgeInsets.fromLTRB(
        isWeb ? 24 : 16,
        isWeb ? 20 : 16,
        isWeb ? 24 : 16,
        isWeb ? 16 : 12,
      ),
      decoration: BoxDecoration(
        color: kPrimary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          // Back Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: isWeb ? 20 : 16),
              onPressed: () => Get.back(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Feedback',
                  style: TextStyle(
                    fontSize: isWeb ? 24 : 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Help us improve LedgerPro',
                  style: TextStyle(
                    fontSize: isWeb ? 14 : 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingCard() {
    final isWeb = ResponsiveUtils.isWeb(Get.context!);
    
    return Container(
      padding: EdgeInsets.all(isWeb ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isWeb ? 20 : 16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Text(
            'How would you rate your experience?',
            style: TextStyle(
              fontSize: isWeb ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: kText,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                onPressed: () => setState(() => _rating = index + 1),
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: isWeb ? 48 : 40,
                ),
                padding: EdgeInsets.symmetric(horizontal: isWeb ? 8 : 4),
              );
            }),
          ),
          if (_rating > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _rating == 5 ? 'Excellent!' : 
                _rating == 4 ? 'Good' : 
                _rating == 3 ? 'Average' : 
                _rating == 2 ? 'Poor' : 'Very Poor',
                style: TextStyle(
                  fontSize: isWeb ? 16 : 14,
                  color: _rating >= 4 ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeedbackForm() {
    final isWeb = ResponsiveUtils.isWeb(Get.context!);
    final isMobile = ResponsiveUtils.isMobile(Get.context!);
    
    return Container(
      padding: EdgeInsets.all(isWeb ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isWeb ? 20 : 16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Share Your Thoughts',
            style: TextStyle(
              fontSize: isWeb ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: kText,
            ),
          ),
          const SizedBox(height: 20),
          
          _buildLabel('What do you like about the app?', isWeb),
          TextField(
            controller: _feedbackController,
            maxLines: 3,
            decoration: _buildInputDecoration('Tell us what you love...', isWeb),
            style: TextStyle(fontSize: isWeb ? 15 : 14),
          ),
          const SizedBox(height: 16),
          
          _buildLabel('Suggestions for improvement', isWeb),
          TextField(
            controller: _suggestionController,
            maxLines: 3,
            decoration: _buildInputDecoration('What features would you like to see?', isWeb),
            style: TextStyle(fontSize: isWeb ? 15 : 14),
          ),
          
          const SizedBox(height: 16),
          
          // Anonymous Option
          Row(
            children: [
              Checkbox(
                value: _anonymous,
                onChanged: (value) => setState(() => _anonymous = value ?? false),
                activeColor: kPrimary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              Expanded(
                child: Text(
                  'Submit anonymously',
                  style: TextStyle(
                    fontSize: isWeb ? 14 : 13,
                    color: kSubText,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            height: isWeb ? 56 : 50,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitFeedback,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isWeb ? 14 : 12)),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? LoadingAnimationWidget.waveDots(
                      color: Colors.white,
                      size: isWeb ? 30 : 24,
                    )
                  : Text(
                      'Submit Feedback',
                      style: TextStyle(
                        fontSize: isWeb ? 16 : 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label, bool isWeb) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: isWeb ? 14 : 13,
          fontWeight: FontWeight.w600,
          color: kText,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, bool isWeb) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: const Color(0xFF7A8FA6), fontSize: isWeb ? 14 : 13),
      filled: true,
      fillColor: const Color(0xFFF5F8FC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(isWeb ? 14 : 12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(isWeb ? 14 : 12),
        borderSide: const BorderSide(color: Color(0xFFDDE4EE)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(isWeb ? 14 : 12),
        borderSide: const BorderSide(color: kPrimary, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: isWeb ? 20 : 16, vertical: isWeb ? 18 : 16),
    );
  }
}