import '../../l10n/app_localizations.dart';

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
                    AppLocalizations.of(context)!.menuSeasonRewards,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: AppLocalizations.of(context)!.menuClose,
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!
                  .menuYourSeasonsBestEloDeterminesYourRewardsTiersAre,
            ),
            for (final entry in [
              (
                1000,
                AppLocalizations.of(context)!.menuBronzeBorder,
                Color(0xFFCD8852),
              ),
              (
                1200,
                AppLocalizations.of(context)!.menuSilverBorder,
                Color(0xFFD0DAE6),
              ),
              (
                1400,
                AppLocalizations.of(context)!.menuGoldBorder,
                Color(0xFFFFD54F),
              ),
              (
                1600,
                AppLocalizations.of(context)!.menuTxapelaBeret,
                Color(0xFFB79774),
              ),
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
            Text(
              AppLocalizations.of(context)!
                  .menuAtTheMonthlyCloseEloAndPeakEloReset,
            ),
          ],
        ),
      ),
    );
