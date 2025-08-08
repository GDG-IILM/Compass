import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../chatbot/chatbot_screen.dart';
import '../events/events_screen.dart';
import '../wall/campus_wall_screen.dart';
import '../profile/profile_screen.dart';
// Add this import for the nomination page
// import '../nominations/nomination_page.dart'; // Uncomment and adjust path as needed

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<DashboardTab> _tabs = [
    DashboardTab(
      title: 'Dashboard',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
    ),
    DashboardTab(
      title: 'Sakhi',
      icon: Icons.smart_toy_outlined,
      activeIcon: Icons.smart_toy,
    ),
    DashboardTab(
      title: 'Events',
      icon: Icons.event_outlined,
      activeIcon: Icons.event,
    ),
    DashboardTab(
      title: 'Wall',
      icon: Icons.forum_outlined,
      activeIcon: Icons.forum,
    ),
    DashboardTab(
      title: 'Profile',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          _buildHomeTab(), // Dashboard content
          const ChatBotScreen(), // Updated chatbot screen
          EventsScreen(), // Your actual events screen
          CampusWallScreen(), // Your actual campus wall screen
          ProfileScreen(), // Your actual profile screen
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Jump directly to the page without animation
          _pageController.jumpToPage(index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.mediumGray,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 0,
        items: _tabs.map((tab) {
          final isSelected = _tabs.indexOf(tab) == _currentIndex;
          return BottomNavigationBarItem(
            icon: Icon(isSelected ? tab.activeIcon : tab.icon),
            label: tab.title,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHomeTab() {
    return FutureBuilder<UserModel?>(
      future: _getCurrentUserModel(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data;
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(user),
                const SizedBox(height: 24),
                _buildQuickActions(),
                const SizedBox(height: 24),
                _buildUpcomingEvents(),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper method to get UserModel from Firebase User
  Future<UserModel?> _getCurrentUserModel() async {
    try {
      final firebaseUser = _authService.currentUser;
      if (firebaseUser == null) return null;

      final userData = await _authService.getUserData();
      if (userData == null) return null;

      return UserModel.fromMap(userData, firebaseUser.uid);
    } catch (e) {
      print('Error loading user data: $e');
      return null;
    }
  }

  Widget _buildHeader(UserModel? user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.whiteWithOpacity(0.2),
            backgroundImage: user?.profileImageUrl != null
                ? NetworkImage(user!.profileImageUrl!)
                : null,
            child: user?.profileImageUrl == null
                ? Text(
              user?.initials ?? 'U',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    color: AppColors.whiteWithOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.displayName ?? 'Student',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (user?.branch != null && user?.semester != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${user!.branch} • ${user.formattedSemester}',
                    style: TextStyle(
                      color: AppColors.whiteWithOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Navigate to notifications
            },
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        // Single action card for Join Event
        _buildActionCard(
          'Join Event',
          'Find and join campus events',
          Icons.add_circle_outline,
          AppColors.eventsColor,
              () {
            // Navigate to Events tab
            setState(() {
              _currentIndex = 2;
            });
            _pageController.animateToPage(
              2,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        ),
        const SizedBox(height: 12),
        // GDG Application card
        _buildActionCard(
          'Apply for GDG!',
          'Nominations are live',
          Icons.group_add_outlined,
          AppColors.primaryBlue,
              () {
            // Navigate to nomination page
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => NominationPage()),
            // );

            // Temporary placeholder - replace with actual navigation
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Navigate to Nomination Page'),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(
      String title,
      String subtitle,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.mediumGray,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingEvents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Upcoming Events',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _currentIndex = 2; // Navigate to Events tab
                });
                _pageController.animateToPage(
                  2,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: const Text(
                'View All',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildEventCard(
          'Tech Talk: AI in Education',
          'Tomorrow, 2:00 PM',
          'Auditorium A',
          '45 attending',
        ),
        const SizedBox(height: 12),
        _buildEventCard(
          'Study Group: Database Systems',
          'Friday, 4:00 PM',
          'Library Room 201',
          '12 attending',
        ),
      ],
    );
  }

  Widget _buildEventCard(String title, String time, String location, String attending) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.eventsColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.event,
              color: AppColors.eventsColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      attending,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.eventsColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardTab {
  final String title;
  final IconData icon;
  final IconData activeIcon;

  DashboardTab({
    required this.title,
    required this.icon,
    required this.activeIcon,
  });
}