import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';

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
      title: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
    ),
    DashboardTab(
      title: 'Resources',
      icon: Icons.library_books_outlined,
      activeIcon: Icons.library_books,
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
          _buildHomeTab(),
          _buildResourcesTab(),
          _buildEventsTab(),
          _buildWallTab(),
          _buildProfileTab(),
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
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
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
                _buildQuickStats(),
                const SizedBox(height: 24),
                _buildQuickActions(),
                const SizedBox(height: 24),
                _buildRecentActivity(),
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

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Notes Shared',
            '12',
            Icons.note_outlined,
            AppColors.resourcesColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Events Joined',
            '5',
            Icons.event_outlined,
            AppColors.eventsColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Posts Made',
            '8',
            Icons.forum_outlined,
            AppColors.wallColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
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
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Share Notes',
                'Upload and share your study materials',
                Icons.upload_outlined,
                AppColors.resourcesColor,
                    () {
                  // TODO: Navigate to note upload
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Join Event',
                'Find and join campus events',
                Icons.add_circle_outline,
                AppColors.eventsColor,
                    () {
                  // TODO: Navigate to events
                },
              ),
            ),
          ],
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 12),
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
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to full activity
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
        _buildActivityItem(
          'Sarah Johnson liked your note',
          'Data Structures - Linked Lists',
          '2 hours ago',
          Icons.favorite,
          AppColors.errorRed,
        ),
        _buildActivityItem(
          'New event posted',
          'Programming Contest 2024',
          '4 hours ago',
          Icons.event,
          AppColors.eventsColor,
        ),
        _buildActivityItem(
          'John Doe commented on your post',
          'Campus Wall Discussion',
          '1 day ago',
          Icons.comment,
          AppColors.wallColor,
        ),
      ],
    );
  }

  Widget _buildActivityItem(
      String title,
      String subtitle,
      String time,
      IconData icon,
      Color color,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
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
          Text(
            time,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
        ],
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

  Widget _buildResourcesTab() {
    return const Center(
      child: Text('Resources Tab - Coming Soon'),
    );
  }

  Widget _buildEventsTab() {
    return const Center(
      child: Text('Events Tab - Coming Soon'),
    );
  }

  Widget _buildWallTab() {
    return const Center(
      child: Text('Wall Tab - Coming Soon'),
    );
  }

  Widget _buildProfileTab() {
    return const Center(
      child: Text('Profile Tab - Coming Soon'),
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