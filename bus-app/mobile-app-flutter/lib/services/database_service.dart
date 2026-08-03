import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/route_detail_model.dart';

/// Manages the local SQLite database for offline caching.
/// Creates tables for routes, stops, and stop images on first launch.
/// Provides methods to save and read full RouteDetail objects.
class DatabaseService {
  static Database? _database;

  /// Opens the database (creates it if it doesn't exist).
  /// Uses a singleton pattern so only one connection is open at a time.
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Creates the database file and tables.
  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'bus_app_cache.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Routes table — stores main route info
        await db.execute('''
          CREATE TABLE routes (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT,
            imageUrl TEXT,
            fare REAL,
            internationalFare REAL
          )
        ''');

        // Stops table — each stop belongs to a route (foreign key)
        await db.execute('''
          CREATE TABLE stops (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT,
            orderIndex INTEGER,
            route_id TEXT NOT NULL,
            FOREIGN KEY (route_id) REFERENCES routes(id) ON DELETE CASCADE
          )
        ''');

        // Stop images table — each image belongs to a stop (foreign key)
        await db.execute('''
          CREATE TABLE stop_images (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            url TEXT NOT NULL,
            stop_id TEXT NOT NULL,
            FOREIGN KEY (stop_id) REFERENCES stops(id) ON DELETE CASCADE
          )
        ''');

                // Bookings table — stores user's booked tickets for offline access
        await db.execute('''
          CREATE TABLE bookings (
            id TEXT PRIMARY KEY,
            route_name TEXT NOT NULL,
            pickup_stop TEXT,
            date TEXT,
            time TEXT,
            passengers INTEGER,
            is_local INTEGER DEFAULT 1,
            total_price REAL,
            currency TEXT DEFAULT 'UGX',
            payment_method TEXT,
            status TEXT DEFAULT 'upcoming',
            created_at TEXT
          )
        ''');
      },
    );
  }

  /// Saves a full list of RouteDetail objects to the local database.
  /// Clears existing data first to avoid duplicates, then inserts fresh data.
  static Future<void> saveRoutes(List<RouteDetail> routes) async {
    final db = await database;

    // Clear old data — cascade deletes will also remove stops and images
    await db.delete('routes');

    // Insert each route
    for (final route in routes) {
      await db.insert('routes', {
        'id': route.id,
        'name': route.name,
        'description': route.description,
        'imageUrl': route.imageUrl,
        'fare': route.fare,
        'internationalFare': route.internationalFare,
      });

      // Insert stops for this route
      for (final stop in route.stops) {
        await db.insert('stops', {
          'id': stop.id,
          'name': stop.name,
          'description': stop.description,
          'orderIndex': stop.orderIndex,
          'route_id': route.id,
        });

        // Insert images for this stop
        for (final imageUrl in stop.images) {
          await db.insert('stop_images', {
            'url': imageUrl,
            'stop_id': stop.id,
          });
        }
      }
    }
  }

  /// Reads all routes from the local database and reconstructs
  /// full RouteDetail objects with their stops and images.
  static Future<List<RouteDetail>> getAllRoutes() async {
    final db = await database;

    // Get all routes
    final routeRows = await db.query('routes');
    final List<RouteDetail> routes = [];

    for (final routeRow in routeRows) {
      // Get stops for this route
      final stopRows = await db.query(
        'stops',
        where: 'route_id = ?',
        whereArgs: [routeRow['id']],
        orderBy: 'orderIndex ASC',
      );

      final List<TourStop> stops = [];
      for (final stopRow in stopRows) {
        // Get images for this stop
        final imageRows = await db.query(
          'stop_images',
          where: 'stop_id = ?',
          whereArgs: [stopRow['id']],
        );

        final List<String> images = imageRows
            .map((img) => img['url'] as String)
            .toList();

        stops.add(TourStop(
          id: stopRow['id'] as String,
          name: stopRow['name'] as String,
          description: stopRow['description'] as String? ?? '',
          images: images,
          orderIndex: stopRow['orderIndex'] as int? ?? 0,
        ));
      }

      routes.add(RouteDetail(
        id: routeRow['id'] as String,
        name: routeRow['name'] as String,
        description: routeRow['description'] as String? ?? '',
        imageUrl: routeRow['imageUrl'] as String?,
        fare: (routeRow['fare'] as num?)?.toDouble() ?? 0.0,
        internationalFare: (routeRow['internationalFare'] as num?)?.toDouble() ?? 30.0,
        stops: stops,
      ));
    }

    return routes;
  }

  /// Returns the number of routes stored locally.
  /// Used for quick comparison with backend without loading full data.
  static Future<int> getRouteCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM routes');
    return result.first['count'] as int;
  }

  /// Closes the database connection.
  static Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

    // =============================================================
  // BOOKINGS CACHE
  // =============================================================

  /// Saves a list of BookingModel objects to the local database.
  /// Clears existing bookings first to avoid duplicates.
  static Future<void> saveBookings(List<dynamic> bookings) async {
    final db = await database;

    // Clear old bookings
    await db.delete('bookings');

    // Insert each booking
    for (final booking in bookings) {
      final draft = booking.draft;
      await db.insert('bookings', {
        'id': booking.id,
        'route_name': draft.routeName,
        'pickup_stop': draft.pickupStop,
        'date': draft.date.toIso8601String(),
        'time': draft.time,
        'passengers': draft.passengers,
        'is_local': draft.isLocal ? 1 : 0,
        'total_price': draft.totalPrice,
        'currency': draft.currency,
        'payment_method': booking.paymentMethod,
        'status': booking.status,
        'created_at': booking.createdAt.toIso8601String(),
      });
    }
  }

  /// Reads all bookings from the local database and reconstructs
  /// BookingModel objects.
  static Future<List<dynamic>> getAllBookings() async {
    final db = await database;

    final rows = await db.query('bookings', orderBy: 'created_at DESC');

    return rows.map((row) {
      return {
        'id': row['id'],
        'payment_method': row['payment_method'],
        'status': row['status'],
        'created_at': row['created_at'],
        'draft': {
          'route_id': '',
          'route_name': row['route_name'],
          'pickup_stop': row['pickup_stop'],
          'date': row['date'],
          'time': row['time'],
          'passengers': row['passengers'],
          'is_local': row['is_local'] == 1,
          'total_price': row['total_price'],
          'currency': row['currency'],
        },
      };
    }).toList();
  }

  /// Returns the number of bookings stored locally.
  static Future<int> getBookingCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM bookings');
    return result.first['count'] as int;
  }
}