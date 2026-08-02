import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/app_back_button.dart';
import '../widgets/app_card_shadow.dart';

/// Model representing a saved payment method (Mobile Money or Credit Card).
class SavedPaymentMethod {
  final String type; // 'MTN Mobile Money', 'Airtel Money', 'Credit Card'
  final String label; // e.g. masked number or phone

  SavedPaymentMethod({required this.type, required this.label});
}

/// Screen for managing saved payment methods — viewing, adding, and removing
/// Mobile Money accounts and Credit Cards.
///
/// THEME: Converted to be theme-aware (light/dark). Uses ThemeProvider for
/// surface colors and text colors instead of hardcoded Color(0xFF1A1A1A)/AppColors.white.
class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final List<SavedPaymentMethod> _methods = [
    SavedPaymentMethod(type: 'MTN Mobile Money', label: '+256 7XX XXX 214'),
    SavedPaymentMethod(type: 'Credit Card', label: 'Visa ending in 4821'),
  ];

  void _removeMethod(int index) {
    setState(() => _methods.removeAt(index));
  }

  /// Opens a bottom sheet modal for adding a new payment method.
  /// Now accesses ThemeProvider directly since it's launched from a callback
  /// and needs its own theme context.
  void _showAddMethodSheet() {
    String selectedType = 'MTN Mobile Money';
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Let the inner container control color
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Access theme inside the bottom sheet's own context
        final theme = context.watch<ThemeProvider>();

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: theme.surfaceElevated, // was Color(0xFF1A1A1A) — now theme-aware (elevated for modal)
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Payment Method',
                      style: TextStyle(color: theme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold), // was AppColors.white — now theme-aware
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedType,
                      dropdownColor: theme.surfaceElevated, // was Color(0xFF1A1A1A) — now theme-aware
                      style: TextStyle(color: theme.textPrimary), // was AppColors.white — now theme-aware
                      items: ['MTN Mobile Money', 'Airtel Money', 'Credit Card']
                          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (value) => setModalState(() => selectedType = value!),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: controller,
                      style: TextStyle(color: theme.textPrimary), // was AppColors.white — now theme-aware
                      decoration: InputDecoration(
                        hintText: selectedType == 'Credit Card' ? 'Card number' : 'Phone number',
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (controller.text.isEmpty) return;
                          setState(() {
                            _methods.add(SavedPaymentMethod(type: selectedType, label: controller.text));
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Add Method'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Access theme provider for light/dark mode aware colors
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: theme.background, // now theme-aware
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Payment Methods'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _methods.isEmpty
                    ? const Center(
                        child: Text(
                          'No payment methods saved yet.',
                          style: TextStyle(color: AppColors.grey), // grey stays as static accent
                        ),
                      )
                    : ListView.builder(
                        itemCount: _methods.length,
                        itemBuilder: (context, index) {
                          final method = _methods[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.surface, // was Color(0xFF1A1A1A) — now theme-aware
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: AppCardShadow.soft,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  method.type == 'Credit Card' ? Icons.credit_card : Icons.phone_android,
                                  color: AppColors.yellow,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        method.type,
                                        style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13), // was AppColors.white — now theme-aware
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        method.label,
                                        style: const TextStyle(color: AppColors.grey, fontSize: 12), // grey stays as static accent
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.red),
                                  onPressed: () => _removeMethod(index),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showAddMethodSheet,
                  child: const Text('+ Add Payment Method'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}