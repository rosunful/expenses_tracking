
import 'package:expense_tracking/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  static const Color primaryGreen = Color(0xFF187A52);
  static const Color background = Color(0xFFF5F7F6);
  static const Color darkText = Color(0xFF202624);
  static const Color secondaryText = Color(0xFF727A76);

  @override
  Widget build(BuildContext context) {    

    return Scaffold(      
      appBar: AppBar(        
        elevation: 0,
        // centerTitle: true,
        title:  Text(
          'About Us',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon:  Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 19,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          child: Column(
            children: [
              _buildHeroSection(context),

              const SizedBox(height: 22),

              _buildAboutCard(context),

              const SizedBox(height: 26),

              _buildSectionTitle(
                title: 'What You Can Do',
                subtitle: 'Everything you need to manage your money.',
                context: context
              ),

              const SizedBox(height: 14),

              _buildFeatureGrid(context),

              const SizedBox(height: 26),

              _buildWhySection(context),

              const SizedBox(height: 26),

              _buildCompanyCard(context),

              const SizedBox(height: 24),

              _buildLinksSection(context),

              const SizedBox(height: 24),

            

              const Text(
                'Expense Tracker',
                style: TextStyle(
                  fontSize: 13,
                  color: secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // HERO
  // ------------------------------------------------------------

  Widget _buildHeroSection(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            color: primaryGreen,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: primaryGreen.withValues(alpha: 0.18),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.account_balance_wallet_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),

        const SizedBox(height: 16),

         Text(
          'Expense Tracker',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color:Theme.of(context).colorScheme.onSurface,
            letterSpacing: -0.4,
          ),
        ),

        const SizedBox(height: 7),

        Text(
          'Manage • Plan • Save',
          style: TextStyle(
            fontSize: 13,
            // color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 12),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Text(
            'A simple way to understand your expenses, '
            'manage your budget, and build better saving habits.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.55,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // ABOUT CARD
  // ------------------------------------------------------------

  Widget _buildAboutCard(BuildContext context) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(
            icon: Icons.info_outline_rounded,
            title: 'About the App', context: context,
          ),

          const SizedBox(height: 14),

          Text(
            'Expense Tracker is designed to help you keep track '
            'of your everyday financial activity in one place. '
            'You can record transactions, organize expenses into '
            'your own categories, create budgets, track saving goals, '
            'and understand how your money is flowing.',
            style: TextStyle(
              fontSize: 14,
              height: 1.65,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ), context: context,
    );
  }

  // ------------------------------------------------------------
  // SECTION TITLE
  // ------------------------------------------------------------

  Widget _buildSectionTitle({
    required String title,
    required String subtitle,
    required BuildContext context
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:  TextStyle(
              fontSize: 18,
              fontWeight: FontWeight(750),
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style:  TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // FEATURE GRID
  // ------------------------------------------------------------

  Widget _buildFeatureGrid(BuildContext context) {
    final features = [
      const _FeatureData(
        icon: Icons.receipt_long_rounded,
        title: 'Expense Tracking',
        description: 'Record and organize your everyday expenses.',
      ),
      const _FeatureData(
        icon: Icons.account_balance_wallet_rounded,
        title: 'Budget Planning',
        description: 'Set spending limits and stay on your plan.',
      ),
      const _FeatureData(
        icon: Icons.savings_rounded,
        title: 'Saving Goals',
        description: 'Create targets and follow your saving progress.',
      ),
      const _FeatureData(
        icon: Icons.notifications_active_rounded,
        title: 'Reminders',
        description: 'Remember important bills and recurring payments.',
      ),
      const _FeatureData(
        icon: Icons.category_rounded,
        title: 'Custom Categories',
        description: 'Create categories that fit your lifestyle.',
      ),
      const _FeatureData(
        icon: Icons.bar_chart_rounded,
        title: 'Expense Insights',
        description: 'Understand your spending through charts.',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: features
              .map(
                (feature) => SizedBox(
                  width: itemWidth,
                  child: _buildFeatureCard(feature , context),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildFeatureCard(_FeatureData feature, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.cardsBackground,
        borderRadius: BorderRadius.circular(18),
       
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: context.appColors.balanceCardSubtext,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              feature.icon,
              color:Theme.of(context).colorScheme.onSurface,
              size: 21,
            ),
          ),

          const SizedBox(height: 13),

          Text(
            feature.title,
            style:  TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color:Theme.of(context).colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            feature.description,
            style: TextStyle(
              fontSize: 11.5,
              height: 1.45,
              color:Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // WHY SECTION
  // ------------------------------------------------------------

  Widget _buildWhySection(BuildContext context) {
    return _card(
      color: primaryGreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: context.appColors.balanceCardSubtext,
                  borderRadius: BorderRadius.circular(13),
                ),
                child:  Icon(
                  Icons.lightbulb_outline_rounded,
                  color:Theme.of(context).colorScheme.onSurface,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Why We Built This',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: const FontWeight(750),
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

           Text(
            'Managing money can become difficult when everyday '
            'expenses, bills, subscriptions, and savings are spread '
            'across different places. Our goal is to bring these '
            'activities together in one simple and easy-to-understand '
            'experience.',
            style: TextStyle(
              fontSize: 13.5,
              height: 1.65,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ), context: context,
    );
  }

  // ------------------------------------------------------------
  // COMPANY
  // ------------------------------------------------------------

  Widget _buildCompanyCard(BuildContext context) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(
            icon: Icons.business_rounded,
            title: 'Developed By', context: context,
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: primaryGreen.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Image.asset('assets/images/logo.png')
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                      'Luminious Technology Pvt. Ltd.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Pokhara, Shrijana Chowk, Nepal',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

           Text(
            'Building technology solutions with a focus on '
            'useful, accessible and practical digital experiences.',
            style: TextStyle(
              fontSize: 13,
              height: 1.55,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ), context: context,
    );
  }

  // ------------------------------------------------------------
  // LINKS
  // ------------------------------------------------------------

  Widget _buildLinksSection(BuildContext context) {
    return _card(
      child: Column(
        children: [
          _buildActionTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {
              // Navigate to Privacy Policy
            },
          ),

          const Divider(
            height: 1,
            color: Color(0xFFE9EDEA),
          ),

          _buildActionTile(
            icon: Icons.description_outlined,
            title: 'Terms & Conditions',
            onTap: () {
              // Navigate to Terms & Conditions
            },
          ),

          const Divider(
            height: 1,
            color: Color(0xFFE9EDEA),
          ),

          _buildActionTile(
            icon: Icons.mail_outline_rounded,
            title: 'Contact Us',
            onTap: () {
              // Open contact/support
            },
          ),
        ],
      ), context: context,
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 13,
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: primaryGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                icon,
                size: 19,
                color: primaryGreen,
              ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: darkText,
                ),
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 15,
              color: Color(0xFF8A928E),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // REUSABLE CARD
  // ------------------------------------------------------------

  Widget _card({
    required Widget child,
    Color color = Colors.white,
    required BuildContext context,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:context.appColors.cardsBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  // ------------------------------------------------------------
  // CARD TITLE
  // ------------------------------------------------------------

  Widget _cardTitle({
    required IconData icon,
    required String title,
    required BuildContext context
  }) {
    return Row(
      children: [     


        Text(
          title,
          style:  TextStyle(
            fontSize: 16,
            fontWeight: FontWeight(750),
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _FeatureData {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureData({
    required this.icon,
    required this.title,
    required this.description,
  });
}









