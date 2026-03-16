import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/product_item.dart';

class QuoteState {
  final List<ProductItem> items;
  final Map<String, dynamic>? client;
  final bool cobraDomicilio;
  final String vehiculo;
  final String ciudad;
  final String barrio;

  QuoteState({
    this.items = const [],
    this.client,
    this.cobraDomicilio = true,
    this.vehiculo = 'MO',
    this.ciudad = '',
    this.barrio = '',
  });

  // Val. Mercancia = P.+IVA × cantidad (antes de descuento)
  double get valMercancia => items.fold(
    0.0,
    (sum, item) => sum + (item.precioXUnidad * item.cantidad),
  );

  double get descuentos =>
      items.fold(0.0, (sum, item) => sum + item.descuentoAplicado);

  // Subtotal SIN IVA = (P.+IVA×cant - descuentos) - IVA
  double get subtotal => (valMercancia - descuentos) - ivaTotal;

  // IVA informativo: se extrae del precio base para mostrarlo por separado
  double get ivaTotal => items.fold(
    0.0,
    (sum, item) =>
        sum + ((item.precioUnitario * item.cantidad * item.iva) / 100),
  );

  // Valor Neto = Subtotal + IVA (total con IVA)
  double get valorNeto => subtotal + ivaTotal;

  bool get canDownload => items.isNotEmpty && client != null;

  QuoteState copyWith({
    List<ProductItem>? items,
    Map<String, dynamic>? client,
    bool? cobraDomicilio,
    String? vehiculo,
    String? ciudad,
    String? barrio,
  }) {
    return QuoteState(
      items: items ?? this.items,
      client: client ?? this.client,
      cobraDomicilio: cobraDomicilio ?? this.cobraDomicilio,
      vehiculo: vehiculo ?? this.vehiculo,
      ciudad: ciudad ?? this.ciudad,
      barrio: barrio ?? this.barrio,
    );
  }
}

class QuoteNotifier extends Notifier<QuoteState> {
  @override
  QuoteState build() {
    return QuoteState();
  }

  void addItem(ProductItem item) {
    state = state.copyWith(items: [...state.items, item]);
  }

  void updateCantidad(String id, int cantidad) {
    state = state.copyWith(
      items: state.items.map((item) {
        if (item.id != id) return item;
        final base = item.precioXUnidad * cantidad;
        final newDescuentoAplicado = (base * item.descuento) / 100;
        final newPrecioTotal = base - newDescuentoAplicado;
        return item.copyWith(
          cantidad: cantidad,
          descripcion: item.descripcion,
          precioTotal: newPrecioTotal,
          descuentoAplicado: newDescuentoAplicado,
        );
      }).toList(),
    );
  }

  void updateDescuento(String id, double nuevoDescuento) {
    state = state.copyWith(
      items: state.items.map((item) {
        if (item.id != id) return item;
        final safeDescuento = nuevoDescuento.clamp(0.0, 100.0);
        final base = item.precioXUnidad * item.cantidad;
        final newDescuentoAplicado = (base * safeDescuento) / 100;
        final newPrecioTotal = base - newDescuentoAplicado;
        return item.copyWith(
          descuento: safeDescuento,
          descuentoAplicado: newDescuentoAplicado,
          precioTotal: newPrecioTotal,
        );
      }).toList(),
    );
  }

  void removeItem(String id) {
    state = state.copyWith(
      items: state.items.where((item) => item.id != id).toList(),
    );
  }

  void setClient(Map<String, dynamic>? client) {
    state = state.copyWith(client: client);
  }

  void updateConfig({
    bool? cobraDomicilio,
    String? vehiculo,
    String? ciudad,
    String? barrio,
  }) {
    state = state.copyWith(
      cobraDomicilio: cobraDomicilio,
      vehiculo: vehiculo,
      ciudad: ciudad,
      barrio: barrio,
    );
  }

  void clear() {
    state = QuoteState();
  }
}

final quoteProvider = NotifierProvider<QuoteNotifier, QuoteState>(() {
  return QuoteNotifier();
});
