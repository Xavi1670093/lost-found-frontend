import 'package:flutter/material.dart';

/// [CustomButton] es un botón personalizado y reutilizable adaptado al
/// sistema de diseño visual de la aplicación.
///
/// Soporta variaciones primarias (relleno sólido con color de énfasis) y
/// secundarias (con borde delineado), indicadores de estado de carga
/// (loading spinner) e inclusión opcional de iconos decorativos.
class CustomButton extends StatelessWidget {
  /// El texto legible que se mostrará en el centro del botón.
  final String text;

  /// Callback que se ejecuta cuando el usuario presiona el botón.
  /// Si [isLoading] es verdadero, esta acción se deshabilita automáticamente.
  final VoidCallback? onPressed;

  /// Define el estilo visual predominante del botón.
  /// Si es `true`, renderiza un botón primario (Elevated).
  /// Si es `false`, renderiza un botón secundario (Outlined).
  final bool isPrimary;

  /// Controla si se debe mostrar un spinner de carga (`CircularProgressIndicator`)
  /// en lugar del texto y el icono del botón.
  final bool isLoading;

  /// Icono opcional que acompaña al texto dentro del botón.
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (isPrimary) {
      return ElevatedButton(
        onPressed: (isLoading || onPressed == null) ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 10),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
      );
    } else {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: theme.colorScheme.primary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 10),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
      );
    }
  }
}
