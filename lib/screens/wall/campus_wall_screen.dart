import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Startup {
  final String name;
  final String description;
  final String founders;
  final String? logoPath;
  final String? websiteUrl;
  final String? instagramUrl;
  final String? linkedinUrl;

  Startup({
    required this.name,
    required this.description,
    required this.founders,
    this.logoPath,
    this.websiteUrl,
    this.instagramUrl,
    this.linkedinUrl,
  });
}

class CampusWallScreen extends StatelessWidget {
  final List<Startup> startups = [
    Startup(
      name: "Dev-Opify",
      description:
      "Dev-opify crafts tailored, scalable software—websites, mobile apps, custom tools, and digital strategy solutions—powered by expert design and 24/7 support.",
      founders: "Piyush Pattanayk (Founder) Bibhu Krupa (Co-Founder)",
      logoPath: "assets/logo/devopify.png",
      websiteUrl: "https://devopify.com",
      instagramUrl: "https://instagram.com/devopify",
      linkedinUrl: "https://linkedin.com/company/devopify",
    ),
    Startup(
      name: "The Yukt",
      description: "A software solution company",
      founders: "Vaibhav Bajaj",
      logoPath: "assets/logo/yukt.png",
      websiteUrl: "https://theyukt.com",
      instagramUrl: "https://instagram.com/theyukt",
    ),
    Startup(
      name: "ClarifyKnowledge",
      description:
      "An ed-tech startup empowering ICSE students with concept clarity through innovative resources.",
      founders: "Pranay Mishra (Founder) Harshit Singh (Co-Founder)",
      logoPath: "assets/logo/ck.png",
      websiteUrl: "https://clarifyknowledge.com",
    ),
    Startup(
      name: "Loop Mind",
      description: "A creative-tech venture building engaging, futuristic experiences.",
      founders: "Harshit Singh (Founder) Ayush Tripathi (Co-Founder)",
      websiteUrl: "https://www.loopmind.netlify.app",
      linkedinUrl: "https://www.linkedin.com/company/loopmind-in",
      logoPath: "assets/logo/loopmind.png",
    ),
    Startup(
      name: "Grint",
      description:
      "Our startup is a sports booking platform that connects players and sports venues seamlessly.",
      founders: "Aditya Saluja",
      instagramUrl: "https://chat.whatsapp.com/LbH0IIFwqEZHrxpP8yTrVJ",
      logoPath: "assets/logo/grint.png",
    ),
  ];

  CampusWallScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Campus Wall",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0D47A1),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: startups.length,
        itemBuilder: (context, index) {
          final startup = startups[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Logo + Name Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: (startup.logoPath != null &&
                            startup.logoPath!.isNotEmpty)
                            ? Image.asset(
                          startup.logoPath!,
                          height: 40,
                          width: 40,
                          fit: BoxFit.cover,
                        )
                            : Image.asset(
                          "assets/icons/building.png",
                          height: 40,
                          width: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          startup.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  /// Description
                  Text(
                    startup.description,
                    style: const TextStyle(color: Colors.black87),
                  ),

                  const SizedBox(height: 8),

                  /// Founders
                  Text(
                    "Founder(s): ${startup.founders}",
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// Social Icons Row
                  Row(
                    children: [
                      if (startup.websiteUrl != null &&
                          startup.websiteUrl!.isNotEmpty)
                        IconButton(
                          onPressed: () => _launchUrl(startup.websiteUrl!),
                          icon: Image.asset(
                            "assets/icons/web.png",
                            height: 28,
                          ),
                        ),
                      if (startup.instagramUrl != null &&
                          startup.instagramUrl!.isNotEmpty)
                        IconButton(
                          onPressed: () => _launchUrl(startup.instagramUrl!),
                          icon: Image.asset(
                            "assets/icons/ig.png",
                            height: 28,
                          ),
                        ),
                      if (startup.linkedinUrl != null &&
                          startup.linkedinUrl!.isNotEmpty)
                        IconButton(
                          onPressed: () => _launchUrl(startup.linkedinUrl!),
                          icon: Image.asset(
                            "assets/icons/linkedin.png",
                            height: 28,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
