import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lmb_skripsi/components/base_element.dart';

class LegalPage extends StatelessWidget {
  const LegalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dateTime = DateTime.now();
    final date = DateFormat('dd/MM/yyyy').format(dateTime);

    return LmbBaseElement(
      title: "Legality Agreement",
      children: [
        // NOTE: Terms of Service
        Text(
          "Terms of Service",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text("Effective Date: $date"),
        SizedBox(height: 16),
        Text(
          "1. Registration and Account\n"
          "- Users must register with accurate and truthful information.\n"
          "- Each account may only be used by its rightful owner.\n"
          "- You are responsible for maintaining the confidentiality of your account and password.",
        ),
        SizedBox(height: 16),
        Text(
          "2. Use of Services\n"
          "The app is intended for cooperative members to access savings, loans, and other related activities. Usage must comply with applicable laws and cooperative rules.",
        ),
        SizedBox(height: 16),
        Text(
          "3. User Rights and Responsibilities\n"
          "- Users are entitled to accurate and transparent information about cooperative services.\n"
          "- Users must act ethically and not misuse the app features.",
        ),
        SizedBox(height: 16),
        Text(
          "4. Limitation of Liability\n"
          "We are not responsible for losses caused by user error or unauthorized access. While we aim for app reliability, we do not guarantee it will be free from technical issues.",
        ),
        SizedBox(height: 16),
        Text(
          "5. Service Changes\n"
          "We may update or modify app features at any time to improve services. Major changes will be announced beforehand.",
        ),
        SizedBox(height: 16),
        Text(
          "6. Account Suspension or Deletion\n"
          "We reserve the right to suspend or delete accounts that violate these terms or cooperative regulations.",
        ),
        SizedBox(height: 16),
        Text(
          "7. Governing Law\n"
          "These terms are governed by the laws of the Republic of Indonesia.",
        ),
        SizedBox(height: 16),
        Text(
          "8. Contact\n"
          "If you have questions about these terms, contact us at:\n"
          "📧 skripsilumbungmakmurbersama@gmail.com\n"
          "📞 +62-812-8567-2787",
        ),
        SizedBox(height: 64),

        // NOTE: Privacy policy
        Text(
          "Privacy Policy",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text("Effective Date: $date"),
        SizedBox(height: 16),
        Text(
          "1. Information We Collect\n"
          "- Personal details such as name, email address, phone number, and NIK.\n"
          "- Cooperative membership information (member number, status, savings, loans, etc).\n"
          "- App usage data (activities, preferences, access logs).\n"
          "- Device and internet connection data (device type, OS, IP address).",
        ),
        SizedBox(height: 16),
        Text(
          "2. How We Use Your Information\n"
          "- To register and manage your account.\n"
          "- To provide cooperative services like tracking savings, loans, and transactions.\n"
          "- To send important notifications regarding your account.\n"
          "- To improve app performance and security.",
        ),
        SizedBox(height: 16),
        Text(
          "3. Data Security\n"
          "We implement appropriate technical and organizational measures to protect your data from unauthorized access, use, or disclosure.",
        ),
        SizedBox(height: 16),
        Text(
          "4. Third-Party Disclosure\n"
          "We do not share your personal data with third parties without your consent, except as required by law or for internal cooperative operations.",
        ),
        SizedBox(height: 16),
        Text(
          "5. Your Rights\n"
          "You have the right to access, correct, or delete your personal data. You may also request to restrict certain data processing.",
        ),
        SizedBox(height: 16),
        Text(
          "6. Policy Changes\n"
          "This policy may be updated from time to time. Changes will be communicated through the app or email.",
        ),
        SizedBox(height: 16),
        Text(
          "7. Contact\n"
          "If you have any questions, contact us at:\n"
          "📧 skripsilumbungmakmurbersama@gmail.com\n"
          "📞 +62-812-8567-2787",
        ),
        SizedBox(height: 64),
      ],
    );
  }
}