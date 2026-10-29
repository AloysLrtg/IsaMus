import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/player_repository.dart';
import 'vip_access.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';

bool get adsEnabled =>
    const bool.fromEnvironment('ADS_ENABLED') &&
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android);

class AdsConsent {
  static Future<bool>? _initialization;
  static Future<bool> initialize() => _initialization ??= _initialize();
  static Future<bool> _initialize() async {
    if (!adsEnabled) return false;
    final done = Completer<bool>();
    Future<void> finish() async {
      try {
        final allowed = await ConsentInformation.instance.canRequestAds();
        if (allowed) await MobileAds.instance.initialize();
        if (!done.isCompleted) done.complete(allowed);
      } catch (_) {
        if (!done.isCompleted) done.complete(false);
      }
    }

    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () {
        ConsentForm.loadAndShowConsentFormIfRequired(
          (_) => unawaited(finish()),
        );
      },
      (_) => unawaited(finish()),
    );
    return done.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () => false,
    );
  }

  static Future<void> privacy() async {
    final done = Completer<void>();
    ConsentForm.showPrivacyOptionsForm((error) {
      if (error == null) {
        done.complete();
      } else {
        done.completeError(StateError(error.message));
      }
    });
    await done.future;
    // Banner widgets re-check consent on application resume / rebuild.
    _initialization = null;
  }
}

final adsConfiguredProvider = Provider<bool>((ref) => adsEnabled);
final canShowAdsProvider = Provider<bool>((ref) {
  final profile = ref.watch(playerProfileProvider);
  return ref.watch(adsConfiguredProvider) &&
      profile is AsyncData<Map<String, dynamic>> &&
      !profile.isLoading &&
      !profile.hasError &&
      !ref.watch(vipAccessProvider);
});

class DashboardAdBanner extends ConsumerWidget {
  const DashboardAdBanner({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ref.watch(canShowAdsProvider)
      ? const _ManagedAdBanner()
      : const SizedBox.shrink();
}

class _ManagedAdBanner extends StatefulWidget {
  const _ManagedAdBanner();
  @override
  State<_ManagedAdBanner> createState() => _DashboardAdBannerState();
}

class _DashboardAdBannerState extends State<_ManagedAdBanner>
    with WidgetsBindingObserver {
  BannerAd? _banner;
  bool _loaded = false;
  int _generation = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_load());
  }

  Future<void> _load() async {
    final generation = ++_generation;
    if (!await AdsConsent.initialize() ||
        !mounted ||
        generation != _generation) {
      return;
    }
    final unit = defaultTargetPlatform == TargetPlatform.iOS
        ? const String.fromEnvironment(
            'ADMOB_IOS_BANNER',
            defaultValue: 'ca-app-pub-3940256099942544/2934735716',
          )
        : const String.fromEnvironment(
            'ADMOB_ANDROID_BANNER',
            defaultValue: 'ca-app-pub-3940256099942544/6300978111',
          );
    final banner = BannerAd(
      size: AdSize.banner,
      adUnitId: unit,
      request: const AdRequest(nonPersonalizedAds: true),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted && generation == _generation) {
            setState(() => _loaded = true);
          } else {
            ad.dispose();
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    _banner = banner;
    await banner.load();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_check());
  }

  Future<void> _check() async {
    if (!await ConsentInformation.instance.canRequestAds() && mounted) {
      _banner?.dispose();
      setState(() {
        _banner = null;
        _loaded = false;
      });
    }
  }

  @override
  void dispose() {
    _generation++;
    WidgetsBinding.instance.removeObserver(this);
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _loaded && _banner != null
      ? SizedBox(height: 50, width: 320, child: AdWidget(ad: _banner!))
      : const SizedBox.shrink();
}
