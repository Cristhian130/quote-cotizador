import 'package:flutter/material.dart';
import '../../../../core/theme/ia_colors.dart';
import '../atoms/ia_button.dart';
import '../molecules/labeled_input.dart';
import '../molecules/searchable_selector.dart';
import '../atoms/siesa_button.dart';
import '../../presentation/providers/notification_provider.dart';
import '../../presentation/providers/quote_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ClientStepperDialog extends ConsumerStatefulWidget {
  const ClientStepperDialog({super.key});

  @override
  ConsumerState<ClientStepperDialog> createState() => _ClientStepperDialogState();
}

class _ClientStepperDialogState extends ConsumerState<ClientStepperDialog> {
  // Step 1 Controllers
  final _cedulaCtrl = TextEditingController();
  final _nombresCtrl = TextEditingController();
  final _apellidosCtrl = TextEditingController();
  final _celularCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();

  // Step 2 Controllers
  final _departamentoCtrl = TextEditingController();
  final _ciudadCtrl = TextEditingController();
  final _barrioCtrl = TextEditingController();

  int _currentStep = 0;
  final int _totalSteps = 3;

  // Step 3 State: List of criteria
  final List<Map<String, String>> _selectedCriteria = [
    {'label': 'MACROSEGMENTO', 'code': '', 'desc': ''},
    {'label': 'SEGMENTACION', 'code': '', 'desc': ''},
    {'label': 'LINEA DE VENTA', 'code': '', 'desc': ''},
    {'label': 'CLASE DE CLIENTE', 'code': '', 'desc': ''},
    {'label': 'ZONA-AREA', 'code': '', 'desc': ''},
    {'label': 'COBRA DOMICILIO', 'code': '', 'desc': ''},
  ];

  // Options for "Agregar columna..."
  final List<String> _availableOptionalCriteria = [
    '007 - CRUCE DE CUENTA',
    '008 - LISTA DE PRECIO',
    '009 - COBRO EXTERNO',
    '010 - ENTIDAD COBRO',
    '011 - DESCUENTOS DE',
    '012 - CLIENTE PREFER',
  ];

  // Dummy data for testing
  final List<String> _departamentos = [
    'Antioquia',
    'Atlántico',
    'Bogotá D.C.',
    'Bolívar',
    'Cundinamarca',
    'Santander',
    'Valle del Cauca',
  ];

  final List<String> _ciudades = [
    'Medellín',
    'Barranquilla',
    'Bogotá',
    'Cartagena',
    'Cali',
    'Bucaramanga',
    'Envigado',
    'Itagüí',
  ];

  @override
  void dispose() {
    _cedulaCtrl.dispose();
    _nombresCtrl.dispose();
    _apellidosCtrl.dispose();
    _celularCtrl.dispose();
    _correoCtrl.dispose();
    _departamentoCtrl.dispose();
    _ciudadCtrl.dispose();
    _barrioCtrl.dispose();
    super.dispose();
  }

  bool _isStep1Valid() {
    final nombres = _nombresCtrl.text.trim();
    final apellidos = _apellidosCtrl.text.trim();
    // Requisito: al menos un nombre Y un apellido (Usuario pidió "al menos un nombre y un apellido")
    // Note: The previous requirement was "at least one of them", but user clarified "un nombre Y un apellido".
    // Wait, step 8 said "(el requisito es al menos un nombre y un apellido)".
    return nombres.isNotEmpty && apellidos.isNotEmpty;
  }

  bool _isStep2Valid() {
    return _departamentoCtrl.text.isNotEmpty &&
        _ciudadCtrl.text.isNotEmpty &&
        _barrioCtrl.text.isNotEmpty;
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_isStep1Valid()) {
        setState(() => _currentStep++);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debe ingresar un Nombre y un Apellido'),
            backgroundColor: IaColors.destructive,
          ),
        );
      }
    } else if (_currentStep == 1) {
      if (_isStep2Valid()) {
        setState(() => _currentStep++);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor complete los datos de ubicación'),
            backgroundColor: IaColors.destructive,
          ),
        );
      }
    } else if (_currentStep == 2) {
      // Finalize - Save in Draft
      final clientData = {
        'cedula': _cedulaCtrl.text,
        'nombres': _nombresCtrl.text,
        'apellidos': _apellidosCtrl.text,
        'celular': _celularCtrl.text,
        'correo': _correoCtrl.text,
        'departamento': _departamentoCtrl.text,
        'ciudad': _ciudadCtrl.text,
        'barrio': _barrioCtrl.text,
        'criteria': _selectedCriteria,
      };

      final draft = {
        'id': _cedulaCtrl.text,
        'name': '${_nombresCtrl.text} ${_apellidosCtrl.text}',
        'step': 3,
        'date': DateTime.now().toString(),
      };
      
      ref.read(notificationProvider.notifier).addDraft(draft);
      ref.read(quoteProvider.notifier).setClient(clientData);

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cliente guardado en borrador'),
          backgroundColor: IaColors.primary,
        ),
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _showCriteriaSelectionModal(int index) {
    showDialog(
      context: context,
      builder: (context) => _CriteriaSelectionModal(
        title: 'Criterios mayores',
        onSelected: (code, description) {
          setState(() {
            _selectedCriteria[index]['code'] = code;
            _selectedCriteria[index]['desc'] = description;
          });
        },
      ),
    );
  }

  void _addOptionalColumn(String label) {
    if (!_selectedCriteria.any((c) => c['label'] == label)) {
      setState(() {
        _selectedCriteria.add({'label': label, 'code': '', 'desc': ''});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = 'Datos del Cliente';
    if (_currentStep == 1) title = 'Ubicación';
    if (_currentStep == 2) title = 'Configurador de Criterios';

    return Dialog(
      backgroundColor: IaColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Container(
        width: 800, // Widened for criteria table
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: IaColors.foreground,
                      ),
                    ),
                    Text(
                      'Paso ${_currentStep + 1} de $_totalSteps',
                      style: const TextStyle(
                        fontSize: 12,
                        color: IaColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
                if (_currentStep == 2)
                  Row(
                    children: [
                      _buildAddColumnSelector(),
                      const SizedBox(width: 8),
                      IAButton(
                        variant: IAButtonVariant.outline,
                        padding: const EdgeInsets.all(8),
                        onPressed: () {},
                        child: const Icon(LucideIcons.plus, size: 16),
                      ),
                    ],
                  ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(LucideIcons.x, size: 20),
                  color: IaColors.mutedForeground,
                )
              ],
            ),
            const SizedBox(height: 24),
            
            // Step content
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildCurrentStep(),
            ),
            
            // Footer
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep == 2)
                  SiesaButton(
                    onPressed: () {
                      final clientData = {
                        'cedula': _cedulaCtrl.text,
                        'nombres': _nombresCtrl.text,
                        'apellidos': _apellidosCtrl.text,
                        'celular': _celularCtrl.text,
                        'correo': _correoCtrl.text,
                        'departamento': _departamentoCtrl.text,
                        'ciudad': _ciudadCtrl.text,
                        'barrio': _barrioCtrl.text,
                        'criteria': _selectedCriteria,
                      };
                      ref.read(quoteProvider.notifier).setClient(clientData);

                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Enviando pedido a Siesa...'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    },
                  )
                else
                  const SizedBox.shrink(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_currentStep == 0)
                      IAButton(
                        variant: IAButtonVariant.ghost,
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      )
                    else
                      IAButton(
                        variant: IAButtonVariant.ghost,
                        onPressed: _previousStep,
                        child: const Text('Atrás'),
                      ),
                    const SizedBox(width: 12),
                    IAButton(
                      onPressed: _nextStep,
                      child: Text(_currentStep == 2 ? 'Guardar en borrador' : 'Siguiente paso'),
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0: return _buildStep1();
      case 1: return _buildStep2();
      case 2: return _buildStep3();
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildStep1() {
    return Column(
      key: const ValueKey(0),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LabeledInput(
          label: 'Cédula',
          placeholder: 'Ingrese documento del cliente',
          onChanged: (v) => _cedulaCtrl.text = v,
          value: _cedulaCtrl.text,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: LabeledInput(
                label: 'Nombres',
                placeholder: 'Ej. Juan Pérez',
                onChanged: (v) => _nombresCtrl.text = v,
                value: _nombresCtrl.text,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: LabeledInput(
                label: 'Apellidos',
                placeholder: 'Ej. López Silva',
                onChanged: (v) => _apellidosCtrl.text = v,
                value: _apellidosCtrl.text,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: LabeledInput(
                label: 'Celular',
                placeholder: 'Número de contacto',
                onChanged: (v) => _celularCtrl.text = v,
                value: _celularCtrl.text,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: LabeledInput(
                label: 'Correo Electrónico',
                placeholder: 'ejemplo@correo.com',
                onChanged: (v) => _correoCtrl.text = v,
                value: _correoCtrl.text,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      key: const ValueKey(1),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SearchableSelector(
          label: 'Departamento',
          placeholder: 'Seleccione departamento',
          items: _departamentos,
          value: _departamentoCtrl.text,
          onSelected: (v) => setState(() => _departamentoCtrl.text = v),
        ),
        const SizedBox(height: 16),
        SearchableSelector(
          label: 'Ciudad',
          placeholder: 'Seleccione ciudad',
          items: _ciudades,
          value: _ciudadCtrl.text,
          onSelected: (v) => setState(() => _ciudadCtrl.text = v),
        ),
        const SizedBox(height: 16),
        LabeledInput(
          label: 'Barrio',
          placeholder: 'Nombre del barrio',
          onChanged: (v) => _barrioCtrl.text = v,
          value: _barrioCtrl.text,
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Container(
      key: const ValueKey(2),
      decoration: BoxDecoration(
        color: IaColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: IaColors.border),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: IaColors.muted,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: const [
                Expanded(flex: 3, child: Text('Descripción', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: IaColors.mutedForeground))),
                Expanded(flex: 1, child: Text('Criterio', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: IaColors.mutedForeground))),
                Expanded(flex: 3, child: Text('Descripción', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: IaColors.mutedForeground))),
                SizedBox(width: 32),
              ],
            ),
          ),
          // Rows
          ...List.generate(_selectedCriteria.length, (index) {
            final row = _selectedCriteria[index];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: IaColors.border.withOpacity(0.5))),
              ),
              child: Row(
                children: [
                  Expanded(flex: 3, child: Text(row['label']!, style: const TextStyle(fontSize: 13, color: IaColors.foreground))),
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () => _showCriteriaSelectionModal(index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: IaColors.muted.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: IaColors.border),
                        ),
                        child: Text(
                          row['code']!.isEmpty ? '...' : row['code']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(flex: 3, child: Text(row['desc']!, style: const TextStyle(fontSize: 12, color: IaColors.mutedForeground))),
                  if (index >= 6) // Temporary logic for optional columns
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 14, color: IaColors.destructive),
                      onPressed: () => setState(() => _selectedCriteria.removeAt(index)),
                    )
                  else
                    const SizedBox(width: 32),
                ],
              ),
            );
          }),
          // Footer / Total
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9), // Light green for total general
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: const [
                Text('Total general', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddColumnSelector() {
    return Container(
      width: 180,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: IaColors.muted.withOpacity(0.3),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: IaColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: const Text('Agregar columna...', style: TextStyle(fontSize: 12)),
          icon: const Icon(LucideIcons.chevronDown, size: 16),
          isExpanded: true,
          items: _availableOptionalCriteria.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(fontSize: 12)),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) _addOptionalColumn(val);
          },
        ),
      ),
    );
  }
}

class _CriteriaSelectionModal extends StatefulWidget {
  final String title;
  final void Function(String code, String description) onSelected;

  const _CriteriaSelectionModal({
    required this.title,
    required this.onSelected,
  });

  @override
  State<_CriteriaSelectionModal> createState() => _CriteriaSelectionModalState();
}

class _CriteriaSelectionModalState extends State<_CriteriaSelectionModal> {
  final List<Map<String, String>> _options = [
    {'code': '0001', 'desc': 'PARTICULARES'},
    {'code': '0002', 'desc': 'PROFESIONALES'},
    {'code': '0003', 'desc': 'ASEGURADORAS'},
    {'code': '0004', 'desc': 'EMPRESAS'},
  ];

  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(LucideIcons.x, size: 20), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: IaColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // Modal Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: const BoxDecoration(color: IaColors.muted, borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))),
                    child: Row(
                      children: const [
                        Expanded(flex: 1, child: Text('Código', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        Expanded(flex: 3, child: Text('Descripción', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      ],
                    ),
                  ),
                  // Modal Rows
                  ...List.generate(_options.length, (index) {
                    final isSelected = _selectedIndex == index;
                    return InkWell(
                      onTap: () => setState(() => _selectedIndex = index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFE8F5E9) : null,
                          border: Border(bottom: BorderSide(color: IaColors.border.withOpacity(0.5))),
                        ),
                        child: Row(
                          children: [
                            if (isSelected) const Icon(LucideIcons.play, size: 12, color: Colors.green) else const SizedBox(width: 12),
                            const SizedBox(width: 8),
                            Expanded(flex: 1, child: Text(_options[index]['code']!, style: const TextStyle(fontSize: 13))),
                            Expanded(flex: 3, child: Text(_options[index]['desc']!, style: const TextStyle(fontSize: 13))),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IAButton(
                  variant: IAButtonVariant.ghost,
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 12),
                IAButton(
                  onPressed: _selectedIndex == null ? null : () {
                    widget.onSelected(_options[_selectedIndex!]['code']!, _options[_selectedIndex!]['desc']!);
                    Navigator.pop(context);
                  },
                  child: const Text('Aceptar'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
