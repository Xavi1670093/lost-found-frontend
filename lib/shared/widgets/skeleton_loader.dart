import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// [SkeletonLoader] es un widget animado que simula el estado de carga
/// (shimmer effect) de componentes textuales o bloques visuales.
///
/// Ofrece transiciones fluidas de gris claro a gris oscuro para adaptarse al brillo
/// del tema activo (`light` / `dark`) de la aplicación y un constructor de grid preconfigurado
/// para tarjetas de objetos perdidos/encontrados.
class SkeletonLoader extends StatelessWidget {
  /// El ancho del contenedor del shimmer.
  final double width;

  /// La altura del contenedor del shimmer.
  final double height;

  /// El radio de borde de las esquinas del contenedor.
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.brightness == Brightness.light 
        ? Colors.grey[300]! 
        : Colors.grey[800]!;
    final highlightColor = theme.brightness == Brightness.light 
        ? Colors.grey[100]! 
        : Colors.grey[700]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }

  static Widget postGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SkeletonLoader(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLoader(height: 14, width: 100),
                      const SizedBox(height: 8),
                      SkeletonLoader(height: 12, width: 60),
                    ],
                  ),
                ),
              ],
            ),
          ),
          childCount: 6,
        ),
      ),
    );
  }
}
