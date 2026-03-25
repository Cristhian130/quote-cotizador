// ──────────────────────────────────────────────────────────────────────────────
//  Stock Alerts Demo Data
//  Shared between Stock (SmartDashboard) and Quote (StockAlertBanner)
// ──────────────────────────────────────────────────────────────────────────────

/// A single inventory item from bodega PV122 (Celeste Medellín).
class StockAlertItem {
  final String referencia;
  final String descripcion;
  final String bodega;
  final double existencia;
  final String unidad;
  final String clasificacion;
  final double cantTransito;
  final double cantComprometida;
  final double costoProm;
  final int diasSinMovimiento;

  const StockAlertItem({
    required this.referencia,
    required this.descripcion,
    required this.bodega,
    required this.existencia,
    required this.unidad,
    required this.clasificacion,
    required this.cantTransito,
    required this.cantComprometida,
    required this.costoProm,
    required this.diasSinMovimiento,
  });
}

/// A business rule that generates an alert.
class StockAlertRule {
  final String id;
  final String nombre;
  final String descripcion;
  final StockAlertType tipo;
  final double umbral;
  final StockAlertAccion accion;
  final double valorAccion; // % descuento o uds a trasladar
  final bool activa;

  const StockAlertRule({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.tipo,
    required this.umbral,
    required this.accion,
    required this.valorAccion,
    this.activa = true,
  });
}

enum StockAlertType {
  sinExistencia,      // Stock = 0
  stockCritico,       // Stock < umbral
  inmovilizado,       // Días sin movimiento > umbral
  sobrestock,         // Existencia > umbral con clasificación baja
  altaDemanda,        // Comprometido/Existencia > umbral %
  enTransito,         // Tiene tránsito significativo pendiente
}

enum StockAlertAccion {
  descuento,
  traslado,
  priorizar,
  reposicion,
  liquidacion,
}

/// A generated alert matching a rule to an item.
class StockAlert {
  final StockAlertRule regla;
  final StockAlertItem item;

  const StockAlert({required this.regla, required this.item});

  String get accionTexto {
    switch (regla.accion) {
      case StockAlertAccion.descuento:
        return 'Aplicar ${regla.valorAccion.toInt()}% descuento';
      case StockAlertAccion.traslado:
        return 'Trasladar ${regla.valorAccion.toInt()} uds';
      case StockAlertAccion.priorizar:
        return 'Priorizar en cotización';
      case StockAlertAccion.reposicion:
        return 'Solicitar reposición';
      case StockAlertAccion.liquidacion:
        return 'Liquidar ${regla.valorAccion.toInt()}% dto máx';
    }
  }
}

// ── 6 Interesting Active Rules ─────────────────────────────────────────────────

const List<StockAlertRule> kDemoAlertRules = [
  StockAlertRule(
    id: 'r1',
    nombre: 'Liquidación urgente — sin stock activo',
    descripcion:
        'Productos con existencia cero en PV122 pero con stock en otras bodegas. '
        'Ofréce traslado o descuento agresivo para cerrar la venta.',
    tipo: StockAlertType.sinExistencia,
    umbral: 0,
    accion: StockAlertAccion.traslado,
    valorAccion: 15,
  ),
  StockAlertRule(
    id: 'r2',
    nombre: 'Inmovilizado > 120 días — liquidar ya',
    descripcion:
        'Artículos que llevan más de 120 días sin movimiento generan costo de '
        'bodegaje. Aplica descuento máximo para liberar capital.',
    tipo: StockAlertType.inmovilizado,
    umbral: 120,
    accion: StockAlertAccion.liquidacion,
    valorAccion: 25,
  ),
  StockAlertRule(
    id: 'r3',
    nombre: 'Alta demanda — prioriza en cotización',
    descripcion:
        'Stock comprometido supera el 70% de la existencia. Prioriza estos '
        'artículos para evitar rupturas y pérdida de clientes.',
    tipo: StockAlertType.altaDemanda,
    umbral: 70,
    accion: StockAlertAccion.priorizar,
    valorAccion: 0,
  ),
  StockAlertRule(
    id: 'r4',
    nombre: 'Sobrestock ZZ — descuento inmediato',
    descripcion:
        'Más de 50 unidades con clasificación ZZ (baja rotación) significan '
        'inventario inmovilizado. Aplica 15% de descuento para activar rotación.',
    tipo: StockAlertType.sobrestock,
    umbral: 50,
    accion: StockAlertAccion.descuento,
    valorAccion: 15,
  ),
  StockAlertRule(
    id: 'r5',
    nombre: 'Stock crítico — repone de inmediato',
    descripcion:
        'Existencia por debajo de 5 unidades en artículos de clasificación A. '
        'Genera solicitud de reposición automática.',
    tipo: StockAlertType.stockCritico,
    umbral: 5,
    accion: StockAlertAccion.reposicion,
    valorAccion: 50,
  ),
  StockAlertRule(
    id: 'r6',
    nombre: 'Tránsito > 30 uds — ofrece preventa',
    descripcion:
        'Más de 30 unidades en tránsito hacia PV122. Ofrécelas al cliente '
        'como preventa con fecha estimada de entrega.',
    tipo: StockAlertType.enTransito,
    umbral: 30,
    accion: StockAlertAccion.priorizar,
    valorAccion: 0,
  ),
];

// ── 50 Demo Products — Bodega PV122 (Celeste Medellín) ─────────────────────────

const List<StockAlertItem> kDemoPV122Items = [
  StockAlertItem(referencia: '000000000094530326', descripcion: 'CLIP PERSIANA OPTRA', bodega: 'PV122', existencia: 0.0, unidad: 'UNID', clasificacion: 'ZZ', cantTransito: 10.0, cantComprometida: 0.0, costoProm: 3714.0, diasSinMovimiento: 180),
  StockAlertItem(referencia: '07I06118', descripcion: 'BOMBILLO GOTERA LUZ MEDIA 158', bodega: 'PV122', existencia: 0.0, unidad: 'UNID', clasificacion: 'ZZ', cantTransito: 10.0, cantComprometida: 0.0, costoProm: 1384.0, diasSinMovimiento: 180),
  StockAlertItem(referencia: '000000000096936800', descripcion: 'MOLDURA TAPIZ COMPART SONIC TR', bodega: 'PV122', existencia: 0.0, unidad: 'UNID', clasificacion: 'ZZ', cantTransito: 10.0, cantComprometida: 0.0, costoProm: 240516.0, diasSinMovimiento: 180),
  StockAlertItem(referencia: '35502-65D30-000', descripcion: 'EXPLORADORA G/VITARA 07 IZQ', bodega: 'PV122', existencia: 0.0, unidad: 'UNID', clasificacion: 'ZZ', cantTransito: 10.0, cantComprometida: 0.0, costoProm: 916012.0, diasSinMovimiento: 180),
  StockAlertItem(referencia: '7175061P10AVF', descripcion: 'MARCO EXPLORADORA SWIFT DER', bodega: 'PV122', existencia: 0.0, unidad: 'UNID', clasificacion: 'ZZ', cantTransito: 10.0, cantComprometida: 0.0, costoProm: 66211.0, diasSinMovimiento: 180),
  StockAlertItem(referencia: '13380-60BT0-000++', descripcion: 'EMP CARBURADOR SW1.3 INCTO', bodega: 'PV122', existencia: 0.0, unidad: 'UNID', clasificacion: 'ZZ', cantTransito: 10.0, cantComprometida: 0.0, costoProm: 8449.0, diasSinMovimiento: 180),
  StockAlertItem(referencia: '8808956276829', descripcion: 'LLAN 225/55 R 17 ZR 101W PS31 ECSTA KUMH', bodega: 'PV122', existencia: 0.0, unidad: 'UNID', clasificacion: 'ZZ', cantTransito: 10.0, cantComprometida: 0.0, costoProm: 551514.0, diasSinMovimiento: 180),
  StockAlertItem(referencia: '000000000023918914', descripcion: 'BARRA EST N300 CTO', bodega: 'PV122', existencia: 0.0, unidad: 'UNID', clasificacion: 'ZZ', cantTransito: 10.0, cantComprometida: 0.0, costoProm: 282753.0, diasSinMovimiento: 180),
  StockAlertItem(referencia: '000000000025187855', descripcion: 'GUAYA CONTROL CAMB ONIX', bodega: 'PV122', existencia: 0.0, unidad: 'UNID', clasificacion: 'ZZ', cantTransito: 10.0, cantComprometida: 0.0, costoProm: 792756.0, diasSinMovimiento: 180),
  StockAlertItem(referencia: '000000000094727089', descripcion: 'MOLDURA EXPLORA TRAILBLAZE D/D', bodega: 'PV122', existencia: 0.0, unidad: 'UNID', clasificacion: 'ZZ', cantTransito: 10.0, cantComprometida: 0.0, costoProm: 498288.0, diasSinMovimiento: 180),
  StockAlertItem(referencia: '000000000025190933', descripcion: 'SENSOR OXIGENO SPARK GT', bodega: 'PV122', existencia: 0.0, unidad: 'UNID', clasificacion: 'ZZ', cantTransito: 10.0, cantComprometida: 0.0, costoProm: 645953.0, diasSinMovimiento: 180),
  StockAlertItem(referencia: '000000000024530165', descripcion: 'HORQUILLA 1A-2A N300', bodega: 'PV122', existencia: 0.0, unidad: 'UNID', clasificacion: 'ZZ', cantTransito: 10.0, cantComprometida: 0.0, costoProm: 56966.0, diasSinMovimiento: 180),
  StockAlertItem(referencia: '000000008975471070', descripcion: 'SOP BOMPER RT-50 14 DEL', bodega: 'PV122', existencia: 0.0, unidad: 'UNID', clasificacion: 'ZZ', cantTransito: 10.0, cantComprometida: 0.0, costoProm: 428387.0, diasSinMovimiento: 180),
  StockAlertItem(referencia: '8808956143145', descripcion: 'LLAN 285/60 R 18 116V HP91 KUMHO', bodega: 'PV122', existencia: 0.0, unidad: 'UNID', clasificacion: 'ZZ', cantTransito: 10.0, cantComprometida: 0.0, costoProm: 836648.0, diasSinMovimiento: 180),
  StockAlertItem(referencia: '000000000024041957', descripcion: 'VALVULA SELENOIDE CRUZE', bodega: 'PV122', existencia: 0.0, unidad: 'UNID', clasificacion: 'ZZ', cantTransito: 10.0, cantComprometida: 0.0, costoProm: 5338379.0, diasSinMovimiento: 180),
  StockAlertItem(referencia: '000000008975567310', descripcion: 'INTERRUPTOR ENCENDIDO FVR-NQR', bodega: 'PV122', existencia: 0.0, unidad: 'UNID', clasificacion: 'ZZ', cantTransito: 10.0, cantComprometida: 0.0, costoProm: 325893.0, diasSinMovimiento: 180),
  StockAlertItem(referencia: '000000008974079000', descripcion: 'TAPIZADO PILAR FRR 15 SUP DER', bodega: 'PV122', existencia: 0.0, unidad: 'UNID', clasificacion: 'ZZ', cantTransito: 10.0, cantComprometida: 0.0, costoProm: 270094.0, diasSinMovimiento: 180),
  StockAlertItem(referencia: '000000000009117716+', descripcion: 'MOTOVENTILADOR CORSA', bodega: 'PV122', existencia: 0.0, unidad: 'UNID', clasificacion: 'ZZ', cantTransito: 10.0, cantComprometida: 0.0, costoProm: 321997.0, diasSinMovimiento: 180),
  StockAlertItem(referencia: '17760-78G50-000', descripcion: 'ENFOCADOR RAD ALTO', bodega: 'PV122', existencia: 0.0, unidad: 'UNID', clasificacion: 'ZZ', cantTransito: 10.0, cantComprometida: 0.0, costoProm: 532799.0, diasSinMovimiento: 180),
  StockAlertItem(referencia: '36739-50J00-000', descripcion: 'FUSIBLE BATERIA G/VITARA', bodega: 'PV122', existencia: 0.0, unidad: 'UNID', clasificacion: 'ZZ', cantTransito: 10.0, cantComprometida: 0.0, costoProm: 57683.0, diasSinMovimiento: 180),
  StockAlertItem(referencia: '000000000093302287+', descripcion: 'SOP MOTOR CORS EVO INF TRAS', bodega: 'PV122', existencia: 1.0, unidad: 'UNID', clasificacion: 'Z', cantTransito: 9.0, cantComprometida: 0.0, costoProm: 65756.0, diasSinMovimiento: 90),
  StockAlertItem(referencia: '000000000025869277+', descripcion: 'SOP MOTOR CAPTIVA3.6 08/10 TRA', bodega: 'PV122', existencia: 1.0, unidad: 'UNID', clasificacion: 'Z', cantTransito: 9.0, cantComprometida: 0.0, costoProm: 259710.0, diasSinMovimiento: 90),
  StockAlertItem(referencia: '000000000094540780+', descripcion: 'SOP MOTOR SPARK GT IZQ', bodega: 'PV122', existencia: 7.0, unidad: 'UNID', clasificacion: 'AA', cantTransito: 3.0, cantComprometida: 5.0, costoProm: 125201.0, diasSinMovimiento: 45),
  StockAlertItem(referencia: '000000000093217461+', descripcion: 'DEP RADIADOR CORSA', bodega: 'PV122', existencia: 4.0, unidad: 'UNID', clasificacion: 'AA', cantTransito: 6.0, cantComprometida: 2.0, costoProm: 49477.0, diasSinMovimiento: 45),
  StockAlertItem(referencia: '000000008973656540+', descripcion: 'HORQUILLA CLUTCH L2.3-TR-DM3.0', bodega: 'PV122', existencia: 2.0, unidad: 'UNID', clasificacion: 'Z', cantTransito: 8.0, cantComprometida: 0.0, costoProm: 63610.0, diasSinMovimiento: 90),
  StockAlertItem(referencia: '13119-77EA0-000*', descripcion: 'EMP MULT ADM G/VITARA2.0', bodega: 'PV122', existencia: 1.0, unidad: 'UNID', clasificacion: 'Z', cantTransito: 9.0, cantComprometida: 0.0, costoProm: 25387.0, diasSinMovimiento: 90),
  StockAlertItem(referencia: '000000000009008914', descripcion: 'CINTA AIRBAG TIMON SAIL', bodega: 'PV122', existencia: 8.0, unidad: 'UNID', clasificacion: 'AA', cantTransito: 2.0, cantComprometida: 6.0, costoProm: 247582.0, diasSinMovimiento: 45),
  StockAlertItem(referencia: '11141M83K01000=', descripcion: 'EMP CULATA NEW SWIFT 1.2', bodega: 'PV122', existencia: 3.0, unidad: 'UNID', clasificacion: 'AA', cantTransito: 7.0, cantComprometida: 1.0, costoProm: 152646.0, diasSinMovimiento: 45),
  StockAlertItem(referencia: '1754054L00000+', descripcion: 'TENSOR CORR ALT G/VITARA 2.4', bodega: 'PV122', existencia: 4.0, unidad: 'UNID', clasificacion: 'AA', cantTransito: 6.0, cantComprometida: 2.0, costoProm: 179210.0, diasSinMovimiento: 45),
  StockAlertItem(referencia: '000000000096351042', descripcion: 'CAUCHO BASE FILTRO AIRE SPARK', bodega: 'PV122', existencia: 11.0, unidad: 'UNID', clasificacion: 'A', cantTransito: 0.0, cantComprometida: 9.0, costoProm: 6186.0, diasSinMovimiento: 10),
  StockAlertItem(referencia: '000000000096590735', descripcion: 'SOP BOMPER CRONOS DEL', bodega: 'PV122', existencia: 2.0, unidad: 'UNID', clasificacion: 'Z', cantTransito: 8.0, cantComprometida: 0.0, costoProm: 120000.0, diasSinMovimiento: 90),
  StockAlertItem(referencia: '000000000019283937-BSH', descripcion: 'P.FRENO AVEO DEL', bodega: 'PV122', existencia: 1.0, unidad: 'UNID', clasificacion: 'Z', cantTransito: 9.0, cantComprometida: 0.0, costoProm: 94341.0, diasSinMovimiento: 90),
  StockAlertItem(referencia: '13765M55R00000', descripcion: 'DUCTO AIRE NEW SWIFT', bodega: 'PV122', existencia: 1.0, unidad: 'UNID', clasificacion: 'Z', cantTransito: 9.0, cantComprometida: 0.0, costoProm: 55373.0, diasSinMovimiento: 90),
  StockAlertItem(referencia: '000000000013516847+', descripcion: 'B.COMB TRACKER', bodega: 'PV122', existencia: 1.0, unidad: 'UNID', clasificacion: 'Z', cantTransito: 9.0, cantComprometida: 0.0, costoProm: 496467.0, diasSinMovimiento: 90),
  StockAlertItem(referencia: '000000008981933440=', descripcion: 'SOP CAJA DMAX RT-50 4X4', bodega: 'PV122', existencia: 2.0, unidad: 'UNID', clasificacion: 'Z', cantTransito: 8.0, cantComprometida: 0.0, costoProm: 330371.0, diasSinMovimiento: 90),
  StockAlertItem(referencia: '000000008973715530+', descripcion: 'ANILLO DMAX3.5 STD', bodega: 'PV122', existencia: 1.0, unidad: 'UNID', clasificacion: 'Z', cantTransito: 9.0, cantComprometida: 0.0, costoProm: 300900.0, diasSinMovimiento: 90),
  StockAlertItem(referencia: '000000000096457238+', descripcion: 'CAMPANA CRONOS-SPARK 07/', bodega: 'PV122', existencia: 2.0, unidad: 'UNID', clasificacion: 'Z', cantTransito: 8.0, cantComprometida: 0.0, costoProm: 138276.0, diasSinMovimiento: 90),
  StockAlertItem(referencia: '48580-65J52-000+', descripcion: 'CAJA DIR G/VITARA2.7 SZ', bodega: 'PV122', existencia: 1.0, unidad: 'UNID', clasificacion: 'Z', cantTransito: 9.0, cantComprometida: 0.0, costoProm: 1220848.0, diasSinMovimiento: 90),
  StockAlertItem(referencia: '000000008981899620', descripcion: 'PIN SINCRON NPR 4A-5A', bodega: 'PV122', existencia: 6.0, unidad: 'UNID', clasificacion: 'AA', cantTransito: 4.0, cantComprometida: 4.0, costoProm: 10166.0, diasSinMovimiento: 45),
  StockAlertItem(referencia: '11189-65J00-000+', descripcion: 'EMP TAPA VALV G/VITA2.0 SZ', bodega: 'PV122', existencia: 1.0, unidad: 'UNID', clasificacion: 'Z', cantTransito: 9.0, cantComprometida: 0.0, costoProm: 52265.0, diasSinMovimiento: 90),
  StockAlertItem(referencia: '000000008944412520', descripcion: 'RODILLO RDA NNR 20/ INT DEL', bodega: 'PV122', existencia: 2.0, unidad: 'UNID', clasificacion: 'Z', cantTransito: 8.0, cantComprometida: 0.0, costoProm: 227590.0, diasSinMovimiento: 90),
  StockAlertItem(referencia: '000000000095089364', descripcion: 'CONECTOR MANG A/A SONIC', bodega: 'PV122', existencia: 1.0, unidad: 'UNID', clasificacion: 'Z', cantTransito: 9.0, cantComprometida: 0.0, costoProm: 45544.0, diasSinMovimiento: 90),
  StockAlertItem(referencia: '000000000095390356', descripcion: 'CAPOT TRACKER LT', bodega: 'PV122', existencia: 2.0, unidad: 'UNID', clasificacion: 'Z', cantTransito: 8.0, cantComprometida: 0.0, costoProm: 2481696.0, diasSinMovimiento: 90),
  StockAlertItem(referencia: '000000000023973398/', descripcion: 'FAROLA N300 IZQ', bodega: 'PV122', existencia: 1.0, unidad: 'UNID', clasificacion: 'Z', cantTransito: 9.0, cantComprometida: 0.0, costoProm: 161681.0, diasSinMovimiento: 90),
  StockAlertItem(referencia: '09482M00609000=', descripcion: 'BUJIA ALTO K10-SWIFT1.2-1.4-CELERI', bodega: 'PV122', existencia: 46.0, unidad: 'UNID', clasificacion: 'A', cantTransito: 0.0, cantComprometida: 44.0, costoProm: 19419.0, diasSinMovimiento: 10),
  StockAlertItem(referencia: '2240061M01000', descripcion: 'DISCO CLUTCH VITARA LIV', bodega: 'PV122', existencia: 1.0, unidad: 'UNID', clasificacion: 'Z', cantTransito: 9.0, cantComprometida: 0.0, costoProm: 653679.0, diasSinMovimiento: 90),
  StockAlertItem(referencia: '15710-65J00-000+', descripcion: 'INYECTOR COMB G/VITARA SZ 2.0', bodega: 'PV122', existencia: 4.0, unidad: 'UNID', clasificacion: 'AA', cantTransito: 6.0, cantComprometida: 2.0, costoProm: 173895.0, diasSinMovimiento: 45),
  StockAlertItem(referencia: '000000000009042063+', descripcion: 'BRAZO AXIAL SAIL', bodega: 'PV122', existencia: 6.0, unidad: 'UNID', clasificacion: 'AA', cantTransito: 4.0, cantComprometida: 4.0, costoProm: 52562.0, diasSinMovimiento: 45),
  StockAlertItem(referencia: '000000008942149850', descripcion: 'EMP TAPA VALV LUV2.3-TROOP', bodega: 'PV122', existencia: 1.0, unidad: 'UNID', clasificacion: 'Z', cantTransito: 9.0, cantComprometida: 0.0, costoProm: 77304.0, diasSinMovimiento: 90),
  StockAlertItem(referencia: '000000000095627820', descripcion: 'EMBLEMA EMOTION AVEO', bodega: 'PV122', existencia: 4.0, unidad: 'UNID', clasificacion: 'AA', cantTransito: 6.0, cantComprometida: 2.0, costoProm: 34163.0, diasSinMovimiento: 45),
];

// ── Alert Engine ──────────────────────────────────────────────────────────────

/// Generates alerts by crossing active rules with the product list.
List<StockAlert> generateAlerts({
  List<StockAlertRule>? rules,
  List<StockAlertItem>? items,
}) {
  final activeRules = (rules ?? kDemoAlertRules).where((r) => r.activa);
  final products = items ?? kDemoPV122Items;
  final alerts = <StockAlert>[];

  for (final rule in activeRules) {
    for (final item in products) {
      bool matches = false;
      switch (rule.tipo) {
        case StockAlertType.sinExistencia:
          matches = item.existencia == 0;
          break;
        case StockAlertType.stockCritico:
          matches = item.existencia > 0 &&
              item.existencia < rule.umbral &&
              (item.clasificacion == 'A' || item.clasificacion == 'AA');
          break;
        case StockAlertType.inmovilizado:
          matches = item.diasSinMovimiento >= rule.umbral;
          break;
        case StockAlertType.sobrestock:
          matches = item.existencia > rule.umbral &&
              (item.clasificacion == 'ZZ' || item.clasificacion == 'Z');
          break;
        case StockAlertType.altaDemanda:
          if (item.existencia > 0) {
            final ratio = (item.cantComprometida / item.existencia) * 100;
            matches = ratio >= rule.umbral;
          }
          break;
        case StockAlertType.enTransito:
          matches = item.cantTransito >= rule.umbral;
          break;
      }
      if (matches) {
        alerts.add(StockAlert(regla: rule, item: item));
      }
    }
  }
  return alerts;
}

/// Returns alerts specific to a given reference (convenience method for UI lists)
List<StockAlert> getAlertsForProduct(String referencia) {
  final refTrimmed = referencia.trim();
  final match = kDemoPV122Items.where((i) => i.referencia.trim() == refTrimmed).toList();
  if (match.isEmpty) return [];
  return generateAlerts(items: match);
}
