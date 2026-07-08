import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/quote_provider.dart';
import '../../presentation/providers/product_provider.dart';
import '../../presentation/services/bonus_service.dart';
import '../../presentation/services/gointegro_service.dart';
import '../../../../core/config/app_config.dart';
import 'dart:convert';

class BonusItem {
  final String reference;
  final String description;
  int quantity;
  double unitPrice;
  double discountValue;
  String consecutive;
  String deliveryDays;
  String notes;
  double iva;

  BonusItem({
    required this.reference,
    required this.description,
    this.quantity = 1,
    required this.unitPrice,
    this.discountValue = 0.0,
    this.consecutive = '1',
    this.deliveryDays = '3',
    this.notes = '',
    this.iva = 0.0,
  });

  Map<String, dynamic> toJson() {
    final map = {
      "consecutive": consecutive,
      "deliveryDays": deliveryDays,
      "itemReference": reference,
      "quantity": quantity.toString(),
    };
    if (unitPrice > 0) map["unitPrice"] = unitPrice.toString();
    if (discountValue > 0) map["discountValue"] = discountValue.toString();
    if (notes.isNotEmpty) map["notes"] = notes;
    return map;
  }
}

class BonusDialog extends ConsumerStatefulWidget {
  final String activeBodega;
  const BonusDialog({super.key, this.activeBodega = ''});

  @override
  ConsumerState<BonusDialog> createState() => _BonusDialogState();
}

class _BonusDialogState extends ConsumerState<BonusDialog>
    with SingleTickerProviderStateMixin {
  // Theme Colors (GitHub Dark)
  final Color bgDark = const Color(0xFF0D1117);
  final Color bgCard = const Color(0xFF161B22);
  final Color borderDark = const Color(0xFF30363D);
  final Color textPrimary = const Color(0xFFF0F6FC);
  final Color textSecondary = const Color(0xFF8B949E);
  final Color greenSuccess = const Color(0xFF2EA44F);
  final Color blueLoading = const Color(0xFF58A6FF);
  final Color redAlert = const Color(0xFFF85149);

  // Controllers
  final _customerIdController = TextEditingController();
  final _sellerIdController = TextEditingController();
  final _promoCodeController = TextEditingController();
  final _companyIdController = TextEditingController();
  final _operationCenterController = TextEditingController();

  // Search & Items
  final _searchController = TextEditingController();
  bool _isSearching = false;
  List<dynamic> _searchResults = []; // From SQLite

  final List<BonusItem> _addedItems = [];

  // Item Editing (Current)
  String? _selectedRef;
  String? _selectedDesc;
  double _selectedPrice = 0.0;
  double _selectedIva = 0.0;
  final _qtyController = TextEditingController(text: '1');
  final _discountController = TextEditingController(text: '0');
  final _consecutiveController = TextEditingController(text: '1');
  final _deliveryDaysController = TextEditingController(text: '3');
  final _notesController = TextEditingController();

  // Tracking State
  int _currentStep = 0; // 0: Init, 1: Validated, 2: Compiled, 3: Preview OK, 4: Applied
  bool _isLoadingStep = false;
  bool _hasError = false;

  final List<Map<String, dynamic>> _previewResults = [];
  final List<Map<String, dynamic>> _orderResults = [];
  final List<String> _logs = [];
  
  BonusValidationResult? _bonusInfo;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initForm();
    });
  }

  void _initForm() {
    final client = ref.read(quoteProvider).client;
    if (client != null && client.containsKey('cedula')) {
      _customerIdController.text = client['cedula']?.toString() ?? '';
    }
    _sellerIdController.text = AppConfig.sellerName;
    _companyIdController.text = _getCompanyId(widget.activeBodega);
    _operationCenterController.text = _getOperationCenter(widget.activeBodega);

    // Pre-fill with items from current quote
    final currentItems = ref.read(quoteProvider).items;
    int consec = 1;
    for (var item in currentItems) {
      _addedItems.add(BonusItem(
        reference: item.referencia,
        description: item.descripcion,
        quantity: item.cantidad,
        unitPrice: item.precioXUnidad,
        discountValue: item.descuentoAplicado,
        consecutive: consec.toString(),
        deliveryDays: '3',
        notes: '',
        iva: item.iva,
      ));
      consec++;
    }
    _updateCompilationStep();
    setState(() {});
  }

  String _getCompanyId(String bodega) {
    final digits = bodega.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.isNotEmpty ? digits[0] : '3';
  }

  String _getOperationCenter(String bodega) {
    final digits = bodega.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.isNotEmpty ? digits : '322';
  }

  @override
  void dispose() {
    _customerIdController.dispose();
    _sellerIdController.dispose();
    _promoCodeController.dispose();
    _companyIdController.dispose();
    _operationCenterController.dispose();
    _searchController.dispose();
    _qtyController.dispose();
    _discountController.dispose();
    _consecutiveController.dispose();
    _deliveryDaysController.dispose();
    _notesController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _addLog(String msg) {
    setState(() {
      _logs.add("[${DateTime.now().toIso8601String().substring(11, 19)}] $msg");
    });
  }

  Future<void> _validatePromo() async {
    final code = _promoCodeController.text.trim();
    if (code.isEmpty) return;
    
    setState(() {
      _isLoadingStep = true;
      _currentStep = 0;
      _hasError = false;
      _bonusInfo = null;
    });
    _addLog("Iniciando validación del bono con GOintegro...");

    final service = ref.read(gointegroServiceProvider);
    final result = await service.validateBonusCode(code);

    if (result.isValid) {
      setState(() {
        _isLoadingStep = false;
        _currentStep = 1; // Validated
        _bonusInfo = result;
      });
      _addLog("Bono validado exitosamente: ${result.title} (${result.amount})");
      _updateCompilationStep();
    } else {
      setState(() {
        _isLoadingStep = false;
        _hasError = true;
      });
      _addLog("Error validando bono: ${result.errorMsg}");
    }
  }

  void _updateCompilationStep() {
    if (_currentStep >= 1) {
      bool isFormFilled = _customerIdController.text.isNotEmpty &&
          _sellerIdController.text.isNotEmpty &&
          _companyIdController.text.isNotEmpty &&
          _operationCenterController.text.isNotEmpty;

      if (isFormFilled && _addedItems.isNotEmpty) {
        setState(() {
          if (_currentStep < 2) _currentStep = 2; // Compiled
        });
        if (_currentStep == 2) {
          _addLog("Payload compilado correctamente (${_addedItems.length} referencias).");
        }
      } else {
        setState(() {
          _currentStep = 1; // Revert to validated if items removed
        });
      }
    }
  }

  Future<void> _doSearch(String query) async {
    if (query.trim().length < 3) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    final sqlite = ref.read(sqliteDataSourceProvider);
    final results = await sqlite.searchProducts(referencia: query);
    final resultsDesc = await sqlite.searchProducts(descripcion: query);
    
    final combined = [...results, ...resultsDesc];
    // deduplicate by referencia
    final Map<String, dynamic> unique = {};
    for (var p in combined) {
      unique[p.referencia] = p;
    }

    setState(() {
      _searchResults = unique.values.toList();
      _isSearching = false;
    });
  }

  void _selectProduct(dynamic product) {
    setState(() {
      _selectedRef = product.referencia;
      _selectedDesc = product.descripcion;
      _selectedPrice = product.precioParti;
      _selectedIva = product.iva;
      
      _consecutiveController.text = (_addedItems.length + 1).toString();
      _qtyController.text = '1';
      _discountController.text = '0';
      _searchResults = [];
      _searchController.clear();
    });
  }

  void _addItem() {
    if (_selectedRef == null) return;
    setState(() {
      _addedItems.add(BonusItem(
        reference: _selectedRef!,
        description: _selectedDesc!,
        quantity: int.tryParse(_qtyController.text) ?? 1,
        unitPrice: _selectedPrice,
        discountValue: double.tryParse(_discountController.text) ?? 0.0,
        consecutive: _consecutiveController.text,
        deliveryDays: _deliveryDaysController.text,
        notes: _notesController.text,
        iva: _selectedIva,
      ));
      
      // Clear selection
      _selectedRef = null;
      _selectedDesc = null;
    });
    _updateCompilationStep();
  }

  void _removeItem(int index) {
    setState(() {
      _addedItems.removeAt(index);
    });
    _updateCompilationStep();
  }

  Map<String, dynamic> _getHeader() {
    return {
      "companyId": _companyIdController.text.trim(),
      "operationCenter": _operationCenterController.text.trim(),
      "customerId": _customerIdController.text.trim(),
      "sellerId": _sellerIdController.text.trim(),
      "promoCode": _promoCodeController.text.trim(),
    };
  }

  Future<void> _handlePreview() async {
    if (_currentStep < 2) return;
    _tabController.animateTo(1);
    
    setState(() {
      _isLoadingStep = true;
      _hasError = false;
      _previewResults.clear();
      _orderResults.clear();
    });
    _addLog("Iniciando Previsualización (Preview) para ${_addedItems.length} referencias...");

    final service = ref.read(bonusServiceProvider);
    final header = _getHeader();
    bool allSuccess = true;

    final List<Map<String, dynamic>> itemsPayload = _addedItems.map((item) => item.toJson()).toList();
    _addLog("Enviando Preview en un solo request...");
    try {
      final response = await service.previewBonus(
        companyId: header['companyId'],
        operationCenter: header['operationCenter'],
        customerId: header['customerId'],
        sellerId: header['sellerId'],
        promoCode: header['promoCode'],
        items: itemsPayload,
      );
      _previewResults.add(response);
      _addLog(" OK Preview");
    } catch (e) {
      _addLog(" ERROR Preview: $e");
      allSuccess = false;
    }

    setState(() {
      _isLoadingStep = false;
      if (allSuccess) {
        _currentStep = 3; // Preview OK
        _addLog("Previsualización completada con éxito.");
      } else {
        _hasError = true;
        _addLog("Previsualización finalizó con errores.");
      }
    });
  }

  Future<void> _handleApply() async {
    if (_currentStep < 3) return;
    _tabController.animateTo(1);
    
    setState(() {
      _isLoadingStep = true;
      _hasError = false;
      _orderResults.clear();
    });
    _addLog("Iniciando Creación de Pedido en Siesa (Apply) para ${_addedItems.length} referencias...");

    final service = ref.read(bonusServiceProvider);
    final header = _getHeader();
    bool allSuccess = true;

    final List<Map<String, dynamic>> itemsPayload = _addedItems.map((item) => item.toJson()).toList();
    _addLog("Enviando Pedido en un solo request...");
    try {
      final response = await service.applyBonusOrders(
        companyId: header['companyId'],
        operationCenter: header['operationCenter'],
        customerId: header['customerId'],
        sellerId: header['sellerId'],
        promoCode: header['promoCode'],
        items: itemsPayload,
      );
      _orderResults.add(response);
      _addLog(" OK Pedido procesado");
    } catch (e) {
      _addLog(" ERROR Pedido: $e");
      allSuccess = false;
    }

    setState(() {
      _isLoadingStep = false;
      if (allSuccess) {
        _currentStep = 4; // Applied OK
        _addLog("Pedido enviado a Siesa con éxito.");
      } else {
        _hasError = true;
        _addLog("El envío a Siesa finalizó con errores.");
      }
    });
  }

  // ==== UI Helpers (GitHub Dark) ====

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumeric = false, Function(String)? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          height: 36,
          decoration: BoxDecoration(
            color: bgDark,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: borderDark),
          ),
          child: TextField(
            controller: controller,
            style: TextStyle(color: textPrimary, fontSize: 14),
            keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
            onChanged: onChanged,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String text, int stepIndex) {
    Color badgeColor = bgCard;
    Color textColor = textSecondary;
    IconData? icon;

    if (_currentStep == stepIndex && _isLoadingStep) {
      badgeColor = blueLoading.withOpacity(0.15);
      textColor = blueLoading;
      icon = Icons.hourglass_top;
    } else if (_currentStep > stepIndex || (_currentStep == stepIndex && !_isLoadingStep && !_hasError)) {
      badgeColor = greenSuccess.withOpacity(0.15);
      textColor = greenSuccess;
      icon = Icons.check_circle_outline;
    } else if (_currentStep == stepIndex && _hasError) {
      badgeColor = redAlert.withOpacity(0.15);
      textColor = redAlert;
      icon = Icons.error_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 6),
          ],
          if (_currentStep == stepIndex && _isLoadingStep)
            SizedBox(
              width: 12, height: 12,
              child: CircularProgressIndicator(strokeWidth: 2, color: textColor),
            ),
          if (_currentStep == stepIndex && _isLoadingStep) const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Workflow Status", style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatusBadge("1. Bono Validado", 1),
              Expanded(child: Divider(color: borderDark)),
              _buildStatusBadge("2. Payload Compilado", 2),
              Expanded(child: Divider(color: borderDark)),
              _buildStatusBadge("3. Previsualización OK", 3),
              Expanded(child: Divider(color: borderDark)),
              _buildStatusBadge("4. Pedido en Siesa", 4),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJsonBlock() {
    final header = _getHeader();
    header["items"] = _addedItems.map((item) => item.toJson()).toList();

    final jsonEncoder = const JsonEncoder.withIndent('  ');
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: bgCard,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              border: Border(bottom: BorderSide(color: borderDark)),
            ),
            child: Row(
              children: [
                Icon(Icons.terminal, color: textSecondary, size: 16),
                const SizedBox(width: 8),
                Text("siesa_sync.json", style: TextStyle(color: textSecondary, fontSize: 13, fontFamily: 'monospace')),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _orderResults.isNotEmpty
                ? "// RESPUESTAS SIESA\n${jsonEncoder.convert(_orderResults)}"
                : _previewResults.isNotEmpty
                  ? "// RESPUESTAS PREVIEW\n${jsonEncoder.convert(_previewResults)}"
                  : "// PAYLOAD COMPILADO (${_addedItems.length} referencias)\n${jsonEncoder.convert(header)}",
              style: TextStyle(
                color: _hasError ? redAlert : const Color(0xFFE5C07B),
                fontFamily: 'monospace',
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsTerminal() {
    return Container(
      width: double.infinity,
      height: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderDark),
      ),
      child: ListView.builder(
        itemCount: _logs.length,
        itemBuilder: (ctx, i) {
          final log = _logs[i];
          Color color = textPrimary;
          if (log.contains("ERROR")) color = redAlert;
          if (log.contains("OK") || log.contains("exitosamente")) color = greenSuccess;
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              log,
              style: TextStyle(color: color, fontFamily: 'monospace', fontSize: 12),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: bgDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderDark, width: 1),
      ),
      child: SizedBox(
        width: 1100,
        height: 750,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: bgCard,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                border: Border(bottom: BorderSide(color: borderDark)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.discount_rounded, color: textPrimary),
                      const SizedBox(width: 12),
                      Text(
                        'Integración Siesa Sync (Bono)',
                        style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ),
            ),
            
            // Body
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left Col: Form & Items
                  Expanded(
                    flex: 5,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(right: BorderSide(color: borderDark)),
                      ),
                      child: Column(
                        children: [
                          TabBar(
                            controller: _tabController,
                            labelColor: textPrimary,
                            unselectedLabelColor: textSecondary,
                            indicatorColor: blueLoading,
                            tabs: const [
                              Tab(text: "Configuración & Referencias"),
                              Tab(text: "Previsualización & Tracking"),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                // TAB 1: FORM
                                SingleChildScrollView(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Cabecera Siesa
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: bgCard,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: borderDark),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Cabecera del Pedido", style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 16),
                                            Row(
                                              children: [
                                                Expanded(child: _buildTextField('Cédula Cliente', _customerIdController)),
                                                const SizedBox(width: 12),
                                                Expanded(child: _buildTextField('ID Vendedor', _sellerIdController)),
                                                const SizedBox(width: 12),
                                                Expanded(child: _buildTextField('Compañía', _companyIdController)),
                                                const SizedBox(width: 12),
                                                Expanded(child: _buildTextField('Centro Op.', _operationCenterController)),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Expanded(child: _buildTextField('Código de Bono (PromoCode)', _promoCodeController)),
                                                const SizedBox(width: 12),
                                                ElevatedButton(
                                                  onPressed: _currentStep == 0 && !_isLoadingStep ? _validatePromo : null,
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: _currentStep >= 1 ? greenSuccess : const Color(0xFF21262D),
                                                    foregroundColor: textPrimary,
                                                    side: BorderSide(color: borderDark),
                                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                                  ),
                                                  child: _isLoadingStep 
                                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                                    : Text(_currentStep >= 1 ? "Validado" : "Validar Bono"),
                                                ),
                                              ],
                                            ),
                                            if (_bonusInfo != null)
                                              Container(
                                                margin: const EdgeInsets.only(top: 12),
                                                padding: const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: _bonusInfo!.isValid ? greenSuccess.withOpacity(0.1) : redAlert.withOpacity(0.1),
                                                  border: Border.all(color: _bonusInfo!.isValid ? greenSuccess.withOpacity(0.3) : redAlert.withOpacity(0.3)),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      _bonusInfo!.isValid ? Icons.check_circle : Icons.error,
                                                      color: _bonusInfo!.isValid ? greenSuccess : redAlert,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            _bonusInfo!.isValid ? "Bono Encontrado: ${_bonusInfo!.title}" : "Bono Inválido",
                                                            style: TextStyle(
                                                              color: _bonusInfo!.isValid ? greenSuccess : redAlert,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          if (_bonusInfo!.isValid)
                                                            Text(
                                                              "${_bonusInfo!.description} • Monto: ${_bonusInfo!.amount} • Saldo: ${_bonusInfo!.balance}",
                                                              style: TextStyle(color: textSecondary, fontSize: 12),
                                                            )
                                                          else
                                                            Text(
                                                              _bonusInfo!.errorMsg,
                                                              style: TextStyle(color: textSecondary, fontSize: 12),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      
                                      const SizedBox(height: 24),
                                      
                                      // Gestor de Items
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: bgCard,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: borderDark),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Buscar Referencia", style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 12),
                                            // Search Input
                                            Container(
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: bgDark,
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: borderDark),
                                              ),
                                              child: TextField(
                                                controller: _searchController,
                                                style: TextStyle(color: textPrimary),
                                                onChanged: (val) {
                                                  Future.delayed(const Duration(milliseconds: 300), () {
                                                    if (_searchController.text == val) {
                                                      _doSearch(val);
                                                    }
                                                  });
                                                },
                                                decoration: InputDecoration(
                                                  hintText: "Escribe referencia o descripción...",
                                                  hintStyle: TextStyle(color: textSecondary),
                                                  prefixIcon: Icon(Icons.search, color: textSecondary, size: 18),
                                                  border: InputBorder.none,
                                                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                                ),
                                              ),
                                            ),
                                            
                                            // Autocomplete results
                                            if (_searchResults.isNotEmpty)
                                              Container(
                                                margin: const EdgeInsets.only(top: 8),
                                                constraints: const BoxConstraints(maxHeight: 150),
                                                decoration: BoxDecoration(
                                                  color: bgDark,
                                                  border: Border.all(color: borderDark),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: ListView.builder(
                                                  itemCount: _searchResults.length,
                                                  itemBuilder: (ctx, i) {
                                                    final p = _searchResults[i];
                                                    return ListTile(
                                                      title: Text(p.descripcion, style: TextStyle(color: textPrimary, fontSize: 13)),
                                                      subtitle: Text("${p.referencia} - \$${p.precioParti}", style: TextStyle(color: textSecondary, fontSize: 11)),
                                                      onTap: () => _selectProduct(p),
                                                    );
                                                  },
                                                ),
                                              ),
                                            
                                            if (_isSearching)
                                              const Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))),
                                              ),
                                              
                                            if (_selectedRef != null) ...[
                                              const SizedBox(height: 16),
                                              Container(
                                                padding: const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: bgDark.withOpacity(0.5),
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(color: greenSuccess.withOpacity(0.5)),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text("Seleccionado: $_selectedRef", style: TextStyle(color: greenSuccess, fontWeight: FontWeight.bold)),
                                                        Text("\$$_selectedPrice", style: TextStyle(color: textSecondary)),
                                                      ],
                                                    ),
                                                    Text(_selectedDesc ?? '', style: TextStyle(color: textSecondary, fontSize: 12)),
                                                    const SizedBox(height: 16),
                                                    Row(
                                                      children: [
                                                        Expanded(child: _buildTextField('Cant', _qtyController, isNumeric: true)),
                                                        const SizedBox(width: 8),
                                                        Expanded(child: _buildTextField('Desc. Val', _discountController, isNumeric: true)),
                                                        const SizedBox(width: 8),
                                                        Expanded(child: _buildTextField('Consec.', _consecutiveController, isNumeric: true)),
                                                        const SizedBox(width: 8),
                                                        Expanded(child: _buildTextField('Días Ent.', _deliveryDaysController, isNumeric: true)),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 12),
                                                    _buildTextField('Notas', _notesController),
                                                    const SizedBox(height: 16),
                                                    Align(
                                                      alignment: Alignment.centerRight,
                                                      child: ElevatedButton.icon(
                                                        onPressed: _addItem,
                                                        icon: const Icon(Icons.add, size: 16),
                                                        label: const Text("Agregar Ítem"),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: const Color(0xFF21262D),
                                                          foregroundColor: textPrimary,
                                                          side: BorderSide(color: borderDark),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ]
                                          ],
                                        ),
                                      ),
                                      
                                      const SizedBox(height: 24),
                                      
                                      // Tabla de Items Agregados
                                      Text("Referencias Agregadas (${_addedItems.length})", style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 12),
                                      if (_addedItems.isEmpty)
                                        Center(child: Text("Sin ítems.", style: TextStyle(color: textSecondary))),
                                      for (int i=0; i<_addedItems.length; i++)
                                        Container(
                                          margin: const EdgeInsets.only(bottom: 8),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: bgCard,
                                            border: Border.all(color: borderDark),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 24, height: 24,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: bgDark,
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(color: borderDark),
                                                ),
                                                child: Text("${i+1}", style: TextStyle(color: textSecondary, fontSize: 11)),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(_addedItems[i].reference, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
                                                    Text(_addedItems[i].description, style: TextStyle(color: textSecondary, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                                                  ],
                                                ),
                                              ),
                                              Text("Cant: ${_addedItems[i].quantity}", style: TextStyle(color: textPrimary, fontSize: 12)),
                                              const SizedBox(width: 16),
                                              Text("Desc: \$${_addedItems[i].discountValue}", style: TextStyle(color: textPrimary, fontSize: 12)),
                                              const SizedBox(width: 16),
                                              IconButton(
                                                icon: Icon(Icons.delete_outline, color: redAlert, size: 18),
                                                onPressed: () => _removeItem(i),
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                              )
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                // TAB 2: TRACKING
                                Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildTimeline(),
                                      const SizedBox(height: 24),
                                      Text("Terminal Output", style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                                      const SizedBox(height: 8),
                                      _buildLogsTerminal(),
                                      const SizedBox(height: 16),
                                      Expanded(
                                        child: SingleChildScrollView(
                                          child: _buildJsonBlock(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: bgCard,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                border: Border(top: BorderSide(color: borderDark)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _isLoadingStep ? null : () => Navigator.of(context).pop(),
                    child: Text('Cerrar', style: TextStyle(color: textSecondary)),
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: (_currentStep >= 2 && !_isLoadingStep) ? _handlePreview : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF21262D),
                          foregroundColor: textPrimary,
                          side: BorderSide(color: borderDark),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        child: const Text('Run Preview'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: (_currentStep >= 3 && !_isLoadingStep) ? _handleApply : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: greenSuccess,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        child: const Text('Commit to Siesa (Apply)'),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
