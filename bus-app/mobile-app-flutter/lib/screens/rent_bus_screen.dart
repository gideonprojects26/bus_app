import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/auth_provider.dart';
import '../services/rental_service.dart';
import '../widgets/app_back_button.dart';

class RentBusScreen extends StatefulWidget {
  const RentBusScreen({super.key});

  @override
  State<RentBusScreen> createState() => _RentBusScreenState();
}

class _RentBusScreenState extends State<RentBusScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passengersController = TextEditingController();
  final _messageController = TextEditingController();
  DateTime? _neededDate;
  bool _isSubmitting = false;

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => _neededDate = date);
  }

  Future<void> _submitInquiry() async {
    if (!_formKey.currentState!.validate() || _neededDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields and select a date')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await RentalService.submitRentalRequest(
      token: authProvider.token!,
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      passengerCount: int.parse(_passengersController.text.trim()),
      neededDate: _neededDate!,
      additionalDetails: _messageController.text.trim(),
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rental inquiry submitted. Our team will contact you shortly.')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Something went wrong. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const AppBackButton(), title: const Text('Rent a Bus')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---- Guarantee Badge (adapted from FlutterFlow component) ----
                // Replaces FlutterFlowTheme with AppColors and standard Text styles
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.black2, // Using your app's dark surface color instead of secondaryBackground
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Circular icon container with yellow accent background
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.yellow.withAlpha(38), // ~15% opacity yellow (0x26 in hex)
                            borderRadius: BorderRadius.circular(9999), // Fully rounded
                          ),
                          alignment: const AlignmentDirectional(0, 0), // Center the icon
                          child: const Icon(
                            Icons.verified_user_rounded,
                            color: AppColors.yellow, // Using your yellow as the icon color
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16), // Replaces .divide(SizedBox(width: 16))
                        // Text column
                        const Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start, // Changed from center to start for better alignment
                            children: [
                              Text(
                                'Pearl Premium Guarantee',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 14, // Approximate labelLarge size
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.0,
                                  height: 1.4,
                                ),
                              ),
                              SizedBox(height: 4), // Replaces .divide(SizedBox(height: 4))
                              Text(
                                'All rentals include a professional driver and comprehensive travel insurance.',
                                style: TextStyle(
                                  color: AppColors.grey, // Using grey for secondary text
                                  fontSize: 12, // Approximate bodySmall size
                                  fontWeight: FontWeight.normal,
                                  letterSpacing: 0.0,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24), // Spacing after the badge before the form fields
                
                // ---- Original form fields ----
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: AppColors.white),
                  decoration: const InputDecoration(hintText: 'Full Name'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _phoneController,
                  style: const TextStyle(color: AppColors.white),
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(hintText: 'Phone Number'),
                  validator: (v) => (v == null || v.length < 9) ? 'Enter a valid phone number' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _passengersController,
                  style: const TextStyle(color: AppColors.white),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Number of Passengers'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.black2, borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, color: AppColors.yellow, size: 18),
                        const SizedBox(width: 10),
                        Text(
                          _neededDate == null ? 'Select date needed' : '${_neededDate!.day}/${_neededDate!.month}/${_neededDate!.year}',
                          style: const TextStyle(color: AppColors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _messageController,
                  style: const TextStyle(color: AppColors.white),
                  maxLines: 4,
                  decoration: const InputDecoration(hintText: 'Additional details (optional)'),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitInquiry,
                    child: _isSubmitting
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.black))
                        : const Text('Submit Inquiry'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}