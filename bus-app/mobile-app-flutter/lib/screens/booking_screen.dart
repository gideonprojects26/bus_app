import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../models/backend_route_model.dart';
import '../models/booking_model.dart';
import '../services/route_service.dart';
import '../widgets/app_price_text.dart';
import '../widgets/app_back_button.dart';
import 'payment_method_screen.dart';

/// Screen allowing passengers to configure tour booking details
/// such as route, pickup location, date, time, passenger count, and pricing tier.
class BookingScreen extends StatefulWidget {
  // Optional preselected route ID passed from previous screens (e.g., RoutesScreen)
  final String? preselectedRouteId;

  const BookingScreen({super.key, this.preselectedRouteId});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // Master list of available tour routes fetched from backend API
  List<BackendRoute> _routes = [];
  bool _isLoadingRoutes = true;
  String? _loadError;

  // Selected user options state
  BackendRoute? _selectedRoute;
  Map<String, dynamic>? _selectedStop;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _passengers = 1;
  bool _isLocal = true; // Flag distinguishing local (UGX) vs international (USD) fare

  @override
  void initState() {
    super.initState();
    // Load available route data on screen initialization
    _loadRoutes();
  }

  /// Fetches tour routes from the route service and auto-selects a route if preselectedRouteId was passed.
  Future<void> _loadRoutes() async {
    try {
      final routes = await RouteService.fetchRoutes();
      setState(() {
        _routes = routes;
        _isLoadingRoutes = false;
        if (widget.preselectedRouteId != null) {
          // Preselect requested route or fallback to first available
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

  // Calculates estimated price based on passenger type (local vs international) and count.
  // Note: Backend recalculates authoritative price on payment submission.
  double get _estimatedPrice {
    if (_selectedRoute == null) return 0;
    final rate = _isLocal ? _selectedRoute!.fare : _selectedRoute!.internationalFare;
    return rate * _passengers;
  }

  // Returns active currency string based on user category
  String get _currency => _isLocal ? 'UGX' : 'USD';

  /// Opens native DatePicker to select travel date
  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 180)),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  /// Opens native TimePicker to select departure time
  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  /// Validates whether all mandatory fields have been filled
  bool get _canContinue =>
      _selectedRoute != null &&
      _selectedStop != null &&
      _selectedDate != null &&
      _selectedTime != null &&
      _passengers > 0;

  /// Bundles booking state into a draft object and navigates to the Payment screen
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
                        // --- Section: Route Dropdown ---
                        const Text('Route', style: TextStyle(color: AppColors.grey, fontSize: 12)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<BackendRoute>(
                          initialValue: _selectedRoute,
                          dropdownColor: AppColors.black2,
                          style: const TextStyle(color: AppColors.white),
                          decoration: const InputDecoration(hintText: 'Select a route'),
                          // Explicitly typed DropdownMenuItem list to prevent type mismatches
                          items: _routes.map<DropdownMenuItem<BackendRoute>>((r) {
                            return DropdownMenuItem<BackendRoute>(
                              value: r,
                              child: Text(r.name),
                            );
                          }).toList(),
                          onChanged: (value) => setState(() {
                            _selectedRoute = value;
                            _selectedStop = null; // Reset selected stop when route changes
                          }),
                        ),
                        const SizedBox(height: 18),

                        // --- Section: Pickup Stop Dropdown ---
                        const Text('Pickup Stop', style: TextStyle(color: AppColors.grey, fontSize: 12)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<Map<String, dynamic>>(
                          initialValue: _selectedStop,
                          dropdownColor: AppColors.black2,
                          style: const TextStyle(color: AppColors.white),
                          decoration: const InputDecoration(hintText: 'Select pickup stop'),
                          // Maps over stops of the selected route safely
                          items: (_selectedRoute?.stops ?? []).map<DropdownMenuItem<Map<String, dynamic>>>((stop) {
                            final Map<String, dynamic> stopMap = stop is Map<String, dynamic> 
                                ? stop 
                                : Map<String, dynamic>.from(stop as Map);
                            return DropdownMenuItem<Map<String, dynamic>>(
                              value: stopMap,
                              child: Text(stopMap['name']?.toString() ?? ''),
                            );
                          }).toList(),
                          onChanged: _selectedRoute == null ? null : (value) => setState(() => _selectedStop = value),
                        ),
                        const SizedBox(height: 18),

                        // --- Section: Date and Time Selectors ---
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

                        // --- Section: Passengers Counter ---
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

                        // --- Section: Local / International Toggle ---
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

                        // --- Section: Total Price Card ---
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

                        // --- Section: Continue Button ---
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

/// Helper tile widget for Date and Time input fields
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

/// Helper widget for rendering Local/International toggle buttons
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