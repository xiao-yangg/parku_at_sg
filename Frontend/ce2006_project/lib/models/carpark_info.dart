/// This is the CarparkInfo class
/// Attributes:
/// parkingSystem - parking system found in carpark
/// type - carpark type
/// freeParking - free parking information of carpark
/// gantryHeight - gantry height of carpark
/// nightParking - whether night parking is available in carpark
class CarparkInfo {
  final String parkingSystem;
  final String type;
  final String freeParking;
  final String gantryHeight;
  final bool nightParking;

  CarparkInfo({
    required this.parkingSystem,
    required this.type,
    required this.freeParking,
    required this.gantryHeight,
    required this.nightParking,
  });
}
