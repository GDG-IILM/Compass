import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class GdgInfoPage extends StatelessWidget {
  const GdgInfoPage({Key? key}) : super(key: key);

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Know your GDG'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GDG Logo
            Center(
              child: Image.asset(
                'assets/icons/gdg.png',
                height: 120,
              ),
            ),
            const SizedBox(height: 20),

            // About text
            Text(
              'Google Developer Groups (GDG) — also known in student communities as Google Developer Student Clubs (GDSC) — are global community groups for developers interested in Google technologies. '
                  'At IILM, our GDG chapter organizes workshops, hackathons, study jams, and networking events to help students learn, build, and grow together.',
              style: GoogleFonts.roboto(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 20),

            // Section title
            Text(
              'Connect with GDG IILM:',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // Instagram
            ListTile(
              leading: Image.asset(
                'assets/icons/ig.png',
                height: 28,
              ),
              title: const Text('Instagram'),
              onTap: () => _launchUrl(
                'https://www.instagram.com/gdg_iilm?igsh=azdvbWlzNXVmc2tt',
              ),
            ),

            // GitHub
            ListTile(
              leading: Image.asset(
                'assets/icons/github.png',
                height: 28,
              ),
              title: const Text('GitHub'),
              onTap: () => _launchUrl('https://github.com/GDG-IILM'),
            ),

            // LinkedIn
            ListTile(
              leading: Image.asset(
                'assets/icons/linkedin.png',
                height: 28,
              ),
              title: const Text('LinkedIn'),
              onTap: () => _launchUrl(
                'https://www.linkedin.com/company/gdgiilm/posts/?feedView=all',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
