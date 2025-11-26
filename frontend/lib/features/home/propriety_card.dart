import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aura_frontend/data/models/imovel_model.dart';

class PropertyCard extends StatelessWidget {
  final ImovelModel imovel;
  final VoidCallback onTap;

  const PropertyCard({
    super.key,
    required this.imovel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark ? Colors.grey.shade900 : Colors.white;
    final primaryColor = isDark ? Colors.white : Colors.black;
    final secondaryColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    final heroTag = 'property_img_${imovel.matricula}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  tag: heroTag,
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: _buildPropertyImage(isDark),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      (imovel.finalidade ?? 'IMÓVEL').toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Preço
                  Text(
                    imovel.valorVenalFormatado,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Endereço (Logradouro)
                  Row(
                    children: [
                      Icon(CupertinoIcons.location_solid,
                          size: 14, color: secondaryColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          imovel.enderecoCompleto,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: secondaryColor),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Badges de Características (Quartos, Metragem)
                  Row(
                    children: [
                      _buildInfoBadge(CupertinoIcons.bed_double_fill,
                          "${imovel.numQuartos} Quartos", secondaryColor),
                      const SizedBox(width: 16),
                      _buildInfoBadge(CupertinoIcons.square_grid_2x2_fill,
                          "${imovel.metragem} m²", secondaryColor),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyImage(bool isDark) {
    if (imovel.profileImageUrl != null && imovel.profileImageUrl!.isNotEmpty) {
      return Image.network(
        imovel.profileImageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            child: const Center(child: CupertinoActivityIndicator()),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(isDark);
        },
      );
    }

    return _buildPlaceholder(isDark);
  }

  Widget _buildPlaceholder(bool isDark) {
    return Container(
      color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
      child: Center(
        child: Icon(CupertinoIcons.photo,
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            size: 40),
      ),
    );
  }

  Widget _buildInfoBadge(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
