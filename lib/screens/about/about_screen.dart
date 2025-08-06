import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Overview Section
            _buildSectionCard(
              title: 'Fresher\'s Compass',
              content: 'An all-in-one mobile application designed specifically for engineering students, with a primary focus on helping freshers navigate their new college environment. Created by the Google Developer Student Club (GDSC) to be the single most essential app for first-year students.',
              icon: Icons.school,
            ),

            const SizedBox(height: 16),

            // Problems It Solves Section
            _buildSectionCard(
              title: 'Problems We Solve',
              content: 'We tackle the anxiety and confusion that freshers face when starting college. The app provides instant access to chatbot, campus information, events, and creates a platform for community connection, making the transition to college life smoother and more enjoyable.',
              icon: Icons.lightbulb_outline,
            ),

            const SizedBox(height: 16),

            // How It Helps Section
            _buildSectionCard(
              title: 'How It Helps Students',
              content: 'The app accelerates student integration into the college community through features like Resource Hub for academic materials, Events & Clubs showcase for extracurricular activities, Campus Wall for peer interaction, and Quick Campus Guide for navigation and essential information.',
              icon: Icons.help_outline,
            ),

            const SizedBox(height: 24),

            // Developers Section
            const Text(
              'Know Your Developers',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Developer 1 - Piyush
            _buildDeveloperCard(
              name: 'Piyush Pattanayak',
              year: '2nd Year, 2024-28',
              role: 'App Developer',
              position: 'GDG, IILM Chapter',
              additionalRole: 'Founder, CTO at Dev-Opify',
              github: 'https://github.com/Piyushpattanayak04',
              devOpifyLink: 'https://dev-opify.netlify.app/',
              imagePath: 'assets/pfp/piyush.png',
            ),

            const SizedBox(height: 16),

            // Developer 2 - Kushal
            _buildDeveloperCard(
              name: 'Kushal Sharma',
              year: '3rd Year, 2023-27',
              role: 'GDG Lead',
              position: 'GDG Lead, IILM Chapter',
              github: 'https://github.com/Kushalsharma0702',
              imagePath: 'assets/pfp/kushal.png',
            ),

            const SizedBox(height: 24),

            // Footer
            Center(
              child: Text(
                'Made with ❤️ by GDG IILM Chapter',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: Colors.blue[700],
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperCard({
    required String name,
    required String year,
    required String role,
    required String position,
    required String github,
    required String imagePath,
    String? additionalRole,
    String? devOpifyLink,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Profile Picture
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image.asset(
                imagePath,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.grey[600],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),

            // Developer Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    year,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    position,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                  // Additional role for Piyush
                  if (additionalRole != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      additionalRole,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.purple[700],
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),

                  // Buttons Row
                  Row(
                    children: [
                      // GitHub Button
                      GestureDetector(
                        onTap: () => _launchURL(github),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.code_outlined,
                                size: 16,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'GitHub',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Dev-Opify Button (only for Piyush)
                      if (devOpifyLink != null) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _launchURL(devOpifyLink),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple[700],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.language,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Dev-Opify',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Handle error - could show a snackbar or dialog
      print('Could not launch $url');
    }
  }
}