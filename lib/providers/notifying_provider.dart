import 'package:expense_tracking/theme/app_navigation.dart';
import 'package:flutter/material.dart';

class NotifyingProvider extends ChangeNotifier {
  OverlayEntry? _overlayEntry;

  void showMessage(
    String message, {
    bool isError = false,
  }) {
    final overlay = appNavigatorKey.currentState?.overlay;

    if (overlay == null) {
      debugPrint('Overlay is null');
      return;
    }

    // Remove previous notification if one is already showing.
    _overlayEntry?.remove();
    _overlayEntry = null;

    final entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: MediaQuery.of(context).padding.top + 14,
          left: 16,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: isError
                    ? Colors.red.shade50
                    : Colors.green.shade50,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    isError
                        ? Icons.error_outline
                        : Icons.check_circle_outline,
                    color: isError
                        ? Colors.red
                        : const Color(0xFF1C6B47),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(
                        color: isError
                            ? Colors.red.shade700
                            : const Color(0xFF1C6B47),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    _overlayEntry = entry;

    overlay.insert(entry);

    Future.delayed(
      const Duration(seconds: 2),
      () {
        if (_overlayEntry == entry) {
          entry.remove();
          _overlayEntry = null;
        }
      },
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }
}