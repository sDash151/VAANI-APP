import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/page_header.dart';
import '../../widgets/expansion_card.dart';
import '../../widgets/contact_option.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: "Help & Support",
                onBackPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    Text(
                      "Frequently Asked Questions",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(
                      5,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: ExpansionCard(
                          title: "How do I reset my password?",
                          content: "Answer goes here...",
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Contact Us",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                    ),
                    const SizedBox(height: 16),
                    ContactOption(
                      icon: Icons.email,
                      title: "Email",
                      subtitle: "support@bswl.com",
                    ),
                    ContactOption(
                      icon: Icons.phone,
                      title: "Phone",
                      subtitle: "+1 234 567 890",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
