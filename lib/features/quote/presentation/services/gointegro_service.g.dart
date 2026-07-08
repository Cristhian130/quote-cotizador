// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gointegro_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(gointegroService)
final gointegroServiceProvider = GointegroServiceProvider._();

final class GointegroServiceProvider
    extends
        $FunctionalProvider<
          GointegroService,
          GointegroService,
          GointegroService
        >
    with $Provider<GointegroService> {
  GointegroServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gointegroServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gointegroServiceHash();

  @$internal
  @override
  $ProviderElement<GointegroService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GointegroService create(Ref ref) {
    return gointegroService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GointegroService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GointegroService>(value),
    );
  }
}

String _$gointegroServiceHash() => r'bbcd1dc8809ae1ec3bd1fed98ae351a0cd822ab5';
