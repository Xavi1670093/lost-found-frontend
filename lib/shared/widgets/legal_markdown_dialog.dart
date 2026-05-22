import 'package:flutter/material.dart';
import 'package:unilost_found/core/localization/app_strings.dart';

class LegalMarkdownDialog extends StatefulWidget {
  final String documentName; // 'terms' o 'privacy'

  const LegalMarkdownDialog({
    super.key,
    required this.documentName,
  });

  @override
  State<LegalMarkdownDialog> createState() => _LegalMarkdownDialogState();
}

class _LegalMarkdownDialogState extends State<LegalMarkdownDialog> {
  String? _content;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    final locale = Localizations.localeOf(context).languageCode;
    final path = 'assets/legal/${widget.documentName}_$locale.md';
    try {
      final text = await DefaultAssetBundle.of(context).loadString(path);
      if (mounted) {
        setState(() {
          _content = text;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("ULF_DEBUG: Error loading legal document $path: $e");
      if (mounted) {
        setState(() {
          _content = _getFallbackContent(widget.documentName, locale);
          _isLoading = false;
        });
      }
    }
  }

  String _getFallbackContent(String docName, String lang) {
    if (docName == 'terms') {
      if (lang == 'ca') {
        return '''# Termes i Condicions d'Ús
Última actualització: 21 de maig de 2026

Benvingut a **UniLost & Found** (ULF), la plataforma oficial per a la recuperació d'objectes perduts a la Universitat Autònoma de Barcelona (UAB).

## 1. Aceptació dels Termes
En registrar-te i utilitzar aquesta aplicació, acceptes complir amb tots els termes i condicions aquí descrits. Si no estàs d'acord amb alguna part dels termes, no podràs accedir als serveis.

## 2. Ús Autoritzat
Aquesta aplicació està destinada exclusivament a membres de la comunitat universitària de la UAB (estudiants, professors i personal d'administració). El registre requereix un correu electrònic institucional vàlid `@uab.cat`.

## 3. Responsabilitat sobre Publicacions
Els usuaris són completament responsables del contingut, veracitat i estat dels objectes publicats a la plataforma. ULF no es fa responsable de transaccions errònies o disputes entre usuaris.

## 4. Modificacions
Ens reservem el dret de modificar aquests termes en qualsevol moment. L'ús continuat de l'aplicació després d'aquests canvis constitueix l'acceptació dels nous termes.''';
      } else if (lang == 'en') {
        return '''# Terms and Conditions of Use
Last updated: May 21, 2026

Welcome to **UniLost & Found** (ULF), the official platform for retrieving lost items at the Universitat Autònoma de Barcelona (UAB).

## 1. Acceptance of Terms
By registering and using this application, you agree to comply with all terms and conditions described herein. If you do not agree with any part of these terms, you may not access the services.

## 2. Authorized Use
This application is exclusively intended for members of the UAB university community (students, professors, and administration staff). Registration requires a valid institutional email `@uab.cat`.

## 3. Responsibility for Publications
Users are entirely responsible for the content, truthfulness, and condition of items published on the platform. ULF is not responsible for incorrect transactions or disputes between users.

## 4. Modifications
We reserve the right to modify these terms at any time. Continued use of the application after such changes constitutes acceptance of the new terms.''';
      } else {
        return '''# Términos y Condiciones de Uso
Última actualización: 21 de mayo de 2026

Bienvenido a **UniLost & Found** (ULF), la plataforma oficial para la recuperación de objetos perdidos en la Universidad Autónoma de Barcelona (UAB).

## 1. Aceptación de los Términos
Al registrarte y utilizar esta aplicación, aceptas cumplir con todos los términos y condiciones aquí descrits. Si no estás de acuerdo con alguna parte de los términos, no podrás acceder a los servicios.

## 2. Uso Autorizado
Esta aplicación está destinada exclusivamente a miembros de la comunidad universitaria de la UAB (estudiantes, profesores y personal de administración). El registro requiere un correo electrónico institucional válido `@uab.cat`.

## 3. Responsabilidad sobre Publicaciones
Los usuarios son enteramente responsables del contenido, veracidad y estado de los objetos publicados en la plataforma. ULF no se hace responsable de transacciones erróneas o disputas entre usuarios.

## 4. Modificaciones
Nos reservamos el derecho de modificar estos términos en cualquier momento. El uso continuado de la aplicación tras dichos cambios constituye la aceptación de los nuevos términos.''';
      }
    } else {
      // privacy
      if (lang == 'ca') {
        return '''# Política de Privacitat
Última actualització: 21 de maig de 2026

A **UniLost & Found** (ULF), ens prenem molt seriosament la privacitat de les teves dades personals.

## 1. Informació Recopilada
Recopilem informació necessària per al funcionament de la plataforma:
- Dades de compte: Nom, correu institucional `@uab.cat`, rol i campus.
- Publicacions: Fotos, descripcions i ubicació aproximada dels objectes.
- Missatgeria: Contingut dels xats iniciats entre usuaris per a la devolució.

## 2. Ús de la Informació
Les dades recopilades s'utilitzen únicament per facilitar la devolució d'objectes perduts i enviar notificacions de coincidències o missatges nous. No compartim dades amb tercers fora de la UAB.

## 3. Seguretat de Dades
Implementem mesures de seguretat tècniques i organitzatives per protegir les teves dades d'accessos no autoritzats mitjançant autenticació xifrada a Firebase.

## 4. Els Teus Drets
Pots exercitar els teus drets d'accés, rectificació o eliminació de les teves dades en qualsevol moment des dels ajustos del teu compte o contactant a suport tècnic.''';
      } else if (lang == 'en') {
        return '''# Privacy Policy
Last updated: May 21, 2026

At **UniLost & Found** (ULF), we take the privacy of your personal data very seriously.

## 1. Information Collected
We collect information necessary for the platform's operation:
- Account Data: Name, institutional email `@uab.cat`, role, and campus.
- Publications: Photos, descriptions, and approximate location of items.
- Messaging: Content of chats initiated between users for retrieval.

## 2. Use of Information
Collected data is solely used to facilitate the retrieval of lost items and send notifications about matches or new messages. We do not share data with third parties outside the UAB.

## 3. Data Security
We implement technical and organizational security measures to protect your data from unauthorized access using encrypted Firebase authentication.

## 4. Your Rights
You can exercise your rights to access, rectify, or delete your data at any time from your account settings or by contacting technical support.''';
      } else {
        return '''# Política de Privacidad
Última actualización: 21 de mayo de 2026

En **UniLost & Found** (ULF), nos tomamos muy en serio la privacidad de tus datos personales.

## 1. Información Recopilada
Recopilamos información necesaria para el funcionamiento de la plataforma:
- Datos de cuenta: Nombre, correo institucional `@uab.cat`, rol y campus.
- Publicaciones: Fotos, descripciones y ubicación aproximada de los objetos.
- Mensajería: Contenido de los chats iniciados entre usuarios para la devolución.

## 2. Uso de la Información
Los datos recopilados se utilizan únicamente para facilitar la devolución de objetos perdidos y enviar notificaciones de coincidencias o mensajes nuevos. No compartimos datos con terceros fuera de la UAB.

## 3. Seguridad de Datos
Implementamos medidas de seguridad técnicas y organizativas para proteger tus datos de accesos no autorizados mediante autenticación cifrada en Firebase.

## 4. Tus Derechos
Puedes ejercitar tus derechos de acceso, rectificación o eliminación de tus datos en cualquier momento desde los ajustes de tu cuenta o contactando a soporte técnico.''';
      }
    }
  }

  List<Widget> _parseMarkdown(String text, ThemeData theme) {
    final lines = text.split('\n');
    final List<Widget> widgets = [];

    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        widgets.add(const SizedBox(height: 12));
        continue;
      }

      if (trimmed.startsWith('# ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            trimmed.substring(2),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ));
      } else if (trimmed.startsWith('## ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 6),
          child: Text(
            trimmed.substring(3),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ));
      } else if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 6, right: 8),
                child: Icon(Icons.circle, size: 6, color: theme.colorScheme.primary),
              ),
              Expanded(
                child: _parseInlineFormatting(trimmed.substring(2), theme),
              ),
            ],
          ),
        ));
      } else {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _parseInlineFormatting(trimmed, theme),
        ));
      }
    }
    return widgets;
  }

  Widget _parseInlineFormatting(String text, ThemeData theme) {
    final List<InlineSpan> spans = [];
    final parts = text.split('**');
    bool isBold = false;
    for (var part in parts) {
      spans.add(TextSpan(
        text: part,
        style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ));
      isBold = !isBold;
    }
    return RichText(
      text: TextSpan(children: spans),
      softWrap: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final theme = Theme.of(context);

    final title = widget.documentName == 'terms' ? t.termsAndConditions : t.privacyPolicy;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: theme.colorScheme.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Content
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : Scrollbar(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _parseMarkdown(_content ?? "", theme),
                        ),
                      ),
                    ),
            ),
            const Divider(height: 1),
            // Action button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(t.close),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
