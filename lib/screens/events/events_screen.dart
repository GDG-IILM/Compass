import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/colors.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({Key? key}) : super(key: key);

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  final List<_EventItem> pastEvents = const [
    _EventItem(
      title: "HackO'Clock: Code Like a Googler, Innovate Like a Visionary",
      date: "April 24-25, 2025",
      description:
      "A 24-hour offline hackathon to build impact-driven solutions aligned with the UN SDGs.",
      url:
      "https://gdg.community.dev/events/details/google-gdg-on-campus-iilm-university-greater-noida-india-presents-hackoclock-code-like-a-googler-innovate-like-a-visionary/",
      imageUrl:
      "https://res.cloudinary.com/startup-grind/image/upload/c_fill,w_500,h_500,g_center/c_fill,dpr_2.0,f_auto,g_center,q_auto:good/v1/gcs/platform-data-goog/events/squre%20banner_3rnFHT2.png",
    ),
    _EventItem(
      title: "GDG IILM Website Launch & Google Solution Challenge Info Session",
      date: "January 31, 2025",
      description:
      "Launch of our developer community platform + GSC info session by Harshit Tripathi.",
      url:
      "https://gdg.community.dev/events/details/google-gdg-on-campus-iilm-university-greater-noida-india-presents-gdg-iilm-website-launch-amp-google-solution-challenge-info-session/",
      imageUrl:
      "https://res.cloudinary.com/startup-grind/image/upload/c_fill,w_500,h_500,g_center/c_fill,dpr_2.0,f_auto,g_center,q_auto:good/v1/gcs/platform-data-goog/events/WhatsApp%20Image%202025-01-28%20at%2022.12.22_fbd06c17_jtP5z7w.jpg",
    ),
    _EventItem(
      title: "Quiz-a-thon 2024: Unleash Your Coding Potential",
      date: "December 2024",
      description:
      "A fun and challenging coding quiz event hosted with Internshala for GDG IILM.",
      url:
      "https://gdg.community.dev/events/details/google-gdg-on-campus-iilm-university-greater-noida-india-presents-quiz-a-thon-2024-unleash-your-coding-potential-with-gdg-iilm-university-amp-internshala-1/",
      imageUrl:
      "https://res.cloudinary.com/startup-grind/image/upload/c_fill,w_500,h_500,g_center/c_fill,dpr_2.0,f_auto,g_center,q_auto:good/v1/gcs/platform-data-goog/events/IMG_0571_6LQNPD5.PNG",
    ),
    _EventItem(
      title: "Mastering Dev Tools: Workshop on Git, GitHub & Firebase",
      date: "Late 2024",
      description:
      "Hands-on training on essential developer tools—Git, GitHub, and Firebase infrastructure.",
      url:
      "https://gdg.community.dev/events/details/google-gdg-on-campus-iilm-college-of-engineering-technology-greater-noida-india-presents-mastering-development-tools-hands-on-workshop-on-git-github-amp-firebase/",
      imageUrl:
      "https://res.cloudinary.com/startup-grind/image/upload/c_fill,w_500,h_500,g_center/c_fill,dpr_2.0,f_auto,g_center,q_auto:good/v1/gcs/platform-data-goog/events/WhatsApp%20Image%202024-09-20%20at%2018.36.11_fee53924_vg62S6d.jpg",
    ),
  ];

  final List<_EventItem> upcomingEvents = const [
    _EventItem(
      title: "GDG Info Session",
      date: "TBA",
      description:
      "Explore how GDG empowers developers through events, workshops, and community engagement.",
      url: "",
      imageUrl:
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR9j3pR1S7bg44a7JxYmV3zKBiMAU0zVXoVDg&s",
    ),
    _EventItem(
      title: "Flutter App Development Session",
      date: "TBA",
      description:
      "An introductory session on Flutter and Android development from scratch.",
      url: "",
      imageUrl:
      "https://res.cloudinary.com/upwork-cloud/image/upload/c_scale,w_400/v1726010069/catalog/1833644053689158905/k8n5j0m53gjpsrtqmw2u.jpg",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Events"),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Upcoming Events"),
            ...upcomingEvents.map((e) => _buildEventCard(context, e)),
            const SizedBox(height: 24),
            _buildSectionTitle("Past Events"),
            ...pastEvents.map((e) => _buildEventCard(context, e)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, _EventItem event) {
    return GestureDetector(
      onTap: event.url.isNotEmpty
          ? () => _launchUrl(event.url)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
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
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                event.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(event.date,
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Text(event.description,
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventItem {
  final String title, date, description, url, imageUrl;

  const _EventItem({
    required this.title,
    required this.date,
    required this.description,
    required this.url,
    required this.imageUrl,
  });
}
