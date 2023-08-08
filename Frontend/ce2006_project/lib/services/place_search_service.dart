import 'dart:convert' as convert;

import 'package:ce2006_project/constants.dart';
import 'package:ce2006_project/models/place_search.dart';
import 'package:http/http.dart' as http;

/// This is the PlacesSearchService class used in Destination Page
class PlacesSearchService {
  final key = kAPIKEY;

  /// This function is for getting destination search results base on user input
  Future<List<PlaceSearch>> getAutocomplete(String search) async {
    var url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$search&components=country:sg&language=en&types=address&key=$key';

    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var jsonResults = json['predictions'] as List;

    return jsonResults
        .map((placeSearch) => PlaceSearch.fromJson(placeSearch))
        .toList();
  }
}
