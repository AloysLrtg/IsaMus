import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/auth_repository.dart';
import '../../core/network/social_repository.dart';
import 'game_invitation_banner.dart';

enum SocialNoticeKind { success, information }

class SocialNotice {
  const SocialNotice(this.text, this.kind);
  final String text;
  final SocialNoticeKind kind;
}

final socialNoticeProvider =
    NotifierProvider<SocialNoticeController, SocialNotice?>(
      SocialNoticeController.new,
    );

class SocialNoticeController extends Notifier<SocialNotice?> {
  Timer? _timer;
  @override
  SocialNotice? build() {
    ref.onDispose(() => _timer?.cancel());
    return null;
  }

  void show(String text, {SocialNoticeKind kind = SocialNoticeKind.success}) {
    _timer?.cancel();
    state = SocialNotice(text, kind);
    _timer = Timer(const Duration(seconds: 4), () {
      if (ref.mounted) state = null;
    });
  }

  void dismiss() {
    _timer?.cancel();
    state = null;
  }
}

class SocialBannerHost extends ConsumerStatefulWidget {
  const SocialBannerHost({super.key, required this.child, this.navigatorKey});
  final GlobalKey<NavigatorState>? navigatorKey;
  final Widget child;
  @override
  ConsumerState<SocialBannerHost> createState() => _SocialBannerHostState();
}

class _SocialBannerHostState extends ConsumerState<SocialBannerHost> {
  String? _actor;
  bool _primed = false;
  final _seen = <String>{};
  @override
  Widget build(BuildContext context) {
    String? actor;
    try {
      actor = ref.watch(authRepositoryProvider).currentUserId;
    } catch (_) {
      actor = null;
    }
    if (actor != _actor) {
      _actor = actor;
      _primed = false;
      _seen.clear();
    }
    if (actor != null) {
      ref.listen(friendshipsProvider, (_, next) {
        final rows = next.asData?.value;
        if (rows == null) return;
        final incoming = rows
            .where(
              (r) =>
                  (r['receiver_id'] ?? r['user_id_2']) == actor &&
                  r['status'] == 'pending',
            )
            .map((r) => r['id'].toString())
            .toSet();
        final added = incoming.difference(_seen);
        if (_primed && added.isNotEmpty) {
          ref
              .read(socialNoticeProvider.notifier)
              .show(
                added.length == 1
                    ? 'Nouvelle demande d’amitié reçue'
                    : '${added.length} nouvelles demandes d’amitié',
                kind: SocialNoticeKind.information,
              );
        }
        _seen.addAll(incoming);
        _primed = true;
      });
    }
    final notice = ref.watch(socialNoticeProvider);
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (notice != null || actor != null)
          Positioned(
            top: MediaQuery.paddingOf(context).top + 12,
            left: 16,
            right: 16,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 520,
                  maxHeight: MediaQuery.sizeOf(context).height * .6,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (notice != null) _notice(notice),
                      if (notice != null && actor != null)
                        const SizedBox(height: 10),
                      if (actor != null)
                        InvitationInbox(
                          username: 'Joueur',
                          navigatorKey: widget.navigatorKey,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _notice(SocialNotice notice) => Semantics(
    liveRegion: true,
    child: Material(
      key: const ValueKey('social-banner'),
      color: notice.kind == SocialNoticeKind.success
          ? Colors.green.shade700
          : Colors.blue.shade700,
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8, right: 4),
        child: Row(
          children: [
            Icon(
              notice.kind == SocialNoticeKind.success
                  ? Icons.check_circle_outline
                  : Icons.person_add_alt_1,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                notice.text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              key: const ValueKey('close-social-banner'),
              onPressed: () =>
                  ref.read(socialNoticeProvider.notifier).dismiss(),
              icon: const Icon(
                Icons.close,
                color: Colors.white,
                semanticLabel: 'Fermer la notification',
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
