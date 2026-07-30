// lib/screens/route_detail_screen.dart

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../models/route_detail_model.dart';
// ignore: unused_import
import '../models/booking_model.dart';
import '../widgets/app_back_button.dart';
import 'booking_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RouteDetailScreen extends StatefulWidget {
  final RouteDetail route;
  final String? targetStopId;

  const RouteDetailScreen({super.key, required this.route, this.targetStopId});

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  final Map<String, GlobalKey> _stopKeys = {};

  @override
  void initState() {
    super.initState();
    for (var stop in widget.route.stops) {
      _stopKeys[stop.id] = GlobalKey();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.targetStopId != null && _stopKeys.containsKey(widget.targetStopId)) {
        final targetContext = _stopKeys[widget.targetStopId]?.currentContext;
        if (targetContext != null) {
          Scrollable.ensureVisible(targetContext, duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(widget.route.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.route.imageUrl != null && widget.route.imageUrl!.isNotEmpty)
              CachedNetworkImage(
                imageUrl: widget.route.imageUrl!,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 220,
                  color: AppColors.black3,
                  child: const Center(child: CircularProgressIndicator(color: AppColors.yellow)),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 220,
                  color: AppColors.black3,
                  child: const Icon(Icons.tour, size: 60, color: AppColors.yellow),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.route.description, style: const TextStyle(color: AppColors.grey, fontSize: 15, height: 1.4)),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 10),
                  const Text('Tour Stops & Highlights', style: TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.route.stops.length,
              itemBuilder: (context, index) {
                final stop = widget.route.stops[index];
                final isTarget = widget.targetStopId == stop.id;

                return Container(
                  key: _stopKeys[stop.id],
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.black2,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isTarget ? AppColors.yellow : AppColors.amber.withValues(alpha: 0.2), width: isTarget ? 2 : 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.yellow,
                            child: Text('${index + 1}', style: const TextStyle(color: AppColors.black, fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(stop.name, style: const TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(stop.description, style: const TextStyle(color: AppColors.grey, fontSize: 14, height: 1.4)),
                      const SizedBox(height: 14),
                      if (stop.images.isNotEmpty) ...[
                        const Text('Gallery', style: TextStyle(color: AppColors.yellow, fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 160,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: stop.images.length,
                            itemBuilder: (context, imgIndex) {
                              return Container(
                                margin: const EdgeInsets.only(right: 10),
                                width: 220,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColors.black),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl: stop.images[imgIndex],
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(color: AppColors.yellow, strokeWidth: 2),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      color: AppColors.black3,
                                      child: const Icon(Icons.broken_image, color: AppColors.grey),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        color: AppColors.black2,
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => BookingScreen(preselectedRouteId: widget.route.id)));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.yellow,
              foregroundColor: AppColors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Book This Tour', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}