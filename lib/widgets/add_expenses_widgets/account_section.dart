import 'package:flutter/material.dart';

class AccountSection extends StatelessWidget {
  final String selectedAccount;
  final ValueChanged<String> onSelected;

  const AccountSection({
    super.key,
    required this.selectedAccount,
    required this.onSelected,
  });

  final List<String> accounts = const ["Cash", "Bank", "Card"];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "ACCOUNT",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 10,
            letterSpacing: 0.7,
          ),
        ),

        const SizedBox(height: 8),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: accounts.map((account) {
            final bool isSelected = account == selectedAccount;

            return GestureDetector(
              onTap: () => onSelected(account),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF1C6B47)
                      : const Color(0xFFF1F5F2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  account,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF26332C),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
