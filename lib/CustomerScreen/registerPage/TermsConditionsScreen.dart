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
                  "Gate No. 6, Abdul Hamid Road, Nr. Akashwani, Malvani, Malad (W), "
                  "Mumbai – 400095\n\n"
                  "Email: support@weloads.com\n"
                  "Website: www.weloads.com",
            ),

            _section(
              title: "1. Acceptance of Terms",
              content:
                  "By accessing or using the Weloads website, mobile application, "
                  "or any associated platform (“Services”), you agree to be bound "
                  "by these Terms & Conditions (“Terms”). If you do not agree, "
                  "you must immediately stop using the Services.",
            ),

            _section(
              title: "2. Nature of Services (Aggregator Model)",
              content:
                  "Weloads operates only as a technology platform that facilitates "
                  "intra-city & inter-city logistics, courier services, transport "
                  "vehicle booking, porter, packer, and mover arrangements.\n\n"
                  "Weloads does not own, operate, or manage any vehicles and does not "
                  "employ any drivers or delivery partners. All service providers "
                  "are independent third-party contractors.",
            ),

            _section(
              title: "3. User Account",
              content:
                  "Users must provide accurate registration details and are "
                  "responsible for all activities conducted through their account. "
                  "Weloads may suspend or terminate accounts for misuse, fraud, or "
                  "violation of these Terms.",
            ),

            _section(
              title: "4. Booking, Pricing & Payments",
              content:
                  "All bookings must be made through the Weloads platform. "
                  "Payments must be made in advance using available payment methods.\n\n"
                  "Pricing may include taxes, tolls, parking, operational charges, "
                  "and peak-hour charges. Toll, parking, and entry charges are always "
                  "payable by the customer.\n\n"
                  "Cancellation Policy:\n"
                  "• Cancellation before driver dispatch: Full refund\n"
                  "• Cancellation after driver dispatch: No refund\n"
                  "• Refunds processed within 7–14 business days",
            ),

            _section(
              title: "5. Delivery & Customer Responsibilities",
              content:
                  "Customers must provide accurate pickup and drop details and "
                  "ensure goods are properly packed. Poor or inadequate packing "
                  "is the customer’s responsibility.\n\n"
                  "Drivers may refuse items that are unsafe, oversized, or illegal.",
            ),

            _section(
              title: "6. Waiting Time, Loading & Unloading",
              content:
                  "Free waiting time of 10 minutes is provided after driver arrival. "
                  "After this, per-minute waiting charges apply.\n\n"
                  "Loading, unloading, lifting, and handling of goods is the "
                  "customer’s responsibility unless voluntarily assisted by the driver.",
            ),

            _section(
              title: "7. Zero Liability Disclaimer",
              content:
                  "Weloads acts only as a vehicle-arrangement facilitator and has "
                  "ZERO liability for loss, theft, damage, delay, misdelivery, "
                  "driver behavior, accidents, or improper packing.\n\n"
                  "Maximum liability of Weloads is ₹0. "
                  "Weloads does not provide insurance for goods.",
            ),

            _section(
              title: "8. Independent Contractor Clause",
              content:
                  "All drivers, delivery partners, porters, packers, and movers are "
                  "independent contractors. Weloads is not responsible for their "
                  "actions, conduct, or compliance with laws.",
            ),

            _section(
              title: "9. Prohibited & Restricted Items",
              content:
                  "Customers must not ship hazardous materials, illegal substances, "
                  "weapons, narcotics, currency, jewellery, perishable goods, or "
                  "any items prohibited under Indian law.",
            ),

            _section(
              title: "10. Communication & Phone Masking",
              content:
                  "Weloads may use virtual or masked numbers to protect user privacy. "
                  "Direct sharing of phone numbers between customer and driver is discouraged.",
            ),

            _section(
              title: "11. Fraudulent or Misleading Bookings",
              content:
                  "Weloads may suspend accounts for fake bookings, misleading "
                  "addresses, illegal shipments, or payment fraud.",
            ),

            _section(
              title: "12. Driver / Partner Rights",
              content:
                  "Drivers may refuse or cancel bookings due to misbehavior, "
                  "illegal goods, safety concerns, or inaccessible locations. "
                  "Weloads is not liable for such cancellations.",
            ),

            _section(
              title: "13. Intellectual Property",
              content:
                  "All trademarks, logos, designs, and content belong to "
                  "RESOLENT PRIME PRIVATE LIMITED. Unauthorized use is prohibited.",
            ),

            _section(
              title: "14. Privacy & Data Protection",
              content:
                  "Personal data is processed as per the Privacy Policy and "
                  "applicable laws, including the DPDP Act 2023.",
            ),

            _section(
              title: "15. Indemnification",
              content:
                  "Customers agree to indemnify Weloads against any claims arising "
                  "from violation of these Terms, illegal use, prohibited items, "
                  "or fraudulent activity.",
            ),

            _section(
              title: "16. Governing Law & Dispute Resolution",
              content:
                  "These Terms are governed by the laws of India. All disputes "
                  "fall under the exclusive jurisdiction of Mumbai Courts.\n\n"
                  "Mandatory Arbitration:\n"
                  "Disputes shall be resolved through binding arbitration under "
                  "the Arbitration and Conciliation Act, 1996. "
                  "Seat and venue: Mumbai. Language: English.",
            ),

            _section(
              title: "17. Modification & Force Majeure",
              content:
                  "Weloads may update these Terms at any time. Continued use "
                  "constitutes acceptance.\n\n"
                  "Weloads shall not be liable for delays due to Force Majeure events "
                  "including natural disasters, government actions, strikes, "
                  "lockdowns, or unforeseen circumstances.",
            ),

            _section(
              title: "18. Contact Information",
              content:
                  "Email: support@weloads.com\n\n"
                  "Address:\n"
                  "Room No. C-344, Sant Rohidas Ekta Society, Ambujwadi, Azad Nagar, "
                  "Gate No. 6, Abdul Hamid Road, Nr. Akashwani, Malvani, "
                  "Malad (W), Mumbai – 400095",
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                "© 2026 Weloads. All rights reserved.",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
            "Weloads – Customer Terms & Conditions",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: themeColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Please read these Terms & Conditions carefully before using Weloads services.",
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
