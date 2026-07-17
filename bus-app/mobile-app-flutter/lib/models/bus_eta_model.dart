class BusEtaModel {
  final String busId;
  final String plateNumber;
  final String routeId;
  final String routeName;
  final String nextStop;
  final int etaMinutes;

  BusEtaModel({
    required this.busId,
    required this.plateNumber,
    required this.routeId,
    required this.routeName,
    required this.nextStop,
    required this.etaMinutes,
  });
}