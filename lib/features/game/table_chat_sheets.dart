import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/engine/mus_table_feedback.dart';
import '../../core/network/player_repository.dart';
import '../../core/network/table_chat_event.dart';

class QuickChatSheet extends ConsumerStatefulWidget {
  const QuickChatSheet({
    super.key,
    required this.label,
    required this.onSend,
    this.enabled = true,
  });
  final bool enabled;
  final String Function(QuickChat) label;
  final Future<void> Function(QuickChat) onSend;
  @override
  ConsumerState<QuickChatSheet> createState() => _QuickChatSheetState();
}

class _QuickChatSheetState extends ConsumerState<QuickChatSheet> {
  bool _sending = false;
  String? _error;
  Future<void> _send(QuickChat chat) async {
    if (_sending || !widget.enabled) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await widget.onSend(chat);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() {
          _sending = false;
          _error = 'Message non transmis. Réessayez.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final owned = ref.watch(inventoryProvider).asData?.value ?? <String>{};
    return SafeArea(
      top: false,
      child: SizedBox(
        height: math.min(380, MediaQuery.sizeOf(context).height * .7),
        child: DefaultTabController(
          length: 3,
          child: Column(
            children: [
              const TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: [
                  Tab(text: 'Information'),
                  Tab(text: 'Encouragement'),
                  Tab(text: 'Trashtalk'),
                ],
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              Expanded(
                child: TabBarView(
                  children: [
                    for (final category in QuickChatCategory.values)
                      GridView.extent(
                        padding: const EdgeInsets.all(16),
                        maxCrossAxisExtent: 240,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        mainAxisExtent: 64,
                        children: [
                          for (final chat in QuickChat.values.where(
                            (q) =>
                                q.category == category &&
                                (q.shopItemId == null ||
                                    owned.contains(q.shopItemId)),
                          ))
                            FilledButton.tonal(
                              key: ValueKey('quick-option-${chat.name}'),
                              onPressed: _sending || !widget.enabled
                                  ? null
                                  : () => _send(chat),
                              child: Text(
                                widget.label(chat),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TextChatSheet extends ConsumerStatefulWidget {
  const TextChatSheet({
    super.key,
    required this.onSend,
    required this.names,
    required this.quickLabel,
    this.enabled = true,
  });
  final bool enabled;
  final Future<void> Function(String) onSend;
  final List<String> names;
  final String Function(QuickChat) quickLabel;
  @override
  ConsumerState<TextChatSheet> createState() => _TextChatSheetState();
}

class _TextChatSheetState extends ConsumerState<TextChatSheet> {
  final _text = TextEditingController();
  bool _sending = false;
  String? _error;
  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_sending || !widget.enabled) return;
    final text = TableChatEvent.normalize(_text.text);
    if (!TableChatEvent.validText(text)) {
      setState(() => _error = 'Écrivez un message de 1 à 160 caractères.');
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await widget.onSend(text);
      if (mounted) {
        setState(() {
          _sending = false;
          _text.clear();
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _sending = false;
          _error = 'Message non transmis. Votre texte est conservé.';
        });
      }
    }
  }

  Widget _input({required bool compact}) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 6, 8, 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TextField(
            key: const ValueKey('table-chat-input'),
            controller: _text,
            autofocus: true,
            enabled: !_sending && widget.enabled,
            maxLength: TableChatEvent.maxLength,
            minLines: 1,
            maxLines: compact ? 1 : 2,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _send(),
            decoration: InputDecoration(
              hintText: 'Votre message…',
              counterText: compact ? '' : null,
              isDense: true,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        IconButton(
          key: const ValueKey('table-chat-send'),
          tooltip: 'Envoyer',
          onPressed: _sending || !widget.enabled ? null : _send,
          icon: _sending
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.send_rounded),
        ),
        if (compact)
          IconButton(
            tooltip: 'Fermer le chat',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
      ],
    ),
  );
  @override
  Widget build(BuildContext context) {
    final history = ref.watch(
      musTableFeedbackProvider.select((s) => s.chatHistory),
    );
    return AnimatedPadding(
      duration: const Duration(milliseconds: 120),
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final height = math.min(420.0, constraints.maxHeight);
            final compact = height < 220;
            return SizedBox(
              height: height,
              child: compact
                  ? SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_error != null) Text(_error!),
                          _input(compact: true),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Row(
                          children: [
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Chat de la table',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            IconButton(
                              tooltip: 'Fermer le chat',
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                        Expanded(
                          child: history.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Les messages restent dans cette partie.',
                                  ),
                                )
                              : ListView.builder(
                                  key: const ValueKey('table-chat-history'),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  reverse: true,
                                  itemCount: history.length,
                                  itemBuilder: (context, index) {
                                    final entry =
                                        history[history.length - 1 - index];
                                    final speech = entry.speech;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 5,
                                      ),
                                      child: Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text:
                                                  '${widget.names[entry.seat]} : ',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                                  speech.kind ==
                                                      SpeechKind.freeChat
                                                  ? speech.text
                                                  : widget.quickLabel(
                                                      speech.chat!,
                                                    ),
                                              style: TextStyle(
                                                fontStyle:
                                                    !speech.isSystemMessage
                                                    ? FontStyle.italic
                                                    : FontStyle.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              _error!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        _input(compact: false),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }
}
