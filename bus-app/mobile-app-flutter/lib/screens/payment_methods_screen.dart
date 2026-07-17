import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/app_back_button.dart';
import '../widgets/app_card_shadow.dart';

class SavedPaymentMethod {
  final String type; // 'MTN Mobile Money', 'Airtel Money', 'Credit Card'
  final String label; // e.g. masked number or phone

  SavedPaymentMethod({required this.type, required this.label});
}

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

  void _showAddMethodSheet() {
    String selectedType = 'MTN Mobile Money';
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
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
                  const Text('Add Payment Method',
                      style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    dropdownColor: const Color(0xFF1A1A1A),
                    style: const TextStyle(color: AppColors.white),
                    items: ['MTN Mobile Money', 'Airtel Money', 'Credit Card']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (value) => setModalState(() => selectedType = value!),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: controller,
                    style: const TextStyle(color: AppColors.white),
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
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        child: Text('No payment methods saved yet.', style: TextStyle(color: AppColors.grey)),
                      )
                    : ListView.builder(
                        itemCount: _methods.length,
                        itemBuilder: (context, index) {
                          final method = _methods[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
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
                                      Text(method.type,
                                          style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                                      const SizedBox(height: 2),
                                      Text(method.label, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
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