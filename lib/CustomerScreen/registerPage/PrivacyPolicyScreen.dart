import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const Color themeColor = Color(0xFF006970);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        elevation: 0,
        title: const Text(
          "Privacy Policy",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerCard(),
            const SizedBox(height: 20),

            _section(
              title: "1. Information We Collect",
              content:
              "To provide delivery services, Weloads collects basic customer information such as name, mobile number, email address, pickup and delivery addresses.",
            ),

            _section(
              title: "2. How We Use Your Information",
              content:
              "Your information is used to create your account, process delivery requests, communicate order updates, and improve our services.",
            ),

            _section(
              title: "3. Location Data",
              content:
              "Location data may be used to find nearby delivery partners, calculate delivery distance, and ensure accurate pickup and drop services.",
            ),

            _section(
              title: "4. Data Security",
              content:
              "We follow strict security practices to protect your personal data from unauthorized access, misuse, or disclosure.",
            ),

            _section(
              title: "5. Data Sharing",
              content:
              "Your data is shared only with delivery partners for order fulfillment. We do not sell your personal information to third parties.",
            ),

            _section(
              title: "6. Your Consent",
              content:
              "By using the Weloads customer app, you agree to the collection and use of information in accordance with this privacy policy.",
            ),

            _section(
              title: "7. Policy Updates",
              content:
              "Weloads may update this Privacy Policy periodically. Any changes will be reflected within the app.",
            ),

            const SizedBox(height: 30),

            Center(
              child: Text(
                "© 2026 Weloads. All rights reserved.",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Weloads Privacy Policy",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: themeColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Weloads is a delivery platform committed to protecting customer data and ensuring transparency.",
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _section({
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: themeColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}
