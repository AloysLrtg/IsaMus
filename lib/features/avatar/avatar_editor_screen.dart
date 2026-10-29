import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/avatar_config.dart';
import '../../core/network/player_repository.dart';
import '../../core/network/social_repository.dart';
import 'player_avatar_view.dart';
import 'avatar_palette.dart';

class AvatarEditorScreen extends ConsumerStatefulWidget {
  const AvatarEditorScreen({super.key, required this.initialConfig});
  final AvatarConfig initialConfig;
  @override
  ConsumerState<AvatarEditorScreen> createState() => _AvatarEditorScreenState();
}

class _AvatarEditorScreenState extends ConsumerState<AvatarEditorScreen> {
  late AvatarConfig _draft = widget.initialConfig;
  bool _saving = false;
  String? _error;
  static const _labels = [
    'Peau',
    'Cheveux',
    'Lunettes',
    'Haut',
    'Couleur de fond',
    'Couleur cheveux',
    'Bordures',
    'Couvre-chefs',
  ];

  String? _rewardLabel(AvatarPart part, int option) => switch (part) {
    AvatarPart.border => [
      'Aucune',
      'Bronze',
      'Argent',
      'Or',
      'Diamant',
    ][option],
    AvatarPart.exclusiveHat => [
      'Aucun',
      'Txapela',
      'Couronne',
      'Casquette',
      'Bonnet',
    ][option],
    AvatarPart.hair when option == AvatarConfig.baldHair => 'Chauve',
    AvatarPart.hair when option == AvatarConfig.mohawkHair => 'Crête',
    AvatarPart.glasses when option == 3 => 'Monture dorée',
    AvatarPart.glasses when option == 4 => 'Rondes',
    AvatarPart.top when option == 3 => 'Maillot rayé',
    _ => null,
  };

  Future<void> _save() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(playerRepositoryProvider).saveAvatar(_draft);
      if (!mounted) return;
      ref.invalidate(playerProfileProvider);
      ref.invalidate(personProvider);
      // Enable popping before completing the editor route.
      setState(() => _saving = false);
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error =
            'Sauvegarde impossible. Vérifiez votre connexion et réessayez.';
      });
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: DefaultTabController(
      length: AvatarPart.values.length,
      child: Scaffold(
        appBar: AppBar(title: const Text('Modifier mon Avatar')),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final previewSize = (constraints.maxHeight * .3).clamp(
                64.0,
                160.0,
              );
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: PlayerAvatarView(
                      key: const ValueKey('avatar-preview'),
                      config: _draft,
                      size: previewSize,
                    ),
                  ),
                  TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.center,
                    tabs: [for (final label in _labels) Tab(text: label)],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        for (final part in AvatarPart.values)
                          GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                            itemCount: part == AvatarPart.hair
                                ? AvatarConfig.hairCount - 1
                                : AvatarConfig.countFor(part),
                            itemBuilder: (context, index) {
                              final option =
                                  part == AvatarPart.hair && index >= 3
                                  ? index + 1
                                  : index;
                              final item = AvatarConfig.cosmeticIdFor(
                                part,
                                option,
                              );
                              final owned =
                                  item == null ||
                                  (ref
                                          .watch(inventoryProvider)
                                          .asData
                                          ?.value
                                          .contains(item) ??
                                      false);
                              final selected = _draft.valueFor(part) == option;
                              return Semantics(
                                selected: selected,
                                button: true,
                                label: part == AvatarPart.backgroundColor
                                    ? AvatarPalette.backgroundLabels[option]
                                    : part == AvatarPart.hairColor
                                    ? AvatarPalette.hairLabels[option]
                                    : _rewardLabel(part, option) ??
                                          '${_labels[part.index]} : option ${option + 1}',
                                child: Material(
                                  color: selected
                                      ? Theme.of(context)
                                            .colorScheme
                                            .primaryContainer
                                      : Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHighest,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(
                                      color: selected
                                          ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: InkWell(
                                    key: ValueKey(
                                      'avatar-${part.jsonKey}-$option',
                                    ),
                                    onTap: _saving || !owned
                                        ? null
                                        : () => setState(() {
                                            _draft = _draft.withOption(
                                              part,
                                              option,
                                            );
                                          }),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Opacity(
                                            opacity: owned ? 1 : .35,
                                            child: PlayerAvatarView(
                                              config: _draft.withOption(
                                                part,
                                                option,
                                              ),
                                            ),
                                          ),
                                          if (_rewardLabel(part, option) !=
                                              null)
                                            Align(
                                              alignment: Alignment.bottomCenter,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 4,
                                                      vertical: 2,
                                                    ),
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .surface
                                                    .withValues(alpha: .9),
                                                child: Text(
                                                  _rewardLabel(part, option)!,
                                                  maxLines: 1,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelSmall,
                                                ),
                                              ),
                                            ),
                                          if (!owned)
                                            const Align(
                                              alignment: Alignment.bottomRight,
                                              child: Icon(Icons.lock_outline),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        key: const ValueKey('avatar-save-button'),
                        onPressed: _saving ? null : _save,
                        icon: _saving
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(_saving ? 'Sauvegarde…' : 'Sauvegarder'),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );
}
