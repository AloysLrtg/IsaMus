import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/player_repository.dart';
import '../../core/models/avatar_config.dart';
import '../avatar/avatar_editor_screen.dart';
import '../avatar/player_avatar_view.dart';
import '../../core/models/profile_statistics.dart';
import 'profile_statistics_view.dart';
import 'profile_progress_view.dart';
import '../inventory/inventory_screen.dart';
import '../../core/models/player_progress.dart';

IconData avatarIcon(String? id) => switch (id) {
  'sun' => Icons.wb_sunny_rounded,
  'mountain' => Icons.landscape_rounded,
  _ => Icons.style_rounded,
};
Color tableColor(String? id) => switch (id) {
  'ocean' => const Color(0xFF123D65),
  'ruby' => const Color(0xFF611E36),
  _ => const Color(0xFF0A4F36),
};
Color backColor(String? id) => switch (id) {
  'gold' => const Color(0xFFD9BC72),
  'shop_back_emerald' => const Color(0xFF047857),
  'shop_back_violet' => const Color(0xFF7C3AED),
  'blue' => const Color(0xFF2563EB),
  _ => const Color(0xFF233F73),
};

class ProfileTab extends ConsumerStatefulWidget {
  const ProfileTab({super.key, required this.onChanged});
  final VoidCallback onChanged;
  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab> {
  bool _busy = false;
  String? _message;
  Future<void> _run(Future<void> Function() action, {String? success}) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await action();
      ref.invalidate(playerProfileProvider);
      widget.onChanged();
      if (mounted) setState(() => _message = success);
    } catch (_) {
      if (mounted) {
        setState(
          () => _message =
              'Action impossible. Vérifiez votre connexion et réessayez.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _rename(String current) async {
    final controller = TextEditingController(text: current);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le pseudo'),
        content: TextField(
          controller: controller,
          maxLength: 24,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    // Dialog route may still animate while the controller is attached.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    controller.dispose();
    if (name != null && mounted) {
      await _run(() => ref.read(playerRepositoryProvider).rename(name));
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(playerProfileProvider);
    return profile.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(
        child: TextButton(
          onPressed: () => ref.invalidate(playerProfileProvider),
          child: const Text('Profil indisponible. Réessayer'),
        ),
      ),
      data: (p) {
        final statistics = ProfileStatistics.fromProfile(p);
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Profil Joueur',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            ListTile(
              leading: PlayerAvatarView(
                config: AvatarConfig.fromJson(p['avatar_config']),
                size: 48,
              ),
              title: Text(p['username'] as String),
              subtitle: Text('${p['elo']} Elo'),
              trailing: IconButton(
                tooltip: 'Modifier le pseudo',
                onPressed: _busy
                    ? null
                    : () => _rename(p['username'] as String),
                icon: const Icon(Icons.edit),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: FilledButton.icon(
                key: const ValueKey('edit-avatar-button'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                icon: const Icon(Icons.face_retouching_natural),
                label: const Text('Modifier mon Avatar'),
                onPressed: _busy
                    ? null
                    : () async {
                        final saved = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (_) => AvatarEditorScreen(
                              initialConfig: AvatarConfig.fromJson(
                                p['avatar_config'],
                              ),
                            ),
                          ),
                        );
                        if (mounted && saved == true) widget.onChanged();
                      },
              ),
            ),
            OutlinedButton(
              key: const ValueKey('open-inventory-button'),
              onPressed: _busy
                  ? null
                  : () async {
                      await Navigator.of(context).push<void>(
                        MaterialPageRoute(
                          builder: (_) => const InventoryScreen(),
                        ),
                      );
                      if (mounted) widget.onChanged();
                    },
              child: const Text('Personnalisation'),
            ),
            const SizedBox(height: 12),
            if (_busy) const LinearProgressIndicator(),
            if (_message != null) Text(_message!),
            ProfileProgressView(progress: PlayerProgress.fromJson(p)),
            const SizedBox(height: 12),
            ProfileStatisticsView(statistics: statistics),
            const Divider(),
            const Text(
              'Dernières parties',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ref
                .watch(matchHistoryProvider)
                .when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, _) => TextButton(
                    onPressed: () => ref.invalidate(matchHistoryProvider),
                    child: const Text('Recharger l’historique'),
                  ),
                  data: (rows) => Column(
                    children: [
                      if (rows.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Vos prochaines parties terminées apparaîtront ici.',
                          ),
                        ),
                      for (final row in rows)
                        ListTile(
                          leading: Icon(
                            row['won'] == true
                                ? Icons.emoji_events
                                : Icons.sports_esports,
                            color: row['won'] == true ? Colors.amber : null,
                          ),
                          title: Text(
                            row['won'] == true ? 'Victoire' : 'Défaite',
                          ),
                          subtitle: Text(
                            '${row['mode'] == 'ranked'
                                ? 'Classé'
                                : row['mode'] == 'solo'
                                ? 'Solo'
                                : row['mode'] == 'private'
                                ? 'Privé'
                                : 'Classique'} · ${DateTime.parse(row['finished_at'] as String).toLocal().toString().substring(0, 16)}',
                          ),
                          trailing: Text(
                            '${(row['elo_after'] as num) - (row['elo_before'] as num)} Elo',
                          ),
                        ),
                    ],
                  ),
                ),
          ],
        );
      },
    );
  }
}
