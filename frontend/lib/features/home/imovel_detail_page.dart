import 'dart:ui';
import 'package:aura_frontend/features/imovel_details/imovel_history_page.dart';
import 'package:aura_frontend/widgets/favorite_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../data/models/imovel_model.dart';
import 'package:aura_frontend/features/imovel_details/imovel_edit_page.dart';
import 'package:intl/intl.dart';

class PropertyPage extends StatefulWidget {
  final ImovelModel imovel;

  const PropertyPage({super.key, required this.imovel});

  @override
  State<PropertyPage> createState() => _PropertyPageState();
}

class _PropertyPageState extends State<PropertyPage> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  void _navigateToHistory(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) =>
            ImovelHistoryPage(matricula: widget.imovel.matricula),
      ),
    );
  }

  void _navigateToEdit(BuildContext context) async {
    final result = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => ImovelEditPage(imovel: widget.imovel),
      ),
    );

    if (result == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  void _nextImage() {
    if (_currentImageIndex < widget.imovel.imagens.length - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _previousImage() {
    if (_currentImageIndex > 0) {
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = Colors.black;
    final imovel = widget.imovel;

    final currencyFormat =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    String precoFormatado = widget.imovel.valorVenalFormatado;

    final List<String> imagensExibicao =
        imovel.imagens.isNotEmpty ? imovel.imagens : ['assets/img1.jpg'];

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 420,
            backgroundColor: Colors.transparent,
            floating: false,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: imagensExibicao.length,
                    onPageChanged: (index) {
                      setState(() => _currentImageIndex = index);
                    },
                    itemBuilder: (context, index) {
                      return Hero(
                        tag: index == 0
                            ? "property-image-${imovel.matricula}"
                            : "img-$index",
                        child: _buildImovelImage(imagensExibicao[index]),
                      );
                    },
                  ),

                  // Gradiente
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black26,
                          Colors.transparent,
                          Colors.black45
                        ],
                      ),
                    ),
                  ),

                  if (imagensExibicao.length > 1) ...[
                    // Seta Esquerda
                    if (_currentImageIndex > 0)
                      Positioned(
                        left: 10,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: _navArrowButton(
                            icon: CupertinoIcons.chevron_left,
                            onTap: _previousImage,
                          ),
                        ),
                      ),
                    // Seta Direita
                    if (_currentImageIndex < imagensExibicao.length - 1)
                      Positioned(
                        right: 10,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: _navArrowButton(
                            icon: CupertinoIcons.chevron_right,
                            onTap: _nextImage,
                          ),
                        ),
                      ),
                  ],

                  Positioned(
                    bottom: 20,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Tags
                        Row(
                          children: [
                            _buildTag(context, Icons.star_rounded, "5.0"),
                            const SizedBox(width: 8),
                            _buildTag(context, Icons.apartment_rounded,
                                imovel.tipo ?? "Imóvel"),
                          ],
                        ),

                        // Indicador de Paginação (Dots)
                        if (imagensExibicao.length > 1)
                          Row(
                            children:
                                List.generate(imagensExibicao.length, (index) {
                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentImageIndex == index
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.5),
                                ),
                              );
                            }),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            leading: _circleButton(
              context,
              icon: CupertinoIcons.back,
              onTap: () => Navigator.pop(context),
            ),
            actions: [
              _circleButton(
                context,
                icon: CupertinoIcons.time,
                onTap: () => _navigateToHistory(context),
              ),
              const SizedBox(width: 8),
              const FavoriteButton(),
              const SizedBox(width: 12),
            ],
          ),

          // CONTEÚDO PRINCIPAL
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título (Endereço Principal)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.imovel.numero.isNotEmpty
                              ? "${widget.imovel.logradouro}, ${widget.imovel.numero}"
                              : widget.imovel.logradouro,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: primaryColor,
                            height: 1.2,
                            fontSize: 24,
                            letterSpacing: -0.5,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Localização Completa
                  Row(
                    children: [
                      const Icon(CupertinoIcons.location_solid,
                          size: 18, color: Colors.black54),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          widget.imovel.enderecoCompleto,
                          style: const TextStyle(color: Colors.black54),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Características
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildFeatureInfo(Icons.bed,
                          "${widget.imovel.numQuartos ?? 0} Quartos"),
                      _buildFeatureInfo(Icons.square_foot,
                          "${widget.imovel.metragem ?? 0} m²"),
                      _buildFeatureInfo(Icons.build,
                          "${widget.imovel.numReformas ?? 0} Reformas"),
                    ],
                  ),

                  const SizedBox(height: 28),

                  Text(
                    "Descrição do Imóvel",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${widget.imovel.descricao}\n\nStatus do Imóvel: ${widget.imovel.statusOcupacao}.\nLocalizado em uma região privilegiada, ideal para ${widget.imovel.finalidade}.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Comodidades
                  if (widget.imovel.comodidades.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text("Comodidades",
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.imovel.comodidades
                          .map((c) =>
                              _buildTag(context, Icons.check, c, isDark: true))
                          .toList(),
                    ),
                  ],

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // BARRA INFERIOR (PREÇO E AÇÃO)
      bottomNavigationBar: Container(
        height: 90,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Valor Total",
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(
                    precoFormatado,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _navigateToEdit(context),
                icon: const Icon(CupertinoIcons.pencil),
                label: const Text("Editar Imóvel"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---
  Widget _buildImovelImage(String urlOrAsset) {
    if (urlOrAsset.startsWith('http')) {
      print("Tentando carregar imagem: $urlOrAsset");

      return Image.network(
        urlOrAsset,
        fit: BoxFit.cover,
        loadingBuilder: (ctx, child, progress) => progress == null
            ? child
            : Container(
                color: Colors.grey.shade200,
                child: const Center(child: CupertinoActivityIndicator())),
        errorBuilder: (context, error, stackTrace) {
          print("ERRO AO CARREGAR IMAGEM ($urlOrAsset): $error");

          return Image.asset("assets/img1.jpg", fit: BoxFit.cover);
        },
      );
    } else {
      return Image.asset(urlOrAsset, fit: BoxFit.cover);
    }
  }

  Widget _navArrowButton(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildFeatureInfo(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey),
        const SizedBox(height: 4),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _circleButton(BuildContext context,
      {required IconData icon,
      required VoidCallback onTap,
      Color? color,
      Color? iconColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color ?? Colors.white.withOpacity(0.7),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: Icon(icon, color: iconColor ?? Colors.black, size: 20),
      ),
    );
  }

  Widget _buildTag(BuildContext context, IconData icon, String label,
      {bool isDark = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade200 : Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isDark ? Colors.black : Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
                color: isDark ? Colors.black : Colors.white, fontSize: 14),
          )
        ],
      ),
    );
  }
}
