import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../data/services/geocoding_service.dart';
import '../../data/models/selected_location_model.dart';

class MapLocationPicker extends StatefulWidget {
  final LatLng initialCenter;

  const MapLocationPicker({
    super.key,
    required this.initialCenter,
  });

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  final GeocodingService _geocodingService = GeocodingService();

  late LatLng _currentLocation;
  String _currentAddress = "Arraste o mapa para selecionar a localização...";
  bool _isLoadingAddress = false;

  @override
  void initState() {
    super.initState();
    _currentLocation = widget.initialCenter;
    _geocodeLocation(_currentLocation);
  }

  Future<void> _geocodeLocation(LatLng coordinates) async {
    setState(() {
      _isLoadingAddress = true;
      _currentAddress = "Buscando endereço...";
    });

    try {
      final place = await _geocodingService.geocodeWithNominatim(coordinates);

      if (place.road.isNotEmpty || place.city.isNotEmpty) {
        setState(() {
          _currentAddress = [
            place.road,
            place.suburb,
            place.city,
            place.postcode,
          ]
              .where((s) =>
                  s.isNotEmpty &&
                  s != 'Logradouro não disponível' &&
                  s != 'N/A')
              .join(', ');
        });
      } else {
        setState(() {
          _currentAddress = "Endereço não encontrado nas coordenadas.";
        });
      }
    } catch (e) {
      setState(() {
        _currentAddress = "Erro fatal ao buscar endereço.";
      });
    } finally {
      setState(() {
        _isLoadingAddress = false;
      });
    }
  }

  void _selectLocation() async {
    if (_isLoadingAddress) return;

    final place =
        await _geocodingService.geocodeWithNominatim(_currentLocation);

    SelectedLocation result = SelectedLocation(
      coordinates: _currentLocation,
      address: _currentAddress,
      cep: place.postcode,
      logradouro: place.road,
      cidade: place.city,
      bairro: place.suburb,
    );

    if (mounted) {
      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: Icon(CupertinoIcons.clear_thick, color: primaryColor),
        ),
        title: Text(
          "Selecionar Endereço",
          style:
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          CupertinoButton(
            onPressed: _selectLocation,
            child: Text(
              "Confirmar",
              style: theme.textTheme.titleMedium?.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: _currentLocation,
              initialZoom: 15.0,
              onMapEvent: (event) {
                if (event is MapEventMoveEnd) {
                  LatLng center = event.camera.center;
                  if (center.latitude != _currentLocation.latitude ||
                      center.longitude != _currentLocation.longitude) {
                    _currentLocation = center;
                    _geocodeLocation(_currentLocation);
                  }
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.aura_imobiliaria',
              ),
            ],
          ),

          // Marcador Central
          Center(
            child: Icon(
              CupertinoIcons.location_solid,
              color: primaryColor,
              size: 40,
            ),
          ),

          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withOpacity(0.9)
                    : Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Localização Selecionada:",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_isLoadingAddress)
                    const CupertinoActivityIndicator()
                  else
                    Text(
                      _currentAddress,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: primaryColor,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
