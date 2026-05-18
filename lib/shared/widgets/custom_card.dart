import 'package:flutter/material.dart';

/// [CustomCard] es un contenedor estilizado y reutilizable en forma de tarjeta.
///
/// Integra de manera nativa efectos visuales táctiles (`InkWell`) al ser pulsada,
/// bordes redondeados consistentes y opciones personalizables de espaciado y color.
class CustomCard extends StatelessWidget {
  /// El widget hijo que se renderizará dentro de la tarjeta.
  final Widget child;

  /// Espaciado interno (padding) opcional alrededor del [child].
  /// Por defecto aplica 16.0 en todos los lados.
  final EdgeInsetsGeometry? padding;

  /// Acción a ejecutar cuando el usuario pulsa sobre la tarjeta.
  /// Si es nulo, los efectos visuales de interactividad se omiten.
  final VoidCallback? onTap;

  /// Color de fondo de la tarjeta.
  /// Si es nulo, consume el color de superficie definido por el tema actual (`CardTheme`).
  final Color? color;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }
}
