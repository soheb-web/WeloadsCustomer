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
              title: "Company Information",
              content:
                  "Company Name: RESOLENT PRIME PRIVATE LIMITED\n"
                  "Brand Name: Weloads\n"
                  "Effective Date: 1 November 2025\n\n"
                  "Registered Address:\n"
                  "Room No. C-344, Sant Rohidas Ekta Society, Ambujwadi, Azad Nagar, "
                  "Gate No. 6, Abdul Hamid Road, Nr. Akashwani, Malvani, "
                  "Malad (W), Mumbai – 400095\n\n"
                  "Email: support@weloads.com\n"
                  "Website: www.weloads.com",
            ),

            _section(
              title: "1. Introduction",
              content:
                  "RESOLENT PRIME PRIVATE LIMITED (“Weloads”, “we”, “our”, “us”) "
                  "is committed to protecting your privacy. This Privacy Policy "
                  "describes how we collect, use, store, and protect your data "
                  "when you use the Weloads mobile app, website, or any service "
                  "operated by us.\n\n"
                  "This policy applies to both customers and driver partners.",
            ),

            _section(
              title: "Consent (DPDP Act 2023)",
              content:
                  "By using Weloads services, you expressly consent to the "
                  "collection, processing, storage, and sharing of your personal "
                  "data in accordance with this Privacy Policy and applicable "
                  "Indian laws, including the DPDP Act 2023.",
            ),

            _section(
              title: "2. Information We Collect",
              content:
                  "Customer Information:\n"
                  "• Name, phone number, email\n"
                  "• Pickup & drop addresses\n"
                  "• Real-time & historical location data\n"
                  "• Payment details (processed via secure gateways)\n"
                  "• Booking history, ratings, complaints\n\n"
                  "Driver Information:\n"
                  "• Name, phone, email\n"
                  "• KYC documents & vehicle details\n"
                  "• Bank details for settlements\n"
                  "• Real-time GPS location during trips\n\n"
                  "Automatically Collected Data:\n"
                  "• Device info, IP address\n"
                  "• Analytics, crash logs, usage data",
            ),

            _section(
              title: "3. How We Use Your Information",
              content:
                  "We use personal data to:\n"
                  "• Provide and operate Weloads services\n"
                  "• Process bookings, payments, and refunds\n"
                  "• Enable customer–driver communication\n"
                  "• Track live locations for deliveries\n"
                  "• Improve performance and safety\n"
                  "• Detect fraud and verify identity\n"
                  "• Send notifications and updates\n"
                  "• Provide customer and driver support",
            ),

            _section(
              title: "4. Data Sharing & Disclosure",
              content:
                  "Operational Sharing:\n"
                  "• Customer details shared with drivers\n"
                  "• Driver details shared with customers\n\n"
                  "Third-Party Providers:\n"
                  "• Payment gateways\n"
                  "• Cloud hosting & analytics\n"
                  "• SMS, OTP & call-masking services\n\n"
                  "Legal Disclosure:\n"
                  "• Law enforcement or government authorities if required\n\n"
                  "Business Transfers:\n"
                  "• Merger, acquisition, or restructuring\n\n"
                  "Weloads does NOT sell personal data.",
            ),

            _section(
              title: "5. Phone Number Masking",
              content:
                  "Weloads may use virtual or masked phone numbers to protect "
                  "the privacy of customers and drivers.",
            ),

            _section(
              title: "6. Cookies & Tracking Technologies",
              content:
                  "Cookies and analytics tools are used for:\n"
                  "• App performance\n"
                  "• Session management\n"
                  "• User preferences\n"
                  "• Fraud prevention\n\n"
                  "Disabling cookies may affect some features.",
            ),

            _section(
              title: "7. Data Retention",
              content:
                  "Customer and driver data may be retained for up to 7 years "
                  "for legal, tax, or audit purposes.\n\n"
                  "Even after account deletion, certain records such as billing "
                  "or KYC may be retained as required by law.",
            ),

            _section(
              title: "8. Data Security",
              content:
                  "We use industry-standard safeguards including encryption, "
                  "secure servers, access controls, audits, and monitoring.\n\n"
                  "However, no system can be guaranteed 100% secure.",
            ),

            _section(
              title: "9. Data Breach Notification",
              content:
                  "In case of a data breach, affected users and the Data "
                  "Protection Board of India will be notified as required "
                  "under the DPDP Act 2023.",
            ),

            _section(
              title: "10. Your Rights",
              content:
                  "You may request:\n"
                  "• Access to your data\n"
                  "• Correction of inaccurate data\n"
                  "• Deletion of personal data (subject to law)\n"
                  "• Withdrawal of consent\n"
                  "• Opt-out of marketing communications\n\n"
                  "Contact: support@weloads.com",
            ),

            _section(
              title: "11. Children’s Privacy",
              content:
                  "Weloads does not knowingly collect data from individuals "
                  "under 18 years of age. Such data will be deleted if found.",
            ),

            _section(
              title: "12. International Data Transfers",
              content:
                  "Data may be stored in India or other permitted regions, "
                  "in compliance with applicable Indian laws.",
            ),

            _section(
              title: "13. Automated Decision-Making",
              content:
                  "Automated systems may be used for fraud detection, identity "
                  "verification, and risk analysis to ensure platform safety.",
            ),

            _section(
              title: "14. Updates to Privacy Policy",
              content:
                  "This Privacy Policy may be updated at any time. Continued "
                  "use of Weloads services constitutes acceptance of the "
                  "updated policy.",
            ),

            _section(
              title: "15. Contact Information",
              content:
                  "Email: support@weloads.com\n\n"
                  "Address:\n"
                  "Room No. C-344, Sant Rohidas Ekta Society, Ambujwadi, "
                  "Azad Nagar, Gate No. 6, Abdul Hamid Road, "
                  "Nr. Akashwani, Malvani, Malad (W), Mumbai – 400095",
            ),

            const SizedBox(height: 30),

            Center(
              child: Text(
                "© 2026 Weloads. All rights reserved.",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
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
            "Weloads – Privacy Policy",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: themeColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Your privacy matters to us. Please read this policy carefully.",
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _section({required String title, required String content}) {
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
          Text(content, style: const TextStyle(fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }
}
