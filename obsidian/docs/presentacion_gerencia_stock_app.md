# 🚀 Presentación Gerencia — Módulo de Inventario Inteligente
## Importadoras Asociadas · App de Cotización Desktop · Marzo 2026

---

> **Objetivo de esta presentación:** Mostrar lo que se ha construido en el módulo de Stock e Inventario de la aplicación de escritorio, el valor que aporta al equipo de ventas y la hoja de ruta técnica para los siguientes pasos, basada en la investigación del ecosistema `importadoras-core-power`.

---

## 📌 1. Visor Múltiple de Inventario

### ¿Qué es?
Una pantalla de visualización rápida del inventario de la bodega **PV122 (Celeste Medellín)**, accesible desde el Dashboard de Stock. Permite consultar existencias, costos promedio, tránsito y compromisos de cualquier artículo sin salir de la app.

### ¿Cómo funciona?
- Los datos se leen directamente de la **base de datos SQLite local** (`quote_app.db`), lo que garantiza disponibilidad **sin necesidad de internet**.
- Se sincroniza desde la API de Siesa cuando hay conexión disponible.
- La interfaz replica el estilo visual de "Transacción de Stock" para coherencia de UX.

### Campos disponibles por artículo
| Campo | Descripción |
|---|---|
| `referencia` | Código único del artículo |
| `descripcion` | Nombre del producto |
| `bodega` | Código de la bodega (PV122) |
| `existencia` | Unidades disponibles actualmente |
| `cantTransito` | Unidades en camino hacia la bodega |
| `cantComprometida` | Unidades ya comprometidas a pedidos |
| `costoProm` | Costo promedio ponderado unitario |
| `clasificacion` | Rotación del artículo (A, AA, Z, ZZ) |

### Valor para el negocio
✅ Consulta instantánea sin esperar respuesta del ERP  
✅ Datos reales del inventario disponibles en campo  
✅ Evita overselling: el vendedor ve en tiempo real qué hay comprometido  

---

## 📌 2. Análisis de Rentabilidad por Bodega (Smart Dashboard)

### ¿Qué es?
Un panel analítico integrado en la pantalla de Stock que muestra métricas clave de rentabilidad y salud del inventario para la bodega PV122, también visible desde el módulo **Smart Insights**.

### Métricas incluidas
| Indicador | Descripción |
|---|---|
| **Valor total del inventario** | `Σ (existencia × costo promedio)` |
| **Artículos inmovilizados** | Sin movimiento > 90 días |
| **Rotación promedio** | Velocidad de salida del inventario |
| **Artículos en riesgo de rotura** | Stock bajo en clasificación A/AA |
| **Cobertura de demanda** | Días estimados de stock restante |

### Visualización
- Tarjetas de KPI con comparativa vs mes anterior
- Clasificación ABC visible a nivel de categoría
- Indicadores de alerta (rojo/amarillo/verde) configurables por umbral

### Valor para el negocio
✅ Decisiones de compra basadas en datos, no en intuición  
✅ Identificación rápida de capital inmobilizado  
✅ Alertas proactivas antes de que ocurra una rotura de stock  

---

## 📌 3. Alertas Proactivas de Inventario en el Proceso de Venta

### ¿Qué es?
Un **banner inteligente** dentro de la pantalla de Cotización (`QuotePage`) que analiza el inventario en tiempo real mientras el vendedor arma la factura, y le muestra sugerencias accionables basadas en **6 reglas de negocio activas**.

### Las 6 reglas activas
| ID | Regla | Tipo | Acción Sugerida |
|---|---|---|---|
| R1 | Liquidación urgente — sin stock | Sin existencia | Traslado de bodega |
| R2 | Inmovilizado > 120 días | Inmovilizado | Descuento hasta 25% |
| R3 | Alta demanda — stock comprometido > 70% | Alta demanda | Priorizar en cotización |
| R4 | Sobrestock ZZ — más de 50 uds baja rotación | Sobrestock | Descuento 15% |
| R5 | Stock crítico — menos de 5 uds en A/AA | Stock crítico | Reposición inmediata |
| R6 | Tránsito > 30 uds — ofrece preventa | En tránsito | Ofrecer como preventa |

### Flujo de la funcionalidad
```
Vendedor abre QuotePage
      │
      ▼
StockAlertBanner aparece (animado, colapsable)
      │
      ▼
Motor de reglas evalúa los 50 productos de PV122
      │
      ▼
Muestra alertas priorizadas: "BUJIA ALTO SWIFT — ⚡ Alta demanda"
      │
      ▼
Vendedor presiona "Aplicar acción" → descuento sugerido
```

### Visual en listas de productos
- En el modal de **Resultados de Búsqueda**: badge rojo 🔥 **Alerta** al lado de productos con reglas activas
- En la **Tabla de Facturación**: mismo badge inline para recordatorio visual

### Valor para el negocio
✅ El vendedor nunca ofrece lo que no hay en bodega  
✅ Impulsa la rotación de inventario en el acto de la venta  
✅ Reduce el tiempo de negociación con sugerencias automáticas de precio  

---

## 📌 4. Visor Jerárquico del Inventario (Análisis por Categorías)

### ¿Qué es?
Vista analítica que clasifica todo el inventario en grupos por tipo de rotación (ABC), mostrando el desempeño comparado de cada categoría dentro de la bodega.

### Categorías de clasificación
| Clase | Descripción | Estrategia |
|---|---|---|
| **A** | Alta rotación, alta prioridad | Mantener stock óptimo, alertas tempranas |
| **AA** | Muy alta rotación | Reposición automática sugerida |
| **Z** | Rotación baja | Monitorear para liquidación |
| **ZZ** | Sin rotación / inmovilizado | Descuento agresivo o traslado |

### Funcionalidades
- Filtro por clasificación y bodega
- Vista de artículos con mayor impacto en capital inmovilizado
- Exportación visual del análisis

### Valor para el negocio
✅ Focaliza los esfuerzos del equipo en los artículos de mayor impacto  
✅ Justifica decisiones de compra con datos de clasificación  
✅ Facilita auditorías de inventario  

---

## 🔬 Investigación: Módulo Inventario en `importadoras-core-power`

> Esta sección documenta lo que ya existe en la plataforma web `importadoras-core-power` (Next.js) y cómo puede aprovecharse para potenciar el módulo de Stock de la app de escritorio.

### Arquitectura Existente (Core Power)

```
BACKEND (Node.js + GraphQL + MongoDB)
      │
      │ reporte=35  (REST)     APIConfiguracionBodegas (GraphQL)
      │
NEXT.JS FRONTEND (importadoras-core-power)
      │
      ├── /api/inventario          ← GET por bodega → MongoDB inventarioresultadosyuba
      ├── /api/bodegas             ← CRUD bodegas (GraphQL + REST)
      │
      └── /audit (Cuadre Inventario)
              ├── InventoryDashboard.tsx       ← Orquestador principal
              ├── WarehouseSelector.tsx        ← Selector de bodega con estados
              ├── DataTable.tsx               ← Tabla paginada con filtros
              ├── FiltersPanel.tsx            ← Panel de filtros dinámicos
              ├── ActionButtons.tsx           ← Botones de acción principales
              └── Sidebar.tsx                ← Navegación lateral
```

### Datos de Inventario Disponibles en la API

Cuando se consulta `/api/inventario?bodega=PV122`, se recibe por artículo:

```json
{
  "referencia": "string",
  "descripcion": "string",
  "cantidad_teorica": "string",
  "cantidad_inventario": "string",
  "cantidad_diferencia": number,
  "valor_diferencia": number,
  "costo_unitario": "string",
  "ubicacion": "string",
  "hora": "string"
}
```

> **Nota clave:** Este endpoint retorna datos de conciliación (teórico vs físico), diferentes a los datos de existencia que ya tenemos en SQLite. Es complementario.

### Estado Redux (auditSlice)

```typescript
{
  selectedWarehouse: string,       // Bodega activa
  filter: string,                  // Texto de búsqueda
  dateFilter: string,              // Filtro por fecha
  inventoryData: InventoryRecord[], // Datos cargados
  isLoading: boolean,
  error: string | null,
  currentPage: number,
  pageSize: number,
  totalItems: number
}
```

### Exportaciones Disponibles

| Utilidad | Descripción | Relevancia |
|---|---|---|
| `exportActaInventario.ts` | Genera Excel con plantilla de Acta de Inventario General (ExcelJS) | Alta — para Regulación de Stock y Comprobante de Costos |
| `exportToExcel.ts` | Exportación genérica a Excel de cualquier tabla de datos | Alta — para Lista de Empaque e Inspección de Calidad |

---

## 🗺️ Hoja de Ruta: Aprovechamiento en la App de Escritorio

| Funcionalidad de Stock | Qué tomar de Core Power | Cómo integrarlo |
|---|---|---|
| **Transacción de Stock** | DataTable.tsx + FilterPanel.tsx | Replicar UX de tabla paginada con filtros en Flutter |
| **Recibo de Compra** | `/api/inventario` (datos teórico vs físico) | Conectar datasource REST para validación de recibos |
| **Salida por Venta** | auditSlice (selectedWarehouse + inventoryData) | Ya implementado parcialmente; extender con datos de saga |
| **Solicitar Referencia** | WarehouseSelector + useBodegas hook | Construir selector de bodega dinámico desde API |
| **Regulación de Stock** | `exportActaInventario.ts` (plantilla ACTA_INVENTARIO) | Crear servicio Flutter equivalente con `excel` package |
| **Comprobante de Costos** | Campos `costo_unitario`, `valor_diferencia` del API | Nuevo reporte PDF/Excel con datos de la API de inventario |
| **Recalcular Valoración** | Lógica: `Σ (cantidad_teorica × costo_unitario)` | Implementar como servicio local con datos de SQLite |
| **Lista de Empaque** | `exportToExcel.ts` (exportación genérica) | Template Excel para lista de productos por pedido |
| **Inspección de Calidad** | FiltersPanel + DataTable con columnas custom | Nueva vista con checklist por referencia y lote |

---

## ✅ Estado Actual y Próximos Pasos

### Lo que está listo hoy
- [x] SQLite local como fuente de verdad (offline-first)
- [x] Sincronización desde API Siesa
- [x] Visor de Inventario PV122
- [x] Smart Dashboard con KPIs
- [x] Alertas proactivas con motor de reglas
- [x] Badges de alerta en búsqueda y tabla de cotización
- [x] Salida por Venta y Solicitud de Material

### Próximas implementaciones priorizadas

| Prioridad | Funcionalidad | Dependencia |
|---|---|---|
| 🔴 Alta | Conectar API `/api/inventario` para datos de conciliación | Acceso al backend de Core Power |
| 🔴 Alta | Regulación de Stock con exportación a Acta de Inventario | Plantilla ACTA_INVENTARIO.xlsx |
| 🟡 Media | WarehouseSelector dinámico desde GraphQL | GraphQL endpoint disponible |
| 🟡 Media | Comprobante de Costos con datos reales de costo unitario | API de inventario |
| 🟢 Baja | Lista de Empaque e Inspección de Calidad | Definición de flujo con logística |

---

## 📞 Contacto Técnico

- **Proyecto Flutter Desktop:** `c:\soure\quote`  
- **Plataforma Web (Core Power):** `C:\Users\GTB0007\source\importadoras-core-power`  
- **API Backend:** `http://localhost:3001/api/APIImportadoras` (reporte=35 para inventario)  
- **GraphQL:** `http://localhost:3001/graphql` (APIConfiguracionBodegas)  
- **Base de datos local:** `%AppData%\com.example\quote\quote_app.db` (SQLite)

---

*Documento generado: Marzo 2026 · Importadoras Asociadas · Equipo de Desarrollo*
