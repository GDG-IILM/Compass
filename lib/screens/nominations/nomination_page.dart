import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/colors.dart'; // Adjust path as needed

class NominationPage extends StatefulWidget {
  const NominationPage({Key? key}) : super(key: key);

  @override
  State<NominationPage> createState() => _NominationPageState();
}

class _NominationPageState extends State<NominationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _courseController = TextEditingController();
  final _emailController = TextEditingController();
  final _instagramController = TextEditingController();
  final _githubController = TextEditingController();

  String? _selectedGender;
  String? _selectedDomain;

  final List<String> _genderOptions = ['Male', 'Female', 'Others'];
  final List<String> _domainOptions = [
    'UI/UX',
    'App Development',
    'Web Development',
    'CyberSecurity',
    'Social Media Management',
    'Sponsorship & Marketing',
  ];

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _courseController.dispose();
    _emailController.dispose();
    _instagramController.dispose();
    _githubController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildForm(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: IconButton(
          onPressed: () {
            // Navigate back to dashboard
            Navigator.pop(context);
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textPrimary,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.whiteWithOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.groups,
              color: AppColors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'GDG Nomination',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Join our community of developers and innovators!',
            style: TextStyle(
              color: AppColors.whiteWithOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),

            _buildTextFormField(
              controller: _nameController,
              label: 'Full Name',
              hint: 'Enter your full name',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            _buildTextFormField(
              controller: _courseController,
              label: 'Course',
              hint: 'e.g., B.Tech Computer Science',
              icon: Icons.school_outlined,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your course';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            _buildDropdownField(
              label: 'Gender',
              value: _selectedGender,
              hint: 'Select your gender',
              icon: Icons.person_outline,
              items: _genderOptions,
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select your gender';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            _buildTextFormField(
              controller: _emailController,
              label: 'Email Address',
              hint: 'your.email@example.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email address';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),

            const SizedBox(height: 32),

            const Text(
              'Social & Professional Links',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),

            _buildTextFormField(
              controller: _instagramController,
              label: 'Instagram Profile',
              hint: 'https://instagram.com/username',
              icon: Icons.camera_alt_outlined, // Using camera as Instagram icon alternative
              customIcon: _buildInstagramIcon(), // Custom Instagram icon
              keyboardType: TextInputType.url,
              validator: (value) {
                if (value != null && value.isNotEmpty && !value.contains('instagram.com')) {
                  return 'Please enter a valid Instagram URL';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            _buildTextFormField(
              controller: _githubController,
              label: 'GitHub Profile',
              hint: 'https://github.com/username',
              icon: Icons.code_outlined,
              customIcon: _buildGithubIcon(), // Custom GitHub icon
              keyboardType: TextInputType.url,
              validator: (value) {
                if (value != null && value.isNotEmpty && !value.contains('github.com')) {
                  return 'Please enter a valid GitHub URL';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            _buildDropdownField(
              label: 'Domain',
              value: _selectedDomain,
              hint: 'Select your preferred domain',
              icon: Icons.work_outline,
              items: _domainOptions,
              onChanged: (value) {
                setState(() {
                  _selectedDomain = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select your domain';
                }
                return null;
              },
            ),

            const SizedBox(height: 40),

            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    Widget? customIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 16,
              ),
              prefixIcon: customIcon ?? Icon(
                icon,
                color: AppColors.primaryBlue,
                size: 22,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required String hint,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            validator: validator,
            onChanged: onChanged,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 16,
              ),
              prefixIcon: Icon(
                icon,
                color: AppColors.primaryBlue,
                size: 22,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            dropdownColor: AppColors.white,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          disabledBackgroundColor: AppColors.lightGray,
        ),
        child: _isSubmitting
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.send_outlined,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Submit Nomination',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      // Add haptic feedback
      HapticFeedback.lightImpact();

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.white,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Nomination submitted successfully!',
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.successGreen,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        // Navigate back after success
        Navigator.pop(context);
      }

      setState(() {
        _isSubmitting = false;
      });

      // Print form data (replace with actual API call)
      _printFormData();
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.error,
                color: AppColors.white,
              ),
              const SizedBox(width: 8),
              const Text(
                'Please fill all required fields correctly',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.errorRed,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _printFormData() {
    print('=== GDG Nomination Form Data ===');
    print('Name: ${_nameController.text}');
    print('Course: ${_courseController.text}');
    print('Gender: $_selectedGender');
    print('Email: ${_emailController.text}');
    print('Instagram: ${_instagramController.text}');
    print('GitHub: ${_githubController.text}');
    print('Domain: $_selectedDomain');
    print('================================');
  }

  // Custom Instagram Icon
  Widget _buildInstagramIcon() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFFF58529),
              Color(0xFFDD2A7B),
              Color(0xFF8134AF),
              Color(0xFF515BD4),
            ],
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: const Icon(
          Icons.camera_alt_outlined,
          color: Colors.white,
          size: 14,
        ),
      ),
    );
  }

  // Custom GitHub Icon
  Widget _buildGithubIcon() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: const Color(0xFF24292E),
          borderRadius: BorderRadius.circular(11),
        ),
        child: const Icon(
          Icons.code,
          color: Colors.white,
          size: 14,
        ),
      ),
    );
  }
}