import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/route_detail_model.dart';
import '../utils/constants.dart';
import 'database_service.dart';

/// Handles the offline-first data strategy:
/// 1. Load from local SQLite (instant)
/// 2. Fetch from backend in background
/// 3. Compare — update local if backend has changed
/// 4. Return data (local if offline, fresh if online and changed)
class CacheService {
  /// Returns routes — always from cache first, then syncs in background.
  /// [onDataChanged] callback fires if backend data differs from cache,
  /// so the UI can refresh with new data.
  static Future<List<RouteDetail>> getRoutes({
    Function(List<RouteDetail>)? onDataChanged,
  }) async {
    // Step 1: Load cached data instantly
    List<RouteDetail> cachedRoutes = [];
    try {
      cachedRoutes = await DatabaseService.getAllRoutes();
    } catch (_) {
      // Cache might be empty on first launch — that's fine
    }

    // Step 2: Try fetching fresh data from backend
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/routes'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final freshRoutes = data.map((j) => RouteDetail.fromJson(j)).toList();

        // Step 3: Compare cache vs backend
        final hasChanged = await _hasRoutesChanged(freshRoutes);

        if (hasChanged) {
          // Save new data to local database
          await DatabaseService.saveRoutes(freshRoutes);

          // Notify caller that data has been updated
          onDataChanged?.call(freshRoutes);

          return freshRoutes;
        }
      }
    } catch (_) {
      // No internet or server error — use cached data
    }

    // Step 4: Return cached data (or empty list on first launch)
    return cachedRoutes;
  }

  /// Compares fresh routes from backend with cached routes.
  /// Returns true if the data has changed.
  static Future<bool> _hasRoutesChanged(List<RouteDetail> freshRoutes) async {
    // Quick check: different number of routes?
    final cachedCount = await DatabaseService.getRouteCount();
    if (cachedCount != freshRoutes.length) {
      return true; // Routes added or removed
    }

    // Deeper check: compare route names and IDs
    // If any route name or ID differs, data has changed
    final cachedRoutes = await DatabaseService.getAllRoutes();
    final cachedIds = cachedRoutes.map((r) => r.id).toSet();
    final freshIds = freshRoutes.map((r) => r.id).toSet();

    if (!cachedIds.containsAll(freshIds) || !freshIds.containsAll(cachedIds)) {
      return true; // Route IDs differ
    }

    // Compare names (quick way to detect edits)
    for (final fresh in freshRoutes) {
      final cached = cachedRoutes.firstWhere(
        (r) => r.id == fresh.id,
        orElse: () => fresh,
      );
      if (cached.name != fresh.name || cached.description != fresh.description) {
        return true; // Route was edited
      }
    }

    return false; // No changes detected
  }

  /// Checks if the cache has any data at all.
  /// Used to determine if this is the very first launch.
  static Future<bool> hasCachedData() async {
    final count = await DatabaseService.getRouteCount();
    return count > 0;
  }

    // =============================================================
  // BOOKINGS CACHE
  // =============================================================

  /// Returns bookings — cache-first, then syncs with backend.
  /// The [apiFetch] function should call your BookingProvider's
  /// fetch method to get fresh bookings from the server.
  static Future<List<dynamic>> getBookings({
    required Future<List<dynamic>> Function() apiFetch,
    Function(List<dynamic>)? onDataChanged,
  }) async {
    // Step 1: Load cached bookings instantly
    List<dynamic> cachedBookings = [];
    try {
      cachedBookings = await DatabaseService.getAllBookings();
    } catch (_) {
      // Cache might be empty — that's fine
    }

    // Step 2: Try fetching fresh bookings from backend
    try {
      final freshBookings = await apiFetch();

      // Step 3: Compare — if different, update cache
      final cachedCount = await DatabaseService.getBookingCount();
      if (cachedCount != freshBookings.length) {
        await DatabaseService.saveBookings(freshBookings);
        onDataChanged?.call(freshBookings);
        return freshBookings;
      }
    } catch (_) {
      // No internet — use cached data
    }

    return cachedBookings;
  }
}