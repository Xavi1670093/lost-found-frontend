import 'package:flutter/material.dart';
import 'field_label.dart';

/// [CustomTextField] es un campo de texto altamente configurable y estilizado.
///
/// Encapsula comportamientos comunes de formularios como validaciones, soporte para
/// contraseñas (`isPassword`), etiquetas accesibles e indicadores de obligatoriedad (`FieldLabel`),
/// personalización del teclado y control de acciones de finalización de texto.
class CustomTextField extends StatelessWidget {
  /// Etiqueta descriptiva que identifica el propósito del campo de entrada.
  final String label;

  /// Texto de sugerencia o marcador de posición (placeholder) que se muestra
  /// dentro del campo cuando este se encuentra vacío.
  final String? hintText;

  /// Controlador de edición de texto para recuperar y manipular el valor escrito.
  final TextEditingController? controller;

  /// Define si el campo oculta los caracteres (para contraseñas o datos sensibles).
  final bool isPassword;

  /// Tipo de teclado que se desplegará al enfocar el campo (ej: email, numérico).
  final TextInputType keyboardType;

  /// Icono opcional que se muestra al principio del campo de texto.
  final IconData? prefixIcon;

  /// Función validadora que retorna un mensaje de error si el contenido es inválido.
  final String? Function(String?)? validator;

  /// Widget personalizado opcional que se muestra al final del campo de texto.
  final Widget? suffixIcon;

  /// Tipo de botón de acción del teclado virtual (ej: siguiente, enviar).
  final TextInputAction? textInputAction;

  /// Callback que se dispara cuando el usuario envía el formulario desde el teclado.
  final void Function(String)? onFieldSubmitted;

  /// Cantidad máxima de líneas que puede ocupar el campo. Por defecto es 1.
  final int maxLines;

  /// Controla si se debe mostrar la etiqueta superior descriptiva ([FieldLabel]).
  final bool showLabel;

  /// Indica si el campo es obligatorio. Si es `true`, añade un asterisco rojo a la etiqueta.
  final bool isRequired;

  const CustomTextField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.onFieldSubmitted,
    this.prefixIcon,
    this.validator,
    this.suffixIcon,
    this.maxLines = 1,
    this.showLabel = true,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel)
          FieldLabel(label: label, isRequired: isRequired),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon != null 
                ? Icon(prefixIcon, color: theme.colorScheme.primary.withValues(alpha: 0.7)) 
                : null,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
