/// This is the PlaceSearch class
/// Attributes:
/// address - address of location
/// placeId - place id of location
class PlaceSearch {
  final String address;
  final String placeId;

  PlaceSearch({required this.address, required this.placeId});

  factory PlaceSearch.fromJson(Map<String, dynamic> parsedJson) {
    return PlaceSearch(
      address: parsedJson['description'],
      placeId: parsedJson['place_id'],
    );
  }
}
