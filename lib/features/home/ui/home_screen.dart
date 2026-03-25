import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ──────────────────────────────────────────────
//  IA Home Screen — ERPNext-inspired Dashboard
// ──────────────────────────────────────────────

const Color _blue = Color(0xFF458AC9);
const Color _darkBlue = Color(0xFF192D4D);
const Color _surfaceGray = Color(0xFFF4F5F7);
const Color _border = Color(0xFFE2E4E9);

class HomeScreen extends StatefulWidget {
  final VoidCallback onNavigateToVentas;
  final VoidCallback onNavigateToStock;
  final VoidCallback onNavigateToInsights;

  const HomeScreen({
    super.key,
    required this.onNavigateToVentas,
    required this.onNavigateToStock,
    required this.onNavigateToInsights,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  int? _hoveredIndex;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;

  static const List<_Module> _modules = [
    _Module(
      id: 'base',
      name: 'Base de Negocio',
      icon: Icons.foundation_rounded,
      color: Color(0xFF458AC9),
      description: 'Configuración central',
    ),
    _Module(
      id: 'insights',
      name: 'Smart Insights',
      icon: Icons.insights_rounded,
      color: Color(0xFF7B5FF5),
      description: 'Analítica e inteligencia',
    ),
    _Module(
      id: 'despachos',
      name: 'Despachos',
      icon: Icons.local_shipping_rounded,
      color: Color(0xFF2BAE7E),
      description: 'Gestión de envíos',
    ),
    _Module(
      id: 'clientes',
      name: 'Clientes',
      icon: Icons.people_rounded,
      color: Color(0xFFE67E22),
      description: 'Base de clientes',
    ),
    _Module(
      id: 'inventario',
      name: 'Inventario',
      icon: Icons.inventory_2_rounded,
      color: Color(0xFF458AC9),
      description: 'Control de stock',
    ),
    _Module(
      id: 'ventas',
      name: 'Ventas',
      icon: Icons.receipt_long_rounded,
      color: Color(0xFF458AC9),
      description: 'Cotizaciones y facturas',
    ),
    _Module(
      id: 'stock',
      name: 'Stock',
      icon: Icons.warehouse_rounded,
      color: Color(0xFF458AC9),
      description: 'Almacenamiento',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyK):
            _FocusSearchIntent(),
      },
      child: Actions(
        actions: {
          _FocusSearchIntent: CallbackAction<_FocusSearchIntent>(
            onInvoke: (_) => _searchFocus.requestFocus(),
          ),
        },
        child: Scaffold(
          backgroundColor: _surfaceGray,
          body: Column(
            children: [
              _TopBar(searchCtrl: _searchCtrl, searchFocus: _searchFocus),
              const Divider(height: 1, color: _border),
              Expanded(
                child: FadeTransition(
                  opacity: _fade,
                  child: _ModuleGrid(
                    modules: _modules,
                    hoveredIndex: _hoveredIndex,
                    onHover: (i) => setState(() => _hoveredIndex = i),
                    onTap: _handleModuleTap,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleModuleTap(_Module module) {
    if (module.id == 'ventas') {
      widget.onNavigateToVentas();
    } else if (module.id == 'stock') {
      widget.onNavigateToStock();
    } else if (module.id == 'insights') {
      widget.onNavigateToInsights();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${module.name} — próximamente',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: _darkBlue,
          behavior: SnackBarBehavior.floating,
          width: 280,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

// ──────────────────────────────────────────────
//  Top Navigation Bar
// ──────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final TextEditingController searchCtrl;
  final FocusNode searchFocus;

  const _TopBar({required this.searchCtrl, required this.searchFocus});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Logo / Brand
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _darkBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.bolt_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Importadoras Asociadas',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _darkBlue,
              letterSpacing: 0.1,
            ),
          ),

          // Search bar — centered
          const Spacer(),
          _SearchBox(ctrl: searchCtrl, focus: searchFocus),
          const Spacer(),

          // Right actions
          _IconActionButton(
            icon: Icons.notifications_none_rounded,
            onTap: () {},
          ),
          const SizedBox(width: 4),
          _IconActionButton(icon: Icons.settings_outlined, onTap: () {}),
          const SizedBox(width: 12),
          // Avatar
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _blue.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: _blue.withOpacity(0.3), width: 1.5),
            ),
            child: const Center(
              child: Text(
                'IA',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _blue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconActionButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconActionButton({required this.icon, required this.onTap});

  @override
  State<_IconActionButton> createState() => _IconActionButtonState();
}

class _IconActionButtonState extends State<_IconActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: _hovered ? _surfaceGray : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            widget.icon,
            size: 19,
            color: _hovered ? _darkBlue : const Color(0xFF8A94A6),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  Search Box
// ──────────────────────────────────────────────
class _SearchBox extends StatefulWidget {
  final TextEditingController ctrl;
  final FocusNode focus;

  const _SearchBox({required this.ctrl, required this.focus});

  @override
  State<_SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<_SearchBox> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focus.addListener(() {
      setState(() => _focused = widget.focus.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _focused ? 380 : 300,
      height: 34,
      decoration: BoxDecoration(
        color: _focused ? Colors.white : _surfaceGray,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: _focused ? _blue.withOpacity(0.5) : _border,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Icon(
            Icons.search_rounded,
            size: 15,
            color: _focused ? _blue : const Color(0xFFA0A8B5),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: widget.ctrl,
              focusNode: widget.focus,
              style: const TextStyle(fontSize: 13, color: _darkBlue),
              decoration: const InputDecoration(
                hintText: 'Buscar módulo...',
                hintStyle: TextStyle(fontSize: 13, color: Color(0xFFA0A8B5)),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _border,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Ctrl+K',
              style: TextStyle(fontSize: 10, color: Color(0xFF8A94A6)),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  Module Grid
// ──────────────────────────────────────────────
class _ModuleGrid extends StatelessWidget {
  final List<_Module> modules;
  final int? hoveredIndex;
  final void Function(int?) onHover;
  final void Function(_Module) onTap;

  const _ModuleGrid({
    required this.modules,
    required this.hoveredIndex,
    required this.onHover,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
        child: Center(
          child: Wrap(
            spacing: 32,
            runSpacing: 32,
            alignment: WrapAlignment.center,
            children: List.generate(
              modules.length,
              (i) => _ModuleTile(
                module: modules[i],
                isHovered: hoveredIndex == i,
                onHover: (h) => onHover(h ? i : null),
                onTap: () => onTap(modules[i]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  Individual Module Tile
// ──────────────────────────────────────────────
class _ModuleTile extends StatelessWidget {
  final _Module module;
  final bool isHovered;
  final void Function(bool) onHover;
  final VoidCallback onTap;

  const _ModuleTile({
    required this.module,
    required this.isHovered,
    required this.onHover,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 96,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon container
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  gradient: isHovered
                      ? LinearGradient(
                          colors: [
                            module.color,
                            module.color.withOpacity(0.78),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: [
                            module.color.withOpacity(0.92),
                            module.color.withOpacity(0.75),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: isHovered
                      ? [
                          BoxShadow(
                            color: module.color.withOpacity(0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: module.color.withOpacity(0.18),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: AnimatedScale(
                  scale: isHovered ? 1.06 : 1.0,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(module.icon, color: Colors.white, size: 34),
                ),
              ),
              const SizedBox(height: 10),
              // Label
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 150),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isHovered ? FontWeight.w600 : FontWeight.w500,
                  color: isHovered ? _darkBlue : const Color(0xFF3D4A5C),
                  letterSpacing: 0.1,
                ),
                child: Text(
                  module.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  Data model
// ──────────────────────────────────────────────
class _Module {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String description;

  const _Module({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
  });
}

// ──────────────────────────────────────────────
//  Keyboard shortcut intent
// ──────────────────────────────────────────────
class _FocusSearchIntent extends Intent {}
