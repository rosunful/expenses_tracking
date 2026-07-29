import 'package:flutter/material.dart';



class AccountSection extends StatelessWidget {
  final String selectedAccount;
  final ValueChanged<String> onSelected;

  const AccountSection({
    super.key,
    required this.selectedAccount,
    required this.onSelected,
  });

  final List<String> accounts = const [
    "Cash",
    "Bank",
    "Card",
    "Wallet",
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "ACCOUNT",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: accounts.map((account) {
            final bool isSelected = account == selectedAccount;

            return GestureDetector(
              onTap: () => onSelected(account),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blue
                      : Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  account,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Colors.black87,
                    fontWeight: FontWeight.w600,
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