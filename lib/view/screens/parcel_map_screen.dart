import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:garlic/app_router.dart';
import 'package:garlic/view/screens/parcel_survey_screen.dart';
import 'package:garlic/view_model/garlic_vm.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class ParcelMapScreen extends StatefulWidget {
  static const routeName = '/parcelMap';
  const ParcelMapScreen({super.key});

  @override
  State<ParcelMapScreen> createState() => _ParcelMapScreenState();
}

class _ParcelMapScreenState extends State<ParcelMapScreen> {
  final _mapController = MapController();
  // 남해읍 아산리/심천리 중심
  static const _center = LatLng(34.8485, 127.8915);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  Future<void> _reload() async {
    await context.read<GarlicVM>().loadBounds(
      minx: 127.87,
      miny: 34.83,
      maxx: 127.91,
      maxy: 34.87,
    );
  }

  List<LatLng> _polyFromGeoJson(dynamic geom) {
    if (geom == null) return [];
    final obj = geom is String ? jsonDecode(geom) : geom;
    if (obj is! Map) return [];
    final type = obj['type'];
    final coords = obj['coordinates'];
    if (type == 'Polygon' && coords is List && coords.isNotEmpty) {
      return (coords[0] as List)
          .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
          .toList();
    }
    if (type == 'MultiPolygon' && coords is List && coords.isNotEmpty) {
      final first = coords[0];
      if (first is List && first.isNotEmpty) {
        return (first[0] as List)
            .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
            .toList();
      }
    }
    return [];
  }

  LatLng? _centerFrom(dynamic geoCenter) {
    if (geoCenter == null) return null;
    final obj = geoCenter is String ? jsonDecode(geoCenter) : geoCenter;
    if (obj is Map && obj['coordinates'] is List) {
      final c = obj['coordinates'] as List;
      return LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble());
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GarlicVM>();
    final polygons = <Polygon>[];
    final markers = <Marker>[];

    for (final p in vm.mapParcels) {
      final pts = _polyFromGeoJson(p['geom']);
      final written = p['write_data'] == 'Y';
      if (pts.length >= 3) {
        polygons.add(
          Polygon(
            points: pts,
            color: (written ? const Color(0xFF2F6B4F) : Colors.orange)
                .withValues(alpha: 0.35),
            borderColor: written ? const Color(0xFF2F6B4F) : Colors.deepOrange,
            borderStrokeWidth: 2,
          ),
        );
      }
      final c = _centerFrom(p['geo_center']) ??
          (pts.isNotEmpty ? pts.first : null);
      if (c != null) {
        markers.add(
          Marker(
            point: c,
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () async {
                await Navigator.pushNamed(
                  context,
                  ParcelSurveyScreen.routeName,
                  arguments: ParcelSurveyArgs(
                    parcelId: '${p['id']}',
                    surveyUuid: p['survey_uuid']?.toString(),
                    address: '${p['stdg_addr'] ?? ''}',
                  ),
                );
                if (mounted) _reload();
              },
              child: Icon(
                Icons.location_on,
                color: written ? const Color(0xFF2F6B4F) : Colors.deepOrange,
                size: 36,
              ),
            ),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('필지 지도'),
        actions: [
          IconButton(onPressed: _reload, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: const MapOptions(
          initialCenter: _center,
          initialZoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.sejong.garlic',
          ),
          PolygonLayer(polygons: polygons),
          MarkerLayer(markers: markers),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            '필지 ${vm.mapParcels.length}건 · 마커를 눌러 실측조사',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
