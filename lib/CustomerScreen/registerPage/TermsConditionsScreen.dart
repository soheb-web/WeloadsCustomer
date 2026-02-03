import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  static const Color themeColor = Color(0xFF006970);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        elevation: 0,
        title: const Text(
          "Terms & Conditions",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
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
              title: "1. User Eligibility",
              content:
              "By using the Weloads customer app, you confirm that the information provided during registration is accurate and complete.",
            ),

            _section(
              title: "2. Service Usage",
              content:
              "Weloads provides delivery services subject to availability. Delivery time may vary depending on location, traffic, and other conditions.",
            ),

            _section(
              title: "3. User Responsibilities",
              content:
              "Customers are responsible for providing correct pickup and delivery details. Weloads is not responsible for delays caused by incorrect information.",
            ),

            _section(
              title: "4. Payments & Charges",
              content:
              "All delivery charges shown in the app are final unless stated otherwise. Additional charges may apply in special circumstances.",
            ),

            _section(
              title: "5. Cancellation & Refunds",
              content:
              "Cancellations are subject to Weloads cancellation policy. Refunds, if applicable, will be processed as per company guidelines.",
            ),

            _section(
              title: "6. Limitation of Liability",
              content:
              "Weloads shall not be liable for indirect or unforeseen losses arising during the delivery process.",
            ),

            _section(
              title: "7. Policy Updates",
              content:
              "Weloads reserves the right to modify these Terms & Conditions at any time. Continued use of the app indicates acceptance of the updated terms.",
            ),

            const SizedBox(height: 30),

            Center(
              child: Text(
                "© 2026 Weloads. All rights reserved.",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
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
            "Weloads Terms & Conditions",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: themeColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Please read these terms carefully before using the Weloads customer delivery app.",
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
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
