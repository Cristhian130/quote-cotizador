import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/product_provider.dart';
import '../../presentation/providers/quote_provider.dart';
import '../../domain/entities/product.dart';
import '../../../../core/theme/ia_colors.dart';
import '../../models/product_item.dart';
import '../organisms/invoice_header.dart';
import '../organisms/search_panel.dart';
import '../organisms/product_table.dart';
import '../organisms/action_bar.dart';
import '../organisms/summary_panel.dart';
import '../organisms/search_results_dialog.dart';
import '../organisms/client_stepper_dialog.dart';
import '../../presentation/services/invoice_pdf_service.dart';
import 'package:intl/intl.dart';

class QuotePage extends ConsumerStatefulWidget {
  const QuotePage({super.key});

  @override
  ConsumerState<QuotePage> createState() => _QuotePageState();
}

class _QuotePageState extends ConsumerState<QuotePage> {
  String referencia = '';
  String descripcion = '';
  String bodega = '';

  // Getters moved to provider or calculated from provider state
  QuoteState get quoteState => ref.watch(quoteProvider);
  List<ProductItem> get items => quoteState.items;
  double get valMercancia => quoteState.valMercancia;
  double get descuentos => quoteState.descuentos;
  double get subtotal => quoteState.subtotal;
  double get ivaTotal => quoteState.ivaTotal;
  double get valorNeto => quoteState.valorNeto;
  bool get cobraDomicilio => quoteState.cobraDomicilio;
  String get vehiculo => quoteState.vehiculo;
  String get ciudad => quoteState.ciudad;
  String get barrio => quoteState.barrio;

  void showToast(String title, [String? description]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (description != null) Text(description),
          ],
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void handleBuscar() async {
    // Validar mínimo 3 letras en descripción si es el único parámetro
    if (descripcion.trim().length > 0 &&
        descripcion.trim().length < 3 &&
        referencia.trim().isEmpty) {
      showToast('Atención', 'Digita al menos 3 letras en la descripción.');
      return;
    }

    try {
      await ref
          .read(productSearchProvider.notifier)
          .search(
            referencia: referencia,
            descripcion: descripcion,
            bodega: bodega,
          );

      final searchState = ref.read(productSearchProvider);

      if (searchState.hasError) {
        final error = searchState.error;
        print('Riverpod AsyncError: $error');
        showToast('Info', 'No se encontraron resultados: $error');
        return;
      }

      searchState.whenData((products) {
        if (products.isEmpty) {
          showToast('Info', 'No se encontraron productos con estos criterios.');
        } else if (products.length == 1) {
          _addProductToInvoice(products.first);
        } else {
          _showSearchResultsModal(products);
        }
      });
    } catch (e, stackTrace) {
      print('=== EXCEPTION IN HANDLE BUSCAR ===');
      print(e);
      print(stackTrace);
      showToast('Error', 'Error inesperado: ${e.toString()}');
    }
  }

  void _addProductToInvoice(Product product) {
    final uniqueId = '${product.referencia}_${product.bodega}';
    final index = items.indexWhere((i) => i.id == uniqueId);
    if (index >= 0) {
      handleUpdateCantidad(uniqueId, items[index].cantidad + 1);
      showToast('Cantidad actualizada', product.descripcion);
    } else {
      final precioConIva = product.precioParti * (1 + product.iva / 100);
      // precioXUnidad = P.+IVA: es la base para descuentos y totales
      ref.read(quoteProvider.notifier).addItem(
        ProductItem(
          id: uniqueId,
          referencia: product.referencia,
          descripcion: product.descripcion,
          bodega: product.bodega,
          disponible: product.disponible,
          ubicacion: product.ubicacion ?? '',
          precioUnitario: product.precioParti,
          iva: product.iva,
          precioConIva: precioConIva,
          descuento: 0,
          descuentoAplicado: 0,
          cantidad: 1,
          precioTotal: precioConIva, // P.+IVA
          precioXUnidad: precioConIva, // P.+IVA como precio de escala
        ),
      );
      showToast('Añadido a factura', product.descripcion);
    }
  }

  void _showSearchResultsModal(List<Product> products) {
    SearchResultsDialog.show(context, products, (selected) {
      for (final p in selected) {
        _addProductToInvoice(p);
      }
    });
  }

  void handleUpdateCantidad(String id, int cantidad) {
    ref.read(quoteProvider.notifier).updateCantidad(id, cantidad);
  }

  void handleUpdateDescuento(String id, double nuevoDescuento) {
    ref.read(quoteProvider.notifier).updateDescuento(id, nuevoDescuento);
  }

  void handleRemoveItem(String id) {
    ref.read(quoteProvider.notifier).removeItem(id);
    showToast('Producto eliminado');
  }

  void handleCalcular() {
    final currencyFormat = NumberFormat.simpleCurrency(
      locale: 'es_CO',
      name: '',
      decimalDigits: 0,
    );
    showToast(
      'Factura calculada correctamente',
      'Valor neto: \$ ${currencyFormat.format(valorNeto)}',
    );
  }

  void handleDescargar() async {
    showToast('Generando factura...');
    try {
      final path = await InvoicePdfService.generateInvoice(quoteState);
      showToast('Descargado', 'Archivo guardado en: $path');
    } catch (e) {
      showToast('Error', 'No se pudo descargar el PDF: $e');
    }
  }

  void handleLimpiar() {
    setState(() {
      referencia = "";
      descripcion = "";
      bodega = "";
    });
    ref.read(quoteProvider.notifier).clear();
    showToast('Factura limpiada');
  }

  void handleAnadirClientes() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ClientStepperDialog(),
    );
  }

  void handleSincronizar() {
    // Controller to manage the dialog's state from outside
    final streamController = StreamController<String>.broadcast();
    bool isSyncing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Row(
                children: [
                  Icon(Icons.sync_rounded, color: IaColors.primary),
                  SizedBox(width: 8),
                  Text(
                    'Sincronizando Base de Datos',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isSyncing)
                      const LinearProgressIndicator(
                        backgroundColor: Color(0xFFE5E7EB), // light grey
                        valueColor: AlwaysStoppedAnimation<Color>(
                          IaColors.primary,
                        ),
                      ),
                    const SizedBox(height: 16),
                    StreamBuilder<String>(
                      stream: streamController.stream,
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data ?? 'Iniciando sincronización...',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF4B5563), // dark grey
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                if (!isSyncing)
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cerrar',
                      style: TextStyle(color: IaColors.primary),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );

    final repo = ref.read(productRepositoryProvider);
    repo
        .syncProducts(
          onProgress: (message) {
            if (!streamController.isClosed) {
              streamController.add(message);
            }
          },
        )
        .then((result) async {
          isSyncing = false;
          if (!mounted) {
            streamController.close();
            return;
          }

          result.fold(
            (failure) {
              if (!streamController.isClosed) {
                streamController.add(
                  '❌ Error de Sincronización: \\n${failure.message}',
                );
              }
            },
            (_) async {
              if (!streamController.isClosed) {
                streamController.add(
                  '✅ ¡Sincronización Exitosa!\\nTu base de datos SQLite ahora está completamente actualizada.',
                );
              }

              // Removed audioplayer logic since we show a dialog at the end
            },
          );

          // Update UI to show close button
          // To force rebuild of actions, we can pop and push or just use a state variable.
          // Since we are not rebuilding the whole dialog from outside, we'll delay a bit and let user close it.
          // Easiest is to pop the dialog and show a toast if they want it gone.
          // But user requested a timeline that stays. The StatefulBuilder doesn't easily trigger from outside the builder.
          // We will close the dialog and show a new one with the final result.
          Navigator.of(context).pop();
          streamController.close();

          result.fold(
            (failure) {
              showToast('Error de Sincronización', failure.message);
            },
            (_) async {
              // Show final success dialog
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: const Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        '¡Sincronización Exitosa!',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  content: const Text(
                    'La información se ha descargado y la base de datos local está actualizada.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text(
                        'Aceptar',
                        style: TextStyle(color: IaColors.primary),
                      ),
                    ),
                  ],
                ),
              );

              try {
                // Play system alert sound to avoid Windows media player URL exceptions
                SystemSound.play(SystemSoundType.alert);
              } catch (e) {
                print('Could not play sound: $e');
              }
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IaColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              const InvoiceHeader(),
              SearchPanel(
                referencia: referencia,
                setReferencia: (v) => setState(() => referencia = v),
                descripcion: descripcion,
                setDescripcion: (v) => setState(() => descripcion = v),
                bodega: bodega,
                setBodega: (v) => setState(() => bodega = v),
                onBuscar: handleBuscar,
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          ProductTable(
                            items: items,
                            onUpdateCantidad: handleUpdateCantidad,
                            onUpdateDescuento: handleUpdateDescuento,
                            onRemoveItem: handleRemoveItem,
                          ),
                          ActionBar(
                            onCalcular: handleCalcular,
                            onDescargar: quoteState.canDownload ? handleDescargar : null,
                            onLimpiar: handleLimpiar,
                            onAnadirClientes: handleAnadirClientes,
                            onSincronizar: handleSincronizar,
                          ),
                        ],
                      ),
                    ),
                      SummaryPanel(
                        valMercancia: valMercancia,
                        descuentos: descuentos,
                        subtotal: subtotal,
                        iva: ivaTotal,
                        cobraDomicilio: cobraDomicilio,
                        setCobraDomicilio: (v) => ref.read(quoteProvider.notifier).updateConfig(cobraDomicilio: v),
                        vehiculo: vehiculo,
                        setVehiculo: (v) => ref.read(quoteProvider.notifier).updateConfig(vehiculo: v ?? 'MO'),
                        ciudad: ciudad,
                        setCiudad: (v) => ref.read(quoteProvider.notifier).updateConfig(ciudad: v ?? ''),
                        barrio: barrio,
                        setBarrio: (v) => ref.read(quoteProvider.notifier).updateConfig(barrio: v ?? ''),
                        valorNeto: valorNeto,
                        bodega: bodega,
                      ),
                  ],
                ),
              ),
            ],
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.1,
                child: Image.asset(
                  'assets/Banner IA-01.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
