import 'dart:math';

import 'package:latlong2/latlong.dart';

extension LatLangHelper on LatLng {
  LatLng copyWith({double? lat, double? long}) =>
      LatLng(lat ?? latitude, long ?? longitude);

  LatLng add({double toLat = 0, double toLong = 0}) =>
      LatLng(latitude + toLat, longitude + toLong);

  double distance(LatLng pointB) {
    const earthRadius = 6371000;
    final lat1 = latitude * pi / 180;
    final lon1 = longitude * pi / 180;
    final lat2 = pointB.latitude * pi / 180;
    final lon2 = pointB.longitude * pi / 180;

    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }
}
