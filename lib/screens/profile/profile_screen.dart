import 'package:compass/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/colors.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../about/about_screen.dart';
import 'gdginfo_page.dart';
import 'edit_profile_page.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _authService.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          setState(() {
            _currentUser = UserModel.fromMap(doc.data()!, user.uid);
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() => _isLoading = false);
      }
    }
  }

  Route _fadeScaleRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 250),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var fade = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
        return FadeTransition(
          opacity: fade,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(fade),
            child: child,
          ),
        );
      },
    );
  }

  void _showHelpSupportDialog() {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text("Help & Support"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.email_outlined, color: Colors.blue),
                  title: const Text("Email"),
                  subtitle: const Text("gdgiilmu@iilm.edu"),
                  onTap: () async {
                    final uri = Uri(
                      scheme: 'mailto',
                      path: 'gdgiilmu@iilm.edu',
                    );
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text("Close"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 24),
              _buildMenuItems(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Profile',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: _showEditProfile,
                icon: const Icon(Icons.edit, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 24),
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white.withOpacity(0.2),
            backgroundImage: _currentUser?.profileImageUrl != null
                ? NetworkImage(_currentUser!.profileImageUrl!)
                : null,
            child: _currentUser?.profileImageUrl == null
                ? Text(
              _currentUser?.initials ?? 'U',
              style: GoogleFonts.poppins(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            _currentUser?.name ?? 'User Name',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_currentUser?.branch ?? ''} • ${_currentUser
                ?.formattedSemester ?? ''}',
            style: GoogleFonts.roboto(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currentUser?.email ?? '',
            style: GoogleFonts.roboto(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          if (_currentUser?.bio?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(
              _currentUser!.bio!,
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }


  Widget _buildMenuItems() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildMenuItem(
            'Know Your GDG',
            Icons.info_outline,
            AppColors.primary,
                () =>
                Navigator.of(context).push(
                    _fadeScaleRoute(const GdgInfoPage())),
          ),
          const SizedBox(height: 16),
          _buildMenuItem(
            'About',
            Icons.info,
            Colors.orange,
                () =>
                Navigator.of(context).push(
                    _fadeScaleRoute(const AboutScreen())),
          ),
          const SizedBox(height: 16),
          _buildMenuItem(
            'Help & Support',
            Icons.help_outline,
            Colors.teal,
            _showHelpSupportDialog,
          ),
          const SizedBox(height: 16),
          _buildMenuItem(
            'Sign Out',
            Icons.logout,
            AppColors.error,
                () => _signOut(context),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title,
      IconData icon,
      Color color,
      VoidCallback onTap, {
        bool isDestructive = false,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDestructive
              ? AppColors.error.withOpacity(0.05)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? AppColors.error : AppColors
                      .textPrimary,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  void _showEditProfile() {
    Navigator.of(context)
        .push(_fadeScaleRoute(EditProfilePage(user: _currentUser)))
        .then((updatedUser) {
      if (updatedUser != null && updatedUser is UserModel) {
        setState(() {
          _currentUser = updatedUser;
        });
      }
    });
  }

  Future<void> _signOut(BuildContext context) async {
    await AuthService().signOut();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sign out successful')),
    );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }
}
