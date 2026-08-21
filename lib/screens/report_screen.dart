import 'package:expense_tracking/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ReportProblemScreen extends StatefulWidget {
  const ReportProblemScreen({super.key});

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  Color get primaryGreem => context.appColors.balanceCardBackground;
  static const Color primaryGreen = Color(0xFF187A52);
  static const Color textPrimary = Color(0xFF202624);
  static const Color textSecondary = Color(0xFF727A76);
  static const Color borderColor = Color(0xFFE7EBE9);

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController =
      TextEditingController();

  int _selectedType = 0;

  final List<_ReportType> _reportTypes = const [
    _ReportType(
      icon: Icons.bug_report_outlined,
      title: 'Bug',
      subtitle: 'Something is broken',
    ),
    _ReportType(
      icon: Icons.error_outline_rounded,
      title: 'Problem',
      subtitle: 'Something is not right',
    ),
    _ReportType(
      icon: Icons.lightbulb_outline_rounded,
      title: 'Suggestion',
      subtitle: 'Improve an existing feature',
    ),
    _ReportType(
      icon: Icons.auto_awesome_outlined,
      title: 'Idea',
      subtitle: 'Suggest something new',
    ),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(      
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon:  Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 19,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        title:  Text(
          'Report & Feedback',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIntroduction(),

                const SizedBox(height: 28),

                _buildSectionTitle(
                  'What would you like to report?',
                ),

                const SizedBox(height: 14),

                _buildReportTypeSelector(),

                const SizedBox(height: 28),

                _buildSectionTitle(
                  'Tell us more',
                  subtitle:
                      'Please provide enough detail so we can understand your feedback.',
                ),

                const SizedBox(height: 14),

                _buildInputCard(),

                const SizedBox(height: 22),

                _buildAttachmentCard(),

                const SizedBox(height: 28),

                _buildSubmitButton(),

                const SizedBox(height: 14),

                const Center(
                  child: Text(
                    'Your feedback helps us make Expense Tracker better.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INTRODUCTION
  // ============================================================

  Widget _buildIntroduction() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: context.appColors.balanceCardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child:  Icon(
              Icons.forum_outlined,
              color: Theme.of(context).colorScheme.onSurface,
              size: 23,
            ),
          ),

          const SizedBox(width: 13),

           Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'We want to hear from you',
                  style: TextStyle(
                    color: context.appColors.balanceCardText,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                SizedBox(height: 7),

                Text(
                  'Found a bug, ran into a problem, or have an thought '
                  'that could make the app better? Tell us about it.',
                  style: TextStyle(
                    color:context.appColors.balanceCardText,
                    fontSize: 12.8,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(
    String title, {
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight(750),
            color: textPrimary,
            letterSpacing: -0.2,
          ),
        ),

        if (subtitle != null) ...[
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  // ============================================================
  // REPORT TYPE
  // ============================================================

  Widget _buildReportTypeSelector() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(
            _reportTypes.length,
            (index) {
              final type = _reportTypes[index];

              return SizedBox(
                width: width,
                child: _buildReportTypeCard(
                  index: index,
                  type: type,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildReportTypeCard({
    required int index,
    required _ReportType type,
  }) {
    final selected = _selectedType == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: selected
              ? primaryGreen.withValues(alpha: 0.07)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? primaryGreen : borderColor,
            width: selected ? 1.4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: selected ? 0.04 : 0.025,
              ),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 41,
                  height: 41,
                  decoration: BoxDecoration(
                    color: selected
                        ? primaryGreen
                        : primaryGreen.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    type.icon,
                    size: 20,
                    color: selected ? Colors.white : primaryGreen,
                  ),
                ),

                const Spacer(),

                if (selected)
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 20,
                    color: primaryGreen,
                  ),
              ],
            ),

            const SizedBox(height: 13),

            Text(
              type.title,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              type.subtitle,
              style: const TextStyle(
                fontSize: 11.5,
                height: 1.35,
                color: textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INPUTS
  // ============================================================

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTextField(
            controller: _titleController,
            label: 'Title',
            hintText: _getTitleHint(),
            maxLines: 1,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a title';
              }

              return null;
            },
          ),

          const SizedBox(height: 16),

          _buildTextField(
            controller: _descriptionController,
            label: 'Description',
            hintText: _getDescriptionHint(),
            maxLines: 7,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please describe the issue or feedback';
              }

              if (value.trim().length < 10) {
                return 'Please provide a little more detail';
              }

              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required int maxLines,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight(650),
            color: textPrimary,
          ),
        ),

        const SizedBox(height: 8),

        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          textCapitalization: TextCapitalization.sentences,
          style: const TextStyle(
            fontSize: 13.5,
            color: textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              fontSize: 13,
              color: Color(0xFFA0A7A3),
            ),
            filled: true,
            fillColor: const Color(0xFFF8F9F9),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(
                color: borderColor,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(
                color: borderColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(
                color: primaryGreen,
                width: 1.3,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(
                color: Color(0xFFE5484D),
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(
                color: Color(0xFFE5484D),
                width: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ATTACHMENT
  // ============================================================

  Widget _buildAttachmentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.attach_file_rounded,
                size: 19,
                color: primaryGreen,
              ),

              SizedBox(width: 8),

              Text(
                'Attachment',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),

              Spacer(),

              Text(
                'Optional',
                style: TextStyle(
                  fontSize: 11,
                  color: textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          GestureDetector(
            onTap: _pickAttachment,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 15,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9F9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: borderColor,
                ),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 27,
                    color: primaryGreen,
                  ),

                  SizedBox(height: 8),

                  Text(
                    'Add a screenshot or image',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),

                  SizedBox(height: 4),

                  Text(
                    'A screenshot can help us understand the problem faster.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 53,
      child: ElevatedButton(
        onPressed: _submitReport,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.send_rounded,
              size: 19,
            ),

            SizedBox(width: 9),

            Text(
              'Send Report',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _getTitleHint() {
    switch (_selectedType) {
      case 0:
        return 'Example: Expense total is incorrect';
      case 1:
        return 'Example: Unable to create a budget';
      case 2:
        return 'Example: Improve the transaction screen';
      case 3:
        return 'Example: Add recurring income tracking';
      default:
        return 'Enter a title';
    }
  }

  String _getDescriptionHint() {
    switch (_selectedType) {
      case 0:
        return 'What happened? What did you expect to happen?';
      case 1:
        return 'Tell us what problem you are experiencing and when it occurs.';
      case 2:
        return 'Tell us how you think this feature could be improved.';
      case 3:
        return 'Describe your idea and how you think it could help.';
      default:
        return 'Tell us more about your feedback.';
    }
  }

  void _pickAttachment() {
    // Later:
    // Use image_picker or file_picker here.
  }

  void _submitReport() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final reportType = _reportTypes[_selectedType].title;

    debugPrint('Report Type: $reportType');
    debugPrint('Title: ${_titleController.text}');
    debugPrint('Description: ${_descriptionController.text}');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Thank you. Your feedback has been submitted.',
        ),
        backgroundColor: primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _ReportType {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ReportType({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}