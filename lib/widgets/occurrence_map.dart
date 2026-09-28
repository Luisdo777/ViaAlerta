import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Filtro que escurece os tiles do OpenStreetMap para combinar com o tema do app.
const ColorFilter _darkTiles = ColorFilter.matrix(<double>[
  -0.8, 0, 0, 0, 215, //
  0, -0.8, 0, 0, 225, //
  0, 0, -0.8, 0, 215, //
  0, 0, 0, 1, 0, //
]);

class OccurrenceMap extends StatelessWidget {
  const OccurrenceMap({
    super.key,
    required this.center,
    this.zoom = 15,
    this.markers = const [],
    this.interactive = true,
    this.onTap,
  });

  final LatLng center;
  final double zoom;
  final List<Marker> markers;
  final bool interactive;
  final void Function(LatLng point)? onTap;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: zoom,
        backgroundColor: const Color(0xFF16181B),
        interactionOptions: InteractionOptions(
          flags: interactive
              ? InteractiveFlag.all & ~InteractiveFlag.rotate
              : InteractiveFlag.none,
        ),
        onTap: onTap == null ? null : (tapPosition, point) => onTap!(point),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'br.com.viaalerta.app',
          tileBuilder: (context, tileWidget, tile) =>
              ColorFiltered(colorFilter: _darkTiles, child: tileWidget),
        ),
        MarkerLayer(markers: markers),
        if (interactive)
          const SimpleAttributionWidget(
            source: Text('© OpenStreetMap', style: TextStyle(fontSize: 10)),
          ),
      ],
    );
  }
}

/// Pino de mapa cuja ponta fica exatamente sobre a coordenada.
Marker pinMarker(LatLng point, Color color, {VoidCallback? onTap}) {
  return Marker(
    point: point,
    width: 44,
    height: 44,
    alignment: Alignment.topCenter,
    child: GestureDetector(
      onTap: onTap,
      child: Icon(Icons.location_on, color: color, size: 44, shadows: const [
        Shadow(color: Colors.black54, blurRadius: 6),
      ]),
    ),
  );
}

