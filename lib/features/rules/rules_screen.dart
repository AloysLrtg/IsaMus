import 'package:flutter/material.dart';

import 'rules_content.dart';

/// Complete transcription of the supplied FFM championship regulation.
class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          key: const ValueKey('rules-scroll'),
          slivers: [
            SliverAppBar(
              pinned: true,
              leading: Navigator.of(context).canPop()
                  ? const BackButton()
                  : null,
              title: const Text('Règles officielles'),
              backgroundColor: theme.colorScheme.surface,
            ),
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                    child: SelectionArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Icon(
                            Icons.menu_book_rounded,
                            color: Color(0xFF34D399),
                            size: 40,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            officialMusRules['title'] as String,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            officialMusRules['publisher'] as String,
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            officialMusRules['revision'] as String,
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            officialMusRules['contact'] as String,
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 24),
                          for (final section
                              in officialMusRules['sections'] as List)
                            _RulesSection(
                              section: section as Map<String, dynamic>,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RulesSection extends StatelessWidget {
  const _RulesSection({required this.section});
  final Map<String, dynamic> section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                section['title'] as String,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              for (final article in section['articles'] as List) ...[
                const SizedBox(height: 20),
                Text(
                  'Article ${article['number']}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                for (final paragraph in article['paragraphs'] as List)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('•  ', style: TextStyle(height: 1.6)),
                        Expanded(
                          child: Text(
                            paragraph as String,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
