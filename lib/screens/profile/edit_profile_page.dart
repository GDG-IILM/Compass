import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../utils/colors.dart';

class EditProfilePage extends StatefulWidget {
  final UserModel? user;

  const EditProfilePage({Key? key, this.user}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _branchController;
  late TextEditingController _semesterController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;

  bool _isSaving = false;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name ?? '');
    _branchController = TextEditingController(text: widget.user?.branch ?? '');
    _semesterController =
        TextEditingController(text: widget.user?.semester.toString() ?? '');
    _phoneController =
        TextEditingController(text: widget.user?.phoneNumber ?? '');
    _bioController = TextEditingController(text: widget.user?.bio ?? '');
  }

  Future<void> _saveProfile() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({
        'fullName': _nameController.text.trim(),
        'branch': _branchController.text.trim(),
        'semester': int.tryParse(_semesterController.text.trim()) ?? 1,
        'phoneNumber': _phoneController.text.trim(),
        'bio': _bioController.text.trim(),
        'updatedAt': DateTime.now(),
      });

      Navigator.pop(
        context,
        widget.user?.copyWith(
          name: _nameController.text.trim(),
          branch: _branchController.text.trim(),
          semester: int.tryParse(_semesterController.text.trim()) ?? 1,
          phoneNumber: _phoneController.text.trim(),
          bio: _bioController.text.trim(),
          updatedAt: DateTime.now(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating profile: $e")),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: AppColors.textSecondary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField("Full Name", _nameController),
            const SizedBox(height: 12),
            _buildTextField("Branch", _branchController),
            const SizedBox(height: 12),
            _buildTextField(
              "Semester",
              _semesterController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              "Phone Number",
              _phoneController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            _buildTextField("Bio", _bioController, maxLines: 3),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
