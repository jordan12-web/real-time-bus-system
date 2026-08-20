import 'package:latlong2/latlong.dart';

/// Static city-name -> coordinates lookup for the tracking map's
/// origin/destination markers and route line.
///
/// This is a deliberate, scoped-down stand-in for a real geocoding API call
/// (e.g. Google Geocoding or Nominatim) — the live bus position always comes
/// from real GPS data via SSE, this dictionary only decorates the map with
/// where the trip starts/ends. Add more cities here as needed; if a trip's
/// origin/destination text isn't in this map, the screen just skips drawing
/// the route line and endpoint pins and shows the live bus marker alone.
const Map<String, LatLng> kKnownCityCoordinates = {
  'bahir dar': LatLng(11.5936, 37.3908),
  'addis ababa': LatLng(9.0192, 38.7525),
  'hawassa': LatLng(7.0504, 38.4955),
  'gondar': LatLng(12.6030, 37.4521),
  'mekelle': LatLng(13.4967, 39.4753),
  'dire dawa': LatLng(9.5931, 41.8661),
  'adama': LatLng(8.5400, 39.2700),
  'jimma': LatLng(7.6733, 36.8344),
};

/// Case/whitespace-insensitive lookup.
LatLng? lookupCityCoordinates(String? cityName) {
  if (cityName == null) return null;
  return kKnownCityCoordinates[cityName.trim().toLowerCase()];
}