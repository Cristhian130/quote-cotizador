import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/ia_colors.dart';
import '../domain/stock_data_state.dart';

const stockPageBackground = Color(0xFFF6F7F9);
const stockText = Color(0xFF1F2937);
const stockMuted = Color(0xFF667085);
const stockSuccess = Color(0xFF1F8A5B);
const stockWarning = Color(0xFFD97706);
const stockDanger = Color(0xFFC93C37);

class ErpStockPage extends StatelessWidget {
  final String title;
  final String description;
  final List<Widget> actions;
  final Widget filters;
  final Widget child;

  const ErpStockPage({
    super.key,
    required this.title,
    required this.description,
    required this.filters,
    required this.child,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 720;
        final horizontalPadding = compact ? 12.0 : 20.0;
        final titleBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: stockText,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              description,
              style: const TextStyle(fontSize: 11.5, color: stockMuted),
            ),
          ],
        );

        return ColoredBox(
          color: stockPageBackground,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  14,
                  horizontalPadding,
                  12,
                ),
                child: compact
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          titleBlock,
                          if (actions.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.end,
                              children: actions,
                            ),
                          ],
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(child: titleBlock),
                          ...actions,
                        ],
                      ),
              ),
              Container(
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  0,
                  horizontalPadding,
                  12,
                ),
                child: filters,
              ),
              const Divider(height: 1, color: IaColors.border),
              Expanded(child: child),
            ],
          ),
        );
      },
    );
  }
}

class ErpSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;

  const ErpSearchField({
    super.key,
    required this.controller,
    required this.hint,
    this.onSubmitted,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: TextField(
        controller: controller,
        onSubmitted: onSubmitted,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 12.5, color: stockText),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 12.5, color: stockMuted),
          prefixIcon: const Icon(LucideIcons.search, size: 15),
          filled: true,
          fillColor: const Color(0xFFFAFBFC),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: IaColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: IaColors.primaryLight),
          ),
        ),
      ),
    );
  }
}

class ErpTextFilter extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final double width;

  const ErpTextFilter({
    super.key,
    required this.label,
    required this.controller,
    this.width = 130,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 34,
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 12, color: stockText),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 11.5, color: stockMuted),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: IaColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: IaColors.primaryLight),
          ),
        ),
      ),
    );
  }
}

class ErpSelectFilter extends StatelessWidget {
  final String value;
  final String label;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  final double width;

  const ErpSelectFilter({
    super.key,
    required this.value,
    required this.label,
    required this.options,
    required this.onChanged,
    this.width = 130,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 34,
      child: DropdownButtonFormField<String>(
        value: value,
        isDense: true,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 12, color: stockText),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: IaColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: IaColors.primaryLight),
          ),
        ),
        items: [
          DropdownMenuItem(value: '', child: Text(label)),
          ...options.map(
            (option) => DropdownMenuItem(value: option, child: Text(option)),
          ),
        ],
      ),
    );
  }
}

class ErpActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool primary;

  const ErpActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = ButtonStyle(
      minimumSize: WidgetStateProperty.all(const Size(0, 34)),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 12),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      textStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
    return primary
        ? FilledButton.icon(
            onPressed: onPressed,
            style: style,
            icon: Icon(icon, size: 14),
            label: Text(label),
          )
        : OutlinedButton.icon(
            onPressed: onPressed,
            style: style,
            icon: Icon(icon, size: 14),
            label: Text(label),
          );
  }
}

class StockOriginBadge extends StatelessWidget {
  final StockDataOrigin origin;
  final DateTime? syncedAt;

  const StockOriginBadge({super.key, required this.origin, this.syncedAt});

  @override
  Widget build(BuildContext context) {
    final local = origin == StockDataOrigin.local;
    final color = local ? stockWarning : stockSuccess;
    final icon = local ? LucideIcons.database : LucideIcons.checkCircle2;
    final label = local ? 'Datos locales' : 'API actualizada';
    final time = syncedAt == null
        ? ''
        : ' · ${syncedAt!.hour.toString().padLeft(2, '0')}:${syncedAt!.minute.toString().padLeft(2, '0')}';
    return Tooltip(
      message: local
          ? 'La API no respondió; se muestran datos guardados en SQLite.'
          : 'Datos recibidos del backend y guardados localmente.',
      child: Container(
        height: 26,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          border: Border.all(color: color.withValues(alpha: 0.25)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 5),
            Text(
              '$label$time',
              style: TextStyle(
                color: color,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ErpTableHeader extends StatelessWidget {
  final List<Widget> children;

  const ErpTableHeader({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      color: const Color(0xFFF1F3F5),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(children: children),
    );
  }
}

class ErpColumnLabel extends StatelessWidget {
  final String text;
  final int flex;
  final TextAlign align;

  const ErpColumnLabel(
    this.text, {
    super.key,
    this.flex = 1,
    this.align = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: align,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: stockMuted,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class ErpStatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const ErpStatusPill({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class ErpEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final bool isError;

  const ErpEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isError ? stockDanger : stockMuted;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isError ? LucideIcons.alertTriangle : LucideIcons.search,
              size: 30,
              color: color,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: stockText,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: stockMuted, fontSize: 11.5),
            ),
          ],
        ),
      ),
    );
  }
}
