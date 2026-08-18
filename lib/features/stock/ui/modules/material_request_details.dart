part of '../stock_screen.dart';

class _SolicitudDetallesTab extends StatefulWidget {
  const _SolicitudDetallesTab();

  @override
  State<_SolicitudDetallesTab> createState() => _SolicitudDetallesTabState();
}

class _SolicitudDetallesTabState extends State<_SolicitudDetallesTab> {
  String _serie = 'MAT-MR-.YYYY.-';
  String _purpose = 'Purchase';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Container(
        color: const Color(0xFFF4F5F7), // _bodyBg
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _RcCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FormField(
                            label: 'Serie',
                            required: true,
                            child: _DropdownField(
                              value: _serie,
                              items: const ['MAT-MR-.YYYY.-', 'MR-.YYYY.-'],
                              onChanged: (v) => setState(() => _serie = v),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _FormField(
                            label: 'Propósito',
                            required: true,
                            child: _DropdownField(
                              value: _purpose,
                              items: const [
                                'Purchase',
                                'Material Transfer',
                                'Material Issue',
                                'Manufacture',
                                'Customer Provided',
                              ],
                              onChanged: (v) => setState(() => _purpose = v),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    SizedBox(
                      width: 280,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FormField(
                            label: 'Fecha de Transacción',
                            required: true,
                            child: const _ReadOnlyField(
                              value: '12-03-2026',
                              editable: false,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _FormField(
                            label: 'Requerido Por',
                            child: const _TextInputField(hint: ''),
                          ),
                          const SizedBox(height: 14),
                          _FormField(
                            label: 'Lista de Precios',
                            child: const _TextInputField(
                              hint: 'Standard Buying',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Artículos section
            _RcCard(
              child: _InlineAccordion(
                title: 'Artículos',
                initiallyExpanded: true,
                child: Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _FormField(
                              label: 'Escanear Código de Barras',
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 34,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8F9FA),
                                        border: Border.all(
                                          color: const Color(0xFFE2E4E9),
                                        ),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(5),
                                          bottomLeft: Radius.circular(5),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 34,
                                    width: 34,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF8F9FA),
                                      border: Border(
                                        top: BorderSide(
                                          color: Color(0xFFE2E4E9),
                                        ),
                                        right: BorderSide(
                                          color: Color(0xFFE2E4E9),
                                        ),
                                        bottom: BorderSide(
                                          color: Color(0xFFE2E4E9),
                                        ),
                                      ),
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(5),
                                        bottomRight: Radius.circular(5),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.qr_code_scanner,
                                      size: 16,
                                      color: Color(0xFF8A94A6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _FormField(
                              label: 'Bodega Destino',
                              child: Container(
                                height: 34,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F9FA),
                                  border: Border.all(
                                    color: const Color(0xFFE2E4E9),
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Artículos',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF1C2333),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          border: Border.all(color: const Color(0xFFE2E4E9)),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 36,
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Color(0xFFE2E4E9)),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    padding: const EdgeInsets.only(left: 12),
                                    child: _StatefulCheckboxRow(
                                      label: '',
                                      value: false,
                                      onChanged: (v) {},
                                    ),
                                  ),
                                  ...[
                                    _ColDef(id: 'no', label: 'No.', flex: 1),
                                    _ColDef(
                                      id: 'item',
                                      label: 'Código de Artículo',
                                      flex: 4,
                                    ),
                                    _ColDef(
                                      id: 'required_by',
                                      label: 'Requerido Por',
                                      flex: 3,
                                    ),
                                    _ColDef(
                                      id: 'qty',
                                      label: 'Cantidad',
                                      flex: 2,
                                    ),
                                    _ColDef(
                                      id: 'warehouse',
                                      label: 'Bodega',
                                      flex: 3,
                                    ),
                                    _ColDef(id: 'uom', label: 'UDM', flex: 2),
                                  ].map(
                                    (c) => Expanded(
                                      flex: c.flex,
                                      child: _ReciboColHeader(col: c),
                                    ),
                                  ),
                                  const SizedBox(width: 40),
                                ],
                              ),
                            ),
                            Container(
                              height: 40,
                              color: Colors.white,
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    padding: const EdgeInsets.only(left: 12),
                                    child: _StatefulCheckboxRow(
                                      label: '',
                                      value: false,
                                      onChanged: (v) {},
                                    ),
                                  ),
                                  const Expanded(
                                    flex: 1,
                                    child: Text(
                                      '1',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: Color(0xFF1C2333),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          right: BorderSide(
                                            color: Color(0xFFE2E4E9),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          right: BorderSide(
                                            color: Color(0xFFE2E4E9),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      alignment: Alignment.centerLeft,
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          right: BorderSide(
                                            color: Color(0xFFE2E4E9),
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        '0,000',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          color: Color(0xFF1C2333),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          right: BorderSide(
                                            color: Color(0xFFE2E4E9),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(flex: 2, child: Container()),
                                  Container(
                                    width: 40,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        left: BorderSide(
                                          color: Color(0xFFE2E4E9),
                                        ),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.edit_outlined,
                                      size: 14,
                                      color: Color(0xFF8A94A6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF4F5F7), // _bodyBg
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Agregar Fila',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF1C2333),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF4F5F7), // _bodyBg
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Agregar Múltiples',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF1C2333),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF4F5F7), // _bodyBg
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Descargar',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF1C2333),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF4F5F7), // _bodyBg
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Subir',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF1C2333),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Solicitud de Material: Más Información tab
class _SolicitudMasInfoTab extends StatefulWidget {
  const _SolicitudMasInfoTab();

  @override
  State<_SolicitudMasInfoTab> createState() => _SolicitudMasInfoTabState();
}

class _SolicitudMasInfoTabState extends State<_SolicitudMasInfoTab> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Container(
        color: const Color(0xFFF4F5F7), // _bodyBg
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _RcCard(
              child: _InlineAccordion(
                title: 'Detalles de Impresión',
                initiallyExpanded: true,
                child: Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _FormField(
                          label: 'Membrete',
                          child: const _TextInputField(
                            hint: 'Company Letterhead - Grey',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _FormField(
                          label: 'Encabezado de Impresión',
                          child: const _TextInputField(hint: ''),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
