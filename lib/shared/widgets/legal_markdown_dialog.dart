import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final String path;
    if (widget.documentName == 'faq') {
      path = 'assets/faq/faq_$locale.md';
    } else {
      path = 'assets/legal/${widget.documentName}_$locale.md';
    }
    try {
      final text = await rootBundle.loadString(path);
      if (mounted) {
        setState(() {
          _content = text;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("ULF_DEBUG: Error loading legal document $path: $e");
      if (mounted) {
        final t = AppStrings.of(context);
        setState(() {
          _content = t.legalUnavailable;
          _isLoading = false;
        });
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

    final title = widget.documentName == 'terms'
        ? t.termsAndConditions
        : widget.documentName == 'privacy'
            ? t.privacyPolicy
            : t.faqsLink;

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
