import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/booking_provider.dart';
import '../providers/theme_provider.dart';
import '../models/booking_model.dart';
import '../services/cache_service.dart';
import '../widgets/app_pill_button.dart';
import '../widgets/app_icon_avatar.dart';
import 'routes_screen.dart';
import 'receipt_screen.dart';

/// Screen displaying user's booking activity across four tabs:
/// Bookings, Pending, Completed, Cancelled.
///
/// DATA: Uses offline-first approach — loads bookings from local
/// SQLite cache instantly, then fetches fresh data from backend
/// via BookingProvider. If the fetch succeeds and data differs,
/// the cache is updated. Works fully offline.
///
/// THEME: Converted to be theme-aware (light/dark). Uses ThemeProvider for
/// surface colors and text colors instead of hardcoded Color(0xFF1A1A1A)/AppColors.white.
class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  @override
  void initState() {
    super.initState();

    // Load bookings using offline-first cache.
    // WidgetsBinding guarantees the widget is fully built before
    // we make provider calls, preventing "Cannot update Provider
    // during build" exceptions.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBookings();
    });
  }

  /// Loads bookings from local SQLite cache first (instant, works offline),
  /// then fetches fresh data from the backend via BookingProvider.
  /// If the backend returns different data, the cache is updated
  /// and the UI refreshes automatically.
  Future<void> _loadBookings() async {
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);

    // Step 1: Try loading from cache first — instant display
    try {
      final cachedBookings = await CacheService.getBookings(
        apiFetch: () async {
          // Fetch fresh bookings from backend
          await bookingProvider.fetchUserBookings();
          // Return the raw booking data for cache comparison
          return bookingProvider.allBookings
              .map((b) => {
                    'id': b.id,
                    'draft': b.draft,
                    'paymentMethod': b.paymentMethod,
                    'status': b.status,
                    'createdAt': b.createdAt,
                  })
              .toList();
        },
        onDataChanged: (freshBookings) {
          // Backend data differs from cache — update the provider
          // so the UI shows the latest bookings
          if (mounted) {
            // Convert raw maps back to BookingModel objects
            final models = freshBookings
                .map((b) => BookingModel.fromJson(Map<String, dynamic>.from(b)))
                .toList();
            bookingProvider.setBookings(models);
          }
        },
      );

      // Step 2: If cache had data, populate the provider immediately
      // so the user sees bookings even before the backend fetch completes
      if (cachedBookings.isNotEmpty && mounted) {
        final models = cachedBookings
            .map((b) => BookingModel.fromJson(Map<String, dynamic>.from(b)))
            .toList();
        bookingProvider.setBookings(models);
      }
    } catch (_) {
      // Cache might be empty on first launch — BookingProvider
      // will handle showing the loading/error states
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access theme provider for light/dark mode aware colors
    final theme = context.watch<ThemeProvider>();

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: theme.background, // now theme-aware
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 72,
          title: Text('Activity', style: Theme.of(context).textTheme.headlineMedium),
          bottom: const TabBar(
            isScrollable: false,
            indicatorColor: AppColors.yellow,
            indicatorWeight: 3,
            labelColor: AppColors.yellow,
            unselectedLabelColor: AppColors.grey,
            labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            tabs: [
              Tab(text: 'Bookings'),
              Tab(text: 'Pending'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        // Consumer listens to state changes inside BookingProvider
        body: Consumer<BookingProvider>(
          builder: (context, bookingProvider, _) {
            // Show a centered loading spinner while the API call is in-flight
            if (bookingProvider.isLoading && bookingProvider.allBookings.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.yellow),
              );
            }

            // Show an error banner with a Retry button if network request failed
            // AND no cached data is available
            if (bookingProvider.errorMessage != null && bookingProvider.allBookings.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      bookingProvider.errorMessage!,
                      style: const TextStyle(color: AppColors.red, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => _loadBookings(),
                      child: const Text('Retry Connection'),
                    ),
                  ],
                ),
              );
            }

            // Render tab views once data is successfully fetched — passing theme down.
            // If loaded from cache, these show immediately even without internet.
            return TabBarView(
              children: [
                _BookingList(bookings: bookingProvider.allBookings, theme: theme),
                _BookingList(bookings: bookingProvider.upcoming, showCancel: true, theme: theme),
                _BookingList(bookings: bookingProvider.completed, theme: theme),
                _BookingList(bookings: bookingProvider.cancelled, theme: theme),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Renders a scrollable list of booking cards or an empty state placeholder.
/// Now theme-aware — accepts ThemeProvider for surface and text colors.
class _BookingList extends StatelessWidget {
  final List<BookingModel> bookings;
  final bool showCancel;
  final ThemeProvider theme; // added for light/dark mode support

  const _BookingList({
    required this.bookings,
    this.showCancel = false,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    // Render Empty State if list contains no items
    if (bookings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.surface, // was Color(0xFF1A1A1A) — now theme-aware
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 14,
                      decoration: BoxDecoration(
                        color: theme.background, // skeleton placeholder uses background for contrast
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 14,
                      decoration: BoxDecoration(
                        color: theme.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 14,
                      width: 140,
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: theme.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No Trips Here Yet',
                style: TextStyle(color: theme.textPrimary, fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              const Text(
                'Your trip history will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.grey, fontSize: 13),
              ),
              const SizedBox(height: 20),
              AppPillButton(
                label: 'Book a Tour',
                trailingIcon: Icons.arrow_forward,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RoutesScreen())),
              ),
            ],
          ),
        ),
      );
    }

    // Render populated list of bookings (from cache or fresh backend data)
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final draft = booking.draft;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.amber.withValues(alpha: 0.25)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppIconAvatar(
                icon: Icons.directions_bus_rounded,
                color: booking.status == 'cancelled' ? AppColors.red : AppColors.yellow,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          draft.routeName,
                          style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          '${draft.currency} ${draft.totalPrice.toStringAsFixed(draft.isLocal ? 0 : 2)}',
                          style: const TextStyle(color: AppColors.yellow, fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Pickup: ${draft.pickupStop}', style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                    Text('${draft.date.day}/${draft.date.month}/${draft.date.year} \u00b7 ${draft.time}', style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      booking.status.toUpperCase(),
                      style: TextStyle(
                        color: booking.status == 'cancelled' ? AppColors.red : AppColors.yellow,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (booking.status != 'cancelled')
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => ReceiptScreen(booking: booking)),
                              );
                            },
                            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                            child: const Text('View Receipt', style: TextStyle(color: AppColors.yellow, fontSize: 12, fontWeight: FontWeight.w600)),
                          )
                        else
                          const SizedBox.shrink(),
                        if (showCancel && (booking.status == 'upcoming' || booking.status == 'confirmed'))
                          TextButton(
                            onPressed: () {
                              Provider.of<BookingProvider>(context, listen: false).cancelBooking(booking.id);
                            },
                            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                            child: const Text('Cancel Booking', style: TextStyle(color: AppColors.red, fontSize: 12)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}