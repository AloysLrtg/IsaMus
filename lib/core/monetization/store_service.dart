import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../network/player_repository.dart';
import '../network/retention_repository.dart';

final storeServiceProvider = Provider((ref) {
  final store = StoreService(
    onSynced: () {
      ref.invalidate(playerProfileProvider);
      ref.invalidate(retentionStatusProvider);
    },
  );
  ref.onDispose(store.dispose);
  return store;
});

class StoreService {
  StoreService({this.onSynced});
  final VoidCallback? onSynced;
  bool _disposed = false;
  bool _listening = false;
  Future<void>? _syncing;
  static const vipProductId = String.fromEnvironment(
    'REVENUECAT_VIP_PRODUCT_ID',
    defaultValue: 'isamus.vip.monthly',
  );
  void _customerChanged(CustomerInfo _) {
    if (!_disposed) unawaited(sync().catchError((_) {}));
  }

  void dispose() {
    _disposed = true;
    if (_listening) {
      Purchases.removeCustomerInfoUpdateListener(_customerChanged);
    }
  }

  Future<Package?> vipPackage() async {
    if (!configured) return null;
    final all = await packages();
    return all
        .where(
          (p) =>
              p.storeProduct.identifier == vipProductId &&
              p.packageType == PackageType.monthly,
        )
        .firstOrNull;
  }

  static String? _configuredUser;
  static const _iosKey = String.fromEnvironment('REVENUECAT_IOS_KEY');
  static const _androidKey = String.fromEnvironment('REVENUECAT_ANDROID_KEY');
  bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);
  String get _key =>
      defaultTargetPlatform == TargetPlatform.iOS ? _iosKey : _androidKey;
  bool get configured => supported && _key.isNotEmpty;
  Future<void> _prepare() async {
    if (!configured) {
      throw StateError('La boutique sera disponible après sa configuration.');
    }
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || user.isAnonymous) {
      throw StateError('Sécurisez votre compte avant tout achat.');
    }
    if (_configuredUser == null) {
      await Purchases.configure(
        PurchasesConfiguration(_key)..appUserID = user.id,
      );
    } else if (_configuredUser != user.id) {
      await Purchases.logIn(user.id);
    }
    _configuredUser = user.id;
    if (!_listening && !_disposed) {
      Purchases.addCustomerInfoUpdateListener(_customerChanged);
      _listening = true;
    }
  }

  Future<List<Package>> packages() async {
    await _prepare();
    return (await Purchases.getOfferings()).current?.availablePackages ?? [];
  }

  Future<void> purchase(Package package) async {
    await _prepare();
    await Purchases.purchase(PurchaseParams.package(package));
    await sync();
  }

  Future<void> restore() async {
    await _prepare();
    await Purchases.restorePurchases();
    await sync();
  }

  Future<void> sync() =>
      _syncing ??= _sync().whenComplete(() => _syncing = null);
  Future<void> _sync() async {
    final result = await Supabase.instance.client.functions.invoke(
      'sync-purchases',
    );
    if (result.status != 200) {
      throw StateError(
        'Achat enregistré par le store. Réessayez « Restaurer mes achats » pour synchroniser vos objets.',
      );
    }
    if (!_disposed) onSynced?.call();
  }
}
