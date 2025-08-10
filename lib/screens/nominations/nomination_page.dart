import 'package:compass/screens/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../utils/colors.dart';

class NominationScreen extends StatefulWidget {
  @override
  _NominationScreenState createState() => _NominationScreenState();
}

class _NominationScreenState extends State<NominationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _githubController = TextEditingController();

  String? _selectedGender;
  String? _selectedDomain;
  bool _isSubmitting = false;

  final List<String> genderOptions = ["Male", "Female", "Others"];
  final List<String> domainOptions = [
    "UI/UX",
    "App Dev",
    "Web Dev",
    "Cybersecurity Team",
    "Social Media Team",
    "Sponsorship & Marketing"
  ];

  Future<void> _submitNomination() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final response = await http.post(
        Uri.parse('https://compass-backend-production-e15e.up.railway.app/api/nominations'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": _nameController.text.trim(),
          "course": _courseController.text.trim(),
          "gender": _selectedGender ?? '',
          "email": _emailController.text.trim(),
          "phone_no": _phoneController.text.trim(),
          "insta_id": _instagramController.text.trim(),
          "github_id": _githubController.text.trim(),
          "domain": _selectedDomain ?? ''
        }),
      );

      final resData = jsonDecode(response.body);
      print(response);
      print(resData);

      if (resData['success'] == true || resData['success'] == 'true' || resData['success'] == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resData['message'] ?? "Nomination submitted successfully!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        ).closed.then((_) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => DashboardScreen()),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resData['message'] ?? "Submission failed"),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Network error: $e"),
          backgroundColor: AppColors.errorRed,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }



  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textSecondary),
      prefixIcon: Icon(icon, color: AppColors.textSecondary),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primaryBlue),
      ),
    );
  }

  InputDecoration _inputDecorationWithImage(String hint, String assetPath) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textSecondary),
      prefixIcon: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Image.asset(assetPath, width: 24, height: 24),
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primaryBlue),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Blue Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryBlue, AppColors.primaryBlue.withOpacity(0.85)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.group, size: 48, color: Colors.white),
                      SizedBox(height: 8),
                      Text(
                        "GDG Nomination",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Join our community of developers and innovators!",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),
                Text("Personal Information", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

                SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration("Enter your full name", Icons.person_outline),
                  validator: (v) => v!.isEmpty ? "Please enter your name" : null,
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _courseController,
                  decoration: _inputDecoration("e.g., B.Tech Computer Science", Icons.school_outlined),
                  validator: (v) => v!.isEmpty ? "Please enter your course" : null,
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: _inputDecoration("Select your gender", Icons.person_outline),
                  value: _selectedGender,
                  items: genderOptions.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  onChanged: (value) => setState(() => _selectedGender = value),
                  validator: (v) => v == null ? "Please select your gender" : null,
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: _inputDecoration("your.email@example.com", Icons.email_outlined),
                  validator: (v) => v!.isEmpty ? "Please enter an email" : null,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: _inputDecoration("Enter 10 digit phone number", Icons.phone_outlined),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Please enter a phone number";
                    if (!RegExp(r'^\d{10}$').hasMatch(v)) return "Phone number must be 10 digits";
                    return null;
                  },
                  keyboardType: TextInputType.phone,
                ),

                SizedBox(height: 20),
                Text("Social & Professional Links", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

                SizedBox(height: 12),
                TextFormField(
                  controller: _instagramController,
                  decoration: _inputDecorationWithImage(
                    "@Instagram_ID",
                    "assets/icons/ig.png",
                  ),
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _githubController,
                  decoration: _inputDecorationWithImage(
                    "https://github.com/username",
                    "assets/icons/github.png",
                  ),
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: _inputDecoration("Select your preferred domain", Icons.work_outline),
                  value: _selectedDomain,
                  items: domainOptions.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  onChanged: (value) => setState(() => _selectedDomain = value),
                  validator: (v) => v == null ? "Please select a domain" : null,
                ),

                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.send, color: Colors.white),
                    label: _isSubmitting
                        ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                        : Text(
                      "Submit Nomination",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isSubmitting ? null : _submitNomination,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
