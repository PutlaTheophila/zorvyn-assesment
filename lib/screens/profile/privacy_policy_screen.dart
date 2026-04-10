import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const profileBg = Colors.black;
    const profileTextPrimary = Colors.white;
    const profileTextSecondary = Colors.white70;

    return Scaffold(
      backgroundColor: AppColors.adaptiveBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.adaptiveBackground(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.adaptiveText(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Privacy Policy',
          style: TextStyle(
            color: AppColors.adaptiveText(context),
            fontWeight: FontWeight.w700,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Finance Companion Privacy Policy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: profileTextPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Last updated: January 2026',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: profileTextSecondary,
              ),
            ),
            const SizedBox(height: 32),

            _buildSection(
              title: '1. Information We Collect',
              textColor: profileTextPrimary,
              secondaryColor: profileTextSecondary,
              content:
                  'We collect information you provide directly to us, including your name, email address, and financial transaction data. This information is stored locally on your device and is used solely for the purpose of providing you with our financial tracking services.',
            ),

            _buildSection(
              title: '2. How We Use Your Information',
              textColor: profileTextPrimary,
              secondaryColor: profileTextSecondary,
              content:
                  'Your information is used to:\n\n• Provide and maintain our services\n• Personalize your experience\n• Generate financial insights and reports\n• Communicate with you about updates\n• Ensure security and prevent fraud',
            ),

            _buildSection(
              title: '3. Data Storage and Security',
              textColor: profileTextPrimary,
              secondaryColor: profileTextSecondary,
              content:
                  'All your financial data is stored locally on your device using encrypted storage. We implement industry-standard security measures to protect your personal information. Your data is never shared with third parties without your explicit consent.',
            ),

            _buildSection(
              title: '4. Your Rights',
              textColor: profileTextPrimary,
              secondaryColor: profileTextSecondary,
              content:
                  'You have the right to:\n\n• Access your personal data\n• Correct inaccurate data\n• Delete your account and data\n• Export your data\n• Opt-out of communications',
            ),

            _buildSection(
              title: '5. Data Retention',
              textColor: profileTextPrimary,
              secondaryColor: profileTextSecondary,
              content:
                  'We retain your personal information for as long as your account is active or as needed to provide you services. You can request deletion of your account at any time through the app settings.',
            ),

            _buildSection(
              title: '6. Children\'s Privacy',
              textColor: profileTextPrimary,
              secondaryColor: profileTextSecondary,
              content:
                  'Our services are not intended for children under 13 years of age. We do not knowingly collect personal information from children under 13.',
            ),

            _buildSection(
              title: '7. Changes to Privacy Policy',
              textColor: profileTextPrimary,
              secondaryColor: profileTextSecondary,
              content:
                  'We may update this privacy policy from time to time. We will notify you of any changes by posting the new policy on this page and updating the "Last updated" date.',
            ),

            _buildSection(
              title: '8. Contact Us',
              textColor: profileTextPrimary,
              secondaryColor: profileTextSecondary,
              content:
                  'If you have any questions about this Privacy Policy, please contact us at:\n\nEmail: privacy@financecompanion.app\nAddress: Finance Companion, Inc.',
            ),

            const SizedBox(height: 40),

            // Accept button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: profileTextPrimary,
                  foregroundColor: profileBg,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'I Understand',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content, required Color textColor, required Color secondaryColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: secondaryColor,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
