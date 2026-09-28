import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class ResolvedAddress {
  const ResolvedAddress(this.address, this.cityLine);
  final String address;
  final String cityLine;
}

class LocationService {
  /// Centro padrão do mapa (Belém - PA) quando o GPS não está disponível.
  static const defaultCenter = LatLng(-1.4520, -48.4830);

  LatLng? lastKnown;

  /// Retorna a posição atual ou null se o GPS/permissão não estiver disponível.
  Future<LatLng?> currentPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
      lastKnown = LatLng(pos.latitude, pos.longitude);
      return lastKnown;
    } catch (_) {
      return null;
    }
  }

  /// Converte coordenadas em endereço legível (geocodificação reversa).
  Future<ResolvedAddress> addressFor(LatLng p) async {
    try {
      final marks = await placemarkFromCoordinates(p.latitude, p.longitude);
      if (marks.isNotEmpty) {
        final m = marks.first;
        final street = (m.street ?? '').trim();
        final parts = <String>[
          if ((m.subLocality ?? '').trim().isNotEmpty) m.subLocality!.trim(),
          if ((m.locality ?? '').trim().isNotEmpty) m.locality!.trim(),
        ];
        var cityLine = parts.join(', ');
        final state = (m.administrativeArea ?? '').trim();
        if (state.isNotEmpty) {
          cityLine = cityLine.isEmpty ? state : '$cityLine - $state';
        }
        return ResolvedAddress(
          street.isEmpty ? 'Local marcado no mapa' : street,
          cityLine,
        );
      }
    } catch (_) {}
    return ResolvedAddress(
      'Local marcado no mapa',
      '${p.latitude.toStringAsFixed(5)}, ${p.longitude.toStringAsFixed(5)}',
    );
  }
}

final locationService = LocationService();
