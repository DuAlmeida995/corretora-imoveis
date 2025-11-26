import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'dart:convert';

class _NominatimResult {
  final String road;
  final String suburb;
  final String city;
  final String postcode;

  _NominatimResult({
    this.road = 'Logradouro não disponível',
    this.suburb = 'Bairro não disponível',
    this.city = 'Cidade não disponível',
    this.postcode = 'N/A',
  });
}

// O Serviço que lida com a lógica de chamada de API
class GeocodingService {
  Future<_NominatimResult> geocodeWithNominatim(LatLng coordinates) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${coordinates.latitude}&lon=${coordinates.longitude}&zoom=18&addressdetails=1');

    try {
      final response = await http
          .get(url, headers: {'User-Agent': 'AuraImobiliariaApp/1.0'});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'] ?? {};

        return _NominatimResult(
          road: address['road'] ??
              address['footway'] ??
              address['pedestrian'] ??
              '',
          suburb: address['suburb'] ?? address['city_district'] ?? '',
          city: address['city'] ?? address['town'] ?? address['village'] ?? '',
          postcode: address['postcode'] ?? 'N/A',
        );
      }
    } catch (e) {
      print("Erro HTTP/JSON na geocodificação: $e");
    }
    // Retorna fallback em caso de falha de rede ou HTTP não-200
    return _NominatimResult();
  }
}
