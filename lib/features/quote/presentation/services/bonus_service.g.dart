// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bonus_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(bonusService)
final bonusServiceProvider = BonusServiceProvider._();

final class BonusServiceProvider
    extends $FunctionalProvider<BonusService, BonusService, BonusService>
    with $Provider<BonusService> {
  BonusServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bonusServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bonusServiceHash();

  @$internal
  @override
  $ProviderElement<BonusService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BonusService create(Ref ref) {
    return bonusService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BonusService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BonusService>(value),
    );
  }
}

String _$bonusServiceHash() => r'4d30d6f9e83d9725ee82427a2e099990ad255be7';
