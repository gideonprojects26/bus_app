import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../models/backend_route_model.dart';
import '../models/booking_model.dart';
import '../services/route_service.dart';
import '../widgets/app_price_text.dart';
import '../widgets/app_back_button.dart';
import 'payment_method_screen.dart';

class BookingScreen extends StatefulWidget {
  final String? preselectedRouteId;

  const BookingScreen({super.key, this.preselectedRouteId});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  List<BackendRoute> _routes = [];
  bool _isLoadingRoutes = true;
  String? _loadError;

  BackendRoute? _selectedRoute;
  Map<String, dynamic>? _selectedStop;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _passengers = 1;
  bool _isLocal = true;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    try {
      final routes = await RouteService.fetchRoutes();
      setState(() {
        _routes = routes;
        _isLoadingRoutes = false;
        if (widget.preselectedRouteId != null) {
          _selectedRoute = routes.firstWhere(
            (r) => r.id == widget.preselectedRouteId,
            orElse: () => routes.first,
          );
        }
      });
    } catch (e) {
      setState(() {
        _loadError = 'Could not load routes. Check your connection and try again.';
        _isLoadingRoutes = false;
      });
    }
  }

  // This is an ESTIMATE shown to the user for convenience only — the
  // backend recalculates the authoritative total from the Route record
  // when payment is initiated, so this number can never be tampered
  // with to actually change what gets charged.
  double get _estimatedPrice {
    if (_selectedRoute == null) return 0;
    final rate = _isLocal ? _selectedRoute!.fare : _selectedRoute!.internationalFare;
    return rate * _passengers;
  }

  String get _currency => _isLocal ? 'UGX' : 'USD';

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 180)),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  bool get _canContinue =>
      _selectedRoute != null &&
      _selectedStop != null &&
      _selectedDate != null &&
      _selectedTime != null &&
      _passengers > 0;

  void _continueToPayment() {
    if (!_canContinue) return;

    final draft = BookingDraft(
      routeId: _selectedRoute!.id,
      routeName: _selectedRoute!.name,
      pickupStop: _selectedStop!['name'],
      date: _selectedDate!,
      time: _selectedTime!.format(context),
      passengers: _passengers,
      isLocal: _isLocal,
      totalPrice: _estimatedPrice,
      currency: _currency,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PaymentMethodScreen(draft: draft)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Book a Tour'),
      ),
      body: SafeArea(
        child: _isLoadingRoutes
            ? const Center(child: CircularProgressIndicator(color: AppColors.yellow))
            : _loadError != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_loadError!, style: const TextStyle(color: AppColors.grey), textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(onPressed: _loadRoutes, child: const Text('Retry')),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Route', style: TextStyle(color: AppColors.grey, fontSize: 12)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<BackendRoute>(
                          initialValue: _selectedRoute,
                          dropdownColor: AppColors.black2,
                          style: const TextStyle(color: AppColors.white),
                          decoration: const InputDecoration(hintText: 'Select a route'),
                          items: _routes.map((r) => DropdownMenuItem(value: r, child: Text(r.name))).toList(),
                          onChanged: (value) => setState(() {
                            _selectedRoute = value;
                            _selectedStop = null;
                          }),
                        ),
                        const SizedBox(height: 18),
                        const Text('Pickup Stop', style: TextStyle(color: AppColors.grey, fontSize: 12)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<Map<String, dynamic>>(
                          initialValue: _selectedStop,
                          dropdownColor: AppColors.black2,
                          style: const TextStyle(color: AppColors.white),
                          decoration: const InputDecoration(hintText: 'Select pickup stop'),
                          items: (_selectedRoute?.stops ?? [])
                              .map((s) => DropdownMenuItem(value: s, child: Text(s['name'])))
                              .toList(),
                          onChanged: _selectedRoute == null ? null : (value) => setState(() => _selectedStop = value),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: _SelectorTile(
                                label: 'Date',
                                value: _selectedDate == null ? 'Select date' : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                                icon: Icons.calendar_today_outlined,
                                onTap: _pickDate,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _SelectorTile(
                                label: 'Time',
                                value: _selectedTime == null ? 'Select time' : _selectedTime!.format(context),
                                icon: Icons.access_time,
                                onTap: _pickTime,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const Text('Passengers', style: TextStyle(color: AppColors.grey, fontSize: 12)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: AppColors.black2, borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('$_passengers', style: const TextStyle(color: AppColors.white, fontSize: 16)),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: AppColors.yellow),
                                    onPressed: _passengers > 1 ? () => setState(() => _passengers--) : null,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, color: AppColors.yellow),
                                    onPressed: () => setState(() => _passengers++),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text('Passenger Type', style: TextStyle(color: AppColors.grey, fontSize: 12)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(child: _TypeToggle(label: 'Local', isSelected: _isLocal, onTap: () => setState(() => _isLocal = true))),
                            const SizedBox(width: 12),
                            Expanded(child: _TypeToggle(label: 'International', isSelected: !_isLocal, onTap: () => setState(() => _isLocal = false))),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.yellow.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.amber.withValues(alpha: 0.4)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Estimated Total', style: TextStyle(color: AppColors.grey, fontSize: 12)),
                              const SizedBox(height: 4),
                              AppPriceText(currency: _currency, amount: _estimatedPrice, isLocal: _isLocal),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _canContinue ? _continueToPayment : null,
                            child: const Text('Continue to Payment'),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

class _SelectorTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _SelectorTile({required this.label, required this.value, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.black2, borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(icon, color: AppColors.yellow, size: 16), const SizedBox(width: 6), Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 12))]),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(color: AppColors.white, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _TypeToggle extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeToggle({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.yellow : AppColors.black2,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? AppColors.black : AppColors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}