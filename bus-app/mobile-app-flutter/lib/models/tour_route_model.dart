import 'stop_model.dart';
import 'schedule_model.dart';

class TourRouteModel {
  final String id;
  final String name;
  final String description;
  final List<StopModel> stops;
  final List<ScheduleModel> schedule;

  TourRouteModel({
    required this.id,
    required this.name,
    required this.description,
    required this.stops,
    required this.schedule,
  });
}
