import 'package:flutter/material.dart';

/// [FieldLabel] es un componente de UI reutilizable diseñado para mostrar etiquetas
/// descriptivas y estandarizadas encima de los campos de entrada de datos.
///
/// Soporta la indicación visual de obligatoriedad mediante la adición automática
/// de un asterisco rojo (`*`) al final del texto si el campo es requerido.
class FieldLabel extends StatelessWidget {
  /// El texto de la etiqueta a mostrar.
  final String label;

  /// Controla si se visualiza el indicador de obligatoriedad (`*`).
  final bool isRequired;

  const FieldLabel({
    super.key,
    required this.label,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            labelText,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 0.2,
            ),
          ),
          if (isRequired)
            Text(
              ' *',
              style: TextStyle(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  String get labelText => label.endsWith(':') ? label : label;
}
