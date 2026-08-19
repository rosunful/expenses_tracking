import 'package:expense_tracking/models/currency_model.dart';
import 'package:expense_tracking/repositories/currency_repository.dart';
import 'package:expense_tracking/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CurrencySelectionScreen extends StatefulWidget {
  const CurrencySelectionScreen({super.key});

  @override
  State<CurrencySelectionScreen> createState() => _CurrencySelectionScreenState();
}

class _CurrencySelectionScreenState extends State<CurrencySelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CurrencyModel> get _filtered {
    if (_query.trim().isEmpty) return supportedCurrencies;
    final q = _query.trim().toLowerCase();
    return supportedCurrencies
        .where((c) =>
            c.countryName.toLowerCase().contains(q) || 
            c.code.toLowerCase().contains(q) ||
            c.symbol.contains(q))
        .toList();
  }

  Future<void> _select(CurrencyModel currency) async {
    if (_isLoading) return; // Prevent multiple taps
    
    setState(() => _isLoading = true);
    
    try {
      await context.read<CurrencyProvider>().setCurrency(currency);
      if (mounted) {
        // Use pop with a small delay to ensure smooth transition
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) Navigator.of(context).pop(currency);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting currency: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedCode = context.watch<CurrencyProvider>().selected.code;
    final results = _filtered;

    return Scaffold(
      
      appBar: AppBar(
        leading: IconButton(
          icon:  Icon(Icons.arrow_back_ios, color:Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Select Currency',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color:Theme.of(context).colorScheme.onSurface,
          ),
        ),
        
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar - Matching the design theme
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Container(
                decoration: BoxDecoration(
                 color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search country or currency code',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 15,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey.shade600,
                      size: 22,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),
            
            // Results count
            if (results.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${results.length} currencies found',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            
            const SizedBox(height: 8),
            
            // Currency List - Enhanced design
            Expanded(
              child: results.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 60,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No currencies match your search',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final currency = results[index];
                        final isSelected = currency.code == selectedCode;
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Material(
                            color: isSelected 
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () => _select(currency),
                              splashColor: const Color(0xFF1C6B47).withOpacity(0.1),
                              highlightColor: const Color(0xFF1C6B47).withOpacity(0.05),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                child: Row(
                                  children: [
                                    // Currency Symbol Circle
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFF1C6B47)
                                            : Theme.of(context).colorScheme.primary,
                                        borderRadius: BorderRadius.circular(19),
                                      ),
                                      child: Center(
                                        child: Text(
                                          currency.symbol,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    
                                    // Country and Currency Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            currency.countryName,
                                            style:  TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: isSelected 
                                              ? Colors.white
                                              : Theme.of(context).colorScheme.onSurface
                                              
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            currency.code,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: isSelected ? Colors.black54 :  Colors.grey.shade600,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // Selection indicator
                                    if (isSelected)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1C6B47),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Icon(
                                            //   Icons.check_circle,
                                            //   color: Colors.white,
                                            //   size: 16,
                                            // ),
                                            // SizedBox(width: 4),
                                            Text(
                                              'Selected',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    // else
                                    //   Text(
                                    //     currency.symbol,
                                    //     style: TextStyle(
                                    //       fontSize: 18,
                                    //       color: Colors.grey.shade400,
                                    //     ),
                                    //   ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

































// import 'package:expense_tracking/models/currency_model.dart';
// import 'package:expense_tracking/repositories/currency_repository.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class CurrencySelectionScreen extends StatefulWidget {
//   const CurrencySelectionScreen({super.key});

//   @override
//   State<CurrencySelectionScreen> createState() => _CurrencySelectionScreenState();
// }

// class _CurrencySelectionScreenState extends State<CurrencySelectionScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   String _query = '';

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   List<CurrencyModel> get _filtered {
//     if (_query.trim().isEmpty) return supportedCurrencies;
//     final q = _query.trim().toLowerCase();
//     return supportedCurrencies
//         .where((c) =>
//             c.countryName.toLowerCase().contains(q) || c.code.toLowerCase().contains(q))
//         .toList();
//   }

//   Future<void> _select(CurrencyModel currency) async {
//     await context.read<CurrencyProvider>().setCurrency(currency);
//     if (mounted) Navigator.of(context).pop();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final selectedCode = context.watch<CurrencyProvider>().selected.code;
//     final results = _filtered;

//     return Scaffold(
//       appBar: AppBar(
//         leading: const BackButton(),
//         title: const Text('Select Currency', style: TextStyle(fontWeight: FontWeight.bold)),
//         elevation: 0,
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: TextField(
//                 controller: _searchController,
//                 onChanged: (value) => setState(() => _query = value),
//                 decoration: InputDecoration(
//                   hintText: 'Search country or currency code',
//                   prefixIcon: const Icon(Icons.search),
//                   filled: true,
//                   fillColor: const Color(0xFFF1F5F2),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                     borderSide: const BorderSide(color: Color(0xFFDCE5DF)),
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                     borderSide: const BorderSide(color: Color(0xFFDCE5DF)),
//                   ),
//                 ),
//               ),
//             ),
//             Expanded(
//               child: results.isEmpty
//                   ? const Center(
//                       child: Text('No currencies match your search', style: TextStyle(color: Colors.black45)),
//                     )
//                   : ListView.separated(
//                       itemCount: results.length,
//                       separatorBuilder: (_, _) => const Divider(height: 1),
//                       itemBuilder: (context, index) {
//                         final currency = results[index];
//                         final isSelected = currency.code == selectedCode;
//                         return ListTile(
//                           title: Text(currency.countryName),
//                           subtitle: Text(currency.code),
//                           trailing: isSelected
//                               ? const Icon(Icons.check_circle, color: Color(0xFF1C6B47))
//                               : Text(
//                                   currency.symbol,
//                                   style: const TextStyle(fontSize: 16, color: Colors.black54),
//                                 ),
//                           onTap: () => _select(currency),
//                         );
//                       },
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }