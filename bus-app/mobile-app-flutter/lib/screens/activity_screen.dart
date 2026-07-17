import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/booking_provider.dart';
import '../models/booking_model.dart';
import '../widgets/app_pill_button.dart';
import '../widgets/app_icon_avatar.dart';
import 'routes_screen.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
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
        body: Consumer<BookingProvider>(
          builder: (context, bookingProvider, _) {
            return TabBarView(
              children: [
                _BookingList(bookings: bookingProvider.allBookings),
                _BookingList(bookings: bookingProvider.upcoming, showCancel: true),
                _BookingList(bookings: bookingProvider.completed),
                _BookingList(bookings: bookingProvider.cancelled),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  final List<BookingModel> bookings;
  final bool showCancel;

  const _BookingList({required this.bookings, this.showCancel = false});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Placeholder illustration block, matching the grey
              // rounded-line card shown in the reference empty state.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Container(height: 14, decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(8))),
                    const SizedBox(height: 10),
                    Container(height: 14, decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(8))),
                    const SizedBox(height: 10),
                    Container(height: 14, width: 140, alignment: Alignment.centerLeft, decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(8))),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('No Trips Here Yet', style: TextStyle(color: AppColors.white, fontSize: 17, fontWeight: FontWeight.w700)),
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
            color: const Color(0xFF1A1A1A),
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
                        Text(draft.routeName, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 14)),
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
                    if (showCancel && booking.status == 'upcoming') ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Provider.of<BookingProvider>(context, listen: false).cancelBooking(booking.id);
                          },
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                          child: const Text('Cancel Booking', style: TextStyle(color: AppColors.red, fontSize: 12)),
                        ),
                      ),
                    ],
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