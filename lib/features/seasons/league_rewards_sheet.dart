import 'package:flutter/material.dart';

Future<void> showLeagueRewards(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: .65,
        minChildSize: .4,
        maxChildSize: .9,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Récompenses de Saison',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: 'Fermer',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Votre meilleur Elo de la saison détermine vos récompenses. Les paliers sont cumulatifs.',
            ),
            for (final entry in [
              (1000, 'Bordure Bronze', Color(0xFFCD8852)),
              (1200, 'Bordure Argent', Color(0xFFD0DAE6)),
              (1400, 'Bordure Or', Color(0xFFFFD54F)),
              (1600, 'Txapela (béret)', Color(0xFFB79774)),
            ])
              ListTile(
                leading: Icon(
                  entry.$1 == 1600
                      ? Icons.workspace_premium
                      : Icons.circle_outlined,
                  color: entry.$3,
                ),
                title: Text(entry.$2),
                subtitle: Text('${entry.$1} Elo'),
              ),
            const Divider(),
            const Text(
              'À la clôture mensuelle, l’Elo et le Peak Elo reviennent à 800. Vos cosmétiques restent acquis : équipez-les dans Modifier mon Avatar → Bordures / Trophées.',
            ),
          ],
        ),
      ),
    );
