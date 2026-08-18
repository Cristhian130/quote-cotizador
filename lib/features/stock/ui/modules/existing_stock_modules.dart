part of '../stock_screen.dart';

// Stable facades keep the existing ERPNext screens isolated from shell routing.
class _StockTransactionModule extends StatelessWidget {
  const _StockTransactionModule();

  @override
  Widget build(BuildContext context) => const _TransaccionListView();
}

class _PurchaseReceiptModule extends StatelessWidget {
  const _PurchaseReceiptModule();

  @override
  Widget build(BuildContext context) => const _ReciboListView();
}

class _SalesDeliveryModule extends StatelessWidget {
  const _SalesDeliveryModule();

  @override
  Widget build(BuildContext context) => const _SalidaListView();
}

class _MaterialRequestModule extends StatelessWidget {
  const _MaterialRequestModule();

  @override
  Widget build(BuildContext context) => const _SolicitudListView();
}
